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
// AocNSOpenGLView.h
//
// An Objective-C class, derived from NSOpenGLView, that allows C++ code to do the
// OpenGL rendering.  It does so by maintaining an instance of a class derived from
// the C++ Aoc::CppNSOpenGLBase class.
//
// In an application using AocNSOpenGLView, the static
// Aoc::CppNSOpengGLBase::setCreator() function must called, with its argument
// being a function that will return an instance of a class derived from the
// C++ Aoc::CppNSOpenGLBase class.  If setCreator() is not called,
// AocNSOpenGLView will generate a fatal error.  See the README file for an
// example of how to call this function in an Objective-C application.
//
// AocNSOpenGLView sets up the error-reporting API from the Aut library so that the
// results appear in NSAlert dialogs.
//
// Requires the following linked frameworks and libraries:
// OpenGL.framework
// AppKit.framework


#import <Cocoa/Cocoa.h>

@interface AocNSOpenGLView : NSOpenGLView

- (BOOL)acceptsFirstResponder;

- (void)keyDown:(NSEvent *)theEvent;

@end
