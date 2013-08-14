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
//  AocCppNSOpenGLBase.h
//
//  Created by Philip on 6/21/13.
//  Copyright (c) 2013 Philip. All rights reserved.
//

#ifndef __CppNSOpenGLBase__
#define __CppNSOpenglBase__

#include <iostream>

//

namespace Aoc
{
    
    class CppNSOpenGLRequester;
    
    class CppNSOpenGLBase
    {
    public:
#if 1
        // HEY!!
        
        // In an application using AocNSOpenGLView, the static Aoc::CppNSOpengGLBase::setCreator()
        // function must called, with its argument being a function that will return an instance
        // of a class derived from the C++ Aoc::CppNSOpenGLBase class.  If setCreator() is not
        // called, AocNSOpenGLView will generate a fatal error.

        static CppNSOpenGLBase* create(CppNSOpenGLRequester*);
        static void             setCreator(std::function<CppNSOpenGLBase*
                                           (CppNSOpenGLRequester*)> creator);
#endif
        
        CppNSOpenGLBase();
        virtual ~CppNSOpenGLBase();
        
        virtual void init();
        virtual void reshape(int width, int height);
        
        // The derived class routine does not need to call glFlush or anything
        // similar, because the associated NSOpenGLView will call flushBuffer on
        // its OpenGLContext.
        
        virtual void draw();
        
        class KeyEvent
        {
        public:
            enum SpecialCharacter { None, LeftArrow, RightArrow, UpArrow, DownArrow };
            
            KeyEvent (char c = 0, SpecialCharacter sc = None) : character(c), special(sc) {}
            
            char                character;
            SpecialCharacter    special;        
        };
        
        virtual void keyDown (KeyEvent keyEvent);
    };

    //

    class CppNSOpenGLRequester
    {
    public:
        CppNSOpenGLRequester();
        ~CppNSOpenGLRequester();
        void redraw();
    };
    
}

#endif
