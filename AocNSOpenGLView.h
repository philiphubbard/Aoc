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
//  AocNSOpenGLView.h
//

// Requires the following linked frameworks and libraries:
// OpenGL.framework
// AppKit.framework


#import <Cocoa/Cocoa.h>

// Assumes that another unit defines the following C++ function:
// Aoc::CppNSOpenGLBase* createAocCppNSOpenGL();
// This function hould allocate and return a class derived from Aoc::CppNSOpenGLBase
// that implementsthe virtual functions from that class.

@interface AocNSOpenGLView : NSOpenGLView

- (BOOL)acceptsFirstResponder;

- (void)keyDown:(NSEvent *)theEvent;

@end
