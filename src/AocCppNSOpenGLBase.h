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
// AocCppNSOpenGLBase.h
//
// CppNSOpenGLBase: A C++ base class for the OpenGL rendering functionality of an
// Objective-C AocNSOpenGLView.  Create a derived class to add specific OpenGL
// functionality.
//
// CppNSOpenGLRequester: Used by the class derived from CppNSOpenGLBase to request
// a redraw of the AocNSOpenGLView (e.g., after processing a keyboard event).
//

#ifndef __CppNSOpenGLBase__
#define __CppNSOpenGLBase__

#include <iostream>

namespace Aoc
{
    
    class CppNSOpenGLRequester;
    
    //
    
    class CppNSOpenGLBase
    {
    public:

        // In an application using AocNSOpenGLView, the static
        // Aoc::CppNSOpengGLBase::setCreator() function must called, with its
        // argument being a function that will return an instance of a class
        // derived from the C++ Aoc::CppNSOpenGLBase class.  If setCreator()
        // is not called, AocNSOpenGLView will generate a fatal error.
        // See the README file for an example of how to call this function in
        // an Objective-C application.

        static CppNSOpenGLBase* create(CppNSOpenGLRequester*);
        static void             setCreator(std::function<CppNSOpenGLBase*
                                           (CppNSOpenGLRequester*)> creator);
        
        CppNSOpenGLBase();
        virtual ~CppNSOpenGLBase();
        
        // A derived class should redefine this virtual function to perform
        // OpenGL initialization.
        
        virtual void init();
        
        // A derived class should redefine this virtual function to handle the
        // resizing of the view.
        
        virtual void reshape(int width, int height);
        
        // A derived class should redefine this virtual function to handle the
        // OpenGL rendering in the view.  Note that the derived class' routine
        // does not need to call call glFlush or anything similar, because the
        // associated NSOpenGLView will call flushBuffer on its OpenGLContext.
        
        virtual void draw();
        
        // A keyboard event. Used to avoid any dependency on specific Cocoa
        // key codes.
        
        class KeyEvent
        {
        public:
            
            enum SpecialCharacter { None, LeftArrow, RightArrow, UpArrow, DownArrow };
            
            KeyEvent (char c = 0, SpecialCharacter sc = None) : _character(c), _special(sc) {}
            
            // The ASCII character for the key in the event, if it is not one of the
            // special caracters.
            
            char                character() const { return _character; }
            
            // The enum value if the key in the event is a special character, or None
            // otherwise.
            
            SpecialCharacter    special() const { return _special; }
            
        private:
            
            char                _character;
            SpecialCharacter    _special;
        };
        
        // A derived class should redefine this virtual function to handle a key press.
        
        virtual void keyDown (KeyEvent keyEvent);
    };

    //

    class CppNSOpenGLRequester
    {
    public:

        CppNSOpenGLRequester();
        ~CppNSOpenGLRequester();
        
        // Request a redraw.
        
        void redraw();
    };
    
}

#endif
