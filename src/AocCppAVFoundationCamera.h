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
// AocCppAVFoundationCamera.h
//
// A C++ base class giving access to the Objective-C AVFoundationCamera class,
// which accesses a computer's video camera.  A derived class should redefine
// the virtual function to get video frames.
//
// Requires the following linked frameworks and libraries:
// AVFoundation.framework
// QuartzCore.framework
// ApplicationServices.framework

#ifndef __AocCppAVFoundationCamera__
#define __AocCppAVFoundationCamera__

#include <ImageIO/CGImageSource.h>
#include <memory>

namespace Aoc
{
    
    class CppAVFoundationCamera
    {
    public:
        
        // If the instance is specified as being allocated in a worker thread,
        // then it will have its own Objective-C autorelease pool.
        
        enum WhichThread { MainThread, WorkerThread };
        
        CppAVFoundationCamera(WhichThread = MainThread);
        ~CppAVFoundationCamera();
        
        // Control whether the camera if active or not.
        
        void            start();
        void            stop();
        
        // A derived class should redefine this virtual function,
        // which gets called with each captured video frame.
        
        virtual void    handleCapturedImage (CGImageRef) = 0;
        
    private:
        
        // Details of the class' data are hidden in the .cpp file.
        
        class Imp;
        std::unique_ptr<Imp> _m;
    };
    
}

#endif
