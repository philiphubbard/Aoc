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
//  AocCppCIDetector.h
//

// Requires the following linked frameworks and libraries:
// CoreMedia.framework
// QuartzCore.framework

#ifndef __AocCppCIDetector__
#define __AocCppCIDetector__

#include <ImageIO/CGImageSource.h>
#include <vector>

namespace Aoc
{
    
    class CppCIDetector
    {
    public:
        // If the instance is allocated in a WorkerThread, then it
        // will have its own internal Objective-C autorelease pool.
        
        enum WhichThread { MainThread, WorkerThread };

        CppCIDetector(WhichThread = MainThread);
        ~CppCIDetector();
        
        class Face
        {
        public:
            Face (float x = 0, float y = 0, float w = 0, float h = 0) :
                _x(x), _y(y), _width(w), _height(h) {}
            float   x() const { return _x; }
            float   y() const { return _y; }
            float   width() const { return _width; }
            float   height() const { return _height; }
        private:
            float   _x;
            float   _y;
            float   _width;
            float   _height;
        };
        
        bool detect(CGImageRef, std::vector<Face>& result);
        
    private:
        class Imp;
        std::unique_ptr<Imp> _m;
    };

}

#endif