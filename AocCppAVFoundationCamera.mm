// Copyright (c) 2013 Philip M. Hubbard
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// http://opensource.org/licenses/MIT

//
// CppAVFoundationCamera.mm
//
// Note that the code in this file is Objective-C++, mixing both Objective-C
// and C++.
//

#include "AocCppAVFoundationCamera.h"

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureOutput.h>


// The Objective-C class that uses Cocoa to implement getting images from
// the camera.  The C++ class will have a private instance of this Objective-C
// class.

@interface ObjcImp : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
{
@public
    AVCaptureSession*           session;
    Aoc::CppAVFoundationCamera* cppCamera;
}

- (void)setupCaptureSession;
- (void)captureOutput:(AVCaptureOutput *)captureOutput
        didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
        fromConnection:(AVCaptureConnection *)connection;
- (void)captureOutput:(AVCaptureOutput *)captureOutput
        didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;
- (CGImageRef)imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;
@end

@implementation ObjcImp

- (void)setupCaptureSession
{
    NSError *error = nil;
    
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
 
    // Created by a class method, so goes in the autorelease pool.

    AVCaptureDevice* device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Created by a class method, so goes in the autorelease pool.
    
    AVCaptureDeviceInput* input =
        [AVCaptureDeviceInput deviceInputWithDevice:device
                                              error:&error];
    
    if (!input)
    {
        // TODO: Add better error handling.
        
        NSLog(@"No AVCapturDeviceInput: \"%@\"",
              [error localizedFailureReason]);
        assert(input);
    }
    
    [session addInput:input];
    
    AVCaptureVideoDataOutput* output =
        [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    
    [session addOutput:output];
    
    dispatch_queue_t queue = dispatch_queue_create("ObjcImpQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
    output.videoSettings =
        [NSDictionary dictionaryWithObject:
         [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                    forKey:(id)kCVPixelBufferPixelFormatTypeKey];
}

// Delegate routine that is called when a sample buffer was written.

- (void)captureOutput:(AVCaptureOutput *)captureOutput
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CGImageRef image = [self imageFromSampleBuffer:sampleBuffer];
    cppCamera->handleCapturedImage(image);
}

// Delegate routine that is called when a frame is dropped.

- (void)captureOutput:(AVCaptureOutput *)captureOutput
  didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection;
{
    // TODO: Add better error handling.
    
    NSLog(@"Dropped frame");
}

- (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    void* baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context =
        CGBitmapContextCreate(baseAddress, width, height,
                              bitsPerComponent, bytesPerRow,
                              colorSpace,
                              kCGBitmapByteOrder32Little |
                              kCGImageAlphaPremultipliedFirst);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    return (image);
}

@end


namespace Aoc
{
    
    // The implementation class for the C++ class providing the public interface.
    // This class is actually Objective-C++ so it can use an instance of the
    // Objective-C class defined above.

    class CppAVFoundationCamera::Imp
    {
    public:
        Imp() : objcImp(0), pool(0) {}
        ObjcImp*            objcImp;
        NSAutoreleasePool*  pool;
    };

    CppAVFoundationCamera::CppAVFoundationCamera(WhichThread whichThread) :
        _m (new Imp)
    {
        _m->objcImp = [[ObjcImp alloc] init];
        _m->objcImp->cppCamera = this;
        
        if (whichThread == WorkerThread)
            _m->pool = [[NSAutoreleasePool alloc] init];
        
        [_m->objcImp setupCaptureSession];
    }

    CppAVFoundationCamera::~CppAVFoundationCamera()
    {
        [_m->pool release];
        [_m->objcImp release];
    }

    void CppAVFoundationCamera::start()
    {
        [_m->objcImp->session startRunning];
    }

    void CppAVFoundationCamera::stop()
    {
        [_m->objcImp->session stopRunning];
    }

}