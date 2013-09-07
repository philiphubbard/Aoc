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
// CppCIDetector.mm
//
// Note that the code in this file is Objective-C++, mixing both Objective-C
// and C++.
//

#include "AocCppCIDetector.h"

#include <sys/types.h>
#include <sys/times.h>

#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

namespace Aoc
{

    // The implementation class for the C++ class providing the public interface.
    // This class is actually Objective-C++ so it can use an instance of the
    // Objective-C CIDetector.

    class CppCIDetector::Imp
    {
    public:
        Imp() : detector(0), pool(0) {}
        CIDetector*        detector;
        NSAutoreleasePool* pool;
    };

    CppCIDetector::CppCIDetector(WhichThread whichThread) :
        _m(new Imp)
    {

        if (whichThread == WorkerThread)
            _m->pool = [[NSAutoreleasePool alloc] init];

        NSDictionary* options = @{CIDetectorTracking:@(YES),
                                  CIDetectorAccuracy:CIDetectorAccuracyHigh};
        
        // Created by a class method, so goes in the autorelease pool.

        _m->detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil
                                          options:options];
    }

    CppCIDetector::~CppCIDetector()
    {
        [_m->pool release];
    }

    bool CppCIDetector::detect(CGImageRef cgImage,
                               std::vector<Face>& result)
    {
        CIImage* ciImage = [CIImage imageWithCGImage:cgImage];

        assert(_m->detector);
        assert (ciImage);
        
         @autoreleasepool {
             NSArray *faces = [_m->detector featuresInImage:ciImage];
            
            for (CIFaceFeature *face in faces)
            {
                CGRect rect = face.bounds;
                result.push_back(Face(rect.origin.x, rect.origin.y,
                                      rect.size.width, rect.size.height));
            }
        }
         
        return (!result.empty());
    }

}