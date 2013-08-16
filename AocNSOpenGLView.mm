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
//  AocNSOpenGLView.mm
//

#import "AocNSOpenGLView.h"
#include "AocCppNSOpenGLBase.h"
#include "Aut/AutAlert.h"
#include <map>

//

namespace {

    static std::map<Aoc::CppNSOpenGLRequester*, AocNSOpenGLView*> requesterToView;
    
    void warningFunction(const std::string& txt)
    {
        NSString *text = [[NSString alloc] initWithUTF8String:txt.c_str()];
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Warning"];
        [alert setInformativeText:text];
        
        [alert runModal];
        
        [text release];
        [alert release];
    }

    void errorFunction(const std::string& txt)
    {
        NSString *text = [[NSString alloc] initWithUTF8String:txt.c_str()];
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:text];
        
        [alert runModal];
        
        [text release];
        [alert release];
    }
    
    void fatalErrorFunction(const std::string& txt)
    {
        NSString *text = [[NSString alloc] initWithUTF8String:txt.c_str()];
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Fatal Error"];
        [alert setInformativeText:text];
        [alert setAlertStyle:NSCriticalAlertStyle];
        
        [alert runModal];
        
        [text release];
        [alert release];
        
        abort();
    }
}

namespace Aoc
{
    
    CppNSOpenGLRequester::CppNSOpenGLRequester()
    {
    }

    CppNSOpenGLRequester::~CppNSOpenGLRequester()
    {
        requesterToView.erase(this);
    }

    void CppNSOpenGLRequester::redraw()
    {
        @autoreleasepool {
            AocNSOpenGLView* view = requesterToView[this];
            [view setNeedsDisplay:YES];
        }
    }
    
}


// Class extension for the C++ data member, keeping it out of the Objective-C header file.

@interface AocNSOpenGLView () {

    Aoc::CppNSOpenGLBase* cppBase;

}

@end

//

@implementation AocNSOpenGLView

- (void)dealloc
{
    delete cppBase;
    [super dealloc];
}

// Defined in NSResponder, which NSView conforms to.

- (BOOL)acceptsFirstResponder
{
    return YES;
}

// Defined in NSResponder, which NSView conforms to.

- (void)keyDown:(NSEvent *)theEvent
{
    char c = 0;
    Aoc::CppNSOpenGLBase::KeyEvent::SpecialCharacter sc = Aoc::CppNSOpenGLBase::KeyEvent::None;
    
    NSString* s = [theEvent characters];
    if ([s length] > 0)
    {
        c = [s UTF8String][0];
       switch([s characterAtIndex:0])
        {
            case NSLeftArrowFunctionKey:
                sc = Aoc::CppNSOpenGLBase::KeyEvent::LeftArrow;
                break;
            case NSRightArrowFunctionKey:
                sc = Aoc::CppNSOpenGLBase::KeyEvent::RightArrow;
                break;
            case NSUpArrowFunctionKey:
                sc = Aoc::CppNSOpenGLBase::KeyEvent::UpArrow;
                break;
            case NSDownArrowFunctionKey:
                sc = Aoc::CppNSOpenGLBase::KeyEvent::DownArrow;
                break;
        }
    }
    
    Aoc::CppNSOpenGLBase::KeyEvent keyEvent(c, sc);
    cppBase->keyDown(keyEvent);
}

// Defined in NSView, a base class for NSOpenGLView.

- (id)initWithFrame:(NSRect)frame
{
    // Create a pixel format specifying OpenGL version 3.2, and
    // GLSL version 1.50.
    
    NSOpenGLPixelFormatAttribute pixelFormatAttributes[] =
    {
        // Note that when using the profile for OpenGL version 3.2, it is
        // important to use the OpenGL/gl3.h header instead of the OpenGL/gl.h
        // header (and thus the versions of glGenVertexArray and
        // glBindVertexArray without the APPLE extension).
        
        NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
        NSOpenGLPFAColorSize    , 24                           ,
        NSOpenGLPFAAlphaSize    , 8                            ,
        NSOpenGLPFADepthSize    , 32                           ,
        NSOpenGLPFADoubleBuffer ,
        NSOpenGLPFAAccelerated  ,
        NSOpenGLPFANoRecovery   ,
        0
    };
    
    NSOpenGLPixelFormat *pixelFormat = [[[NSOpenGLPixelFormat alloc] initWithAttributes:pixelFormatAttributes]
                                        autorelease];

    // Initialize the superclass NSOpenGLView with the pixel format.
    
    self = [super initWithFrame:frame pixelFormat:pixelFormat];

    if (self)
    {
        if (!Aut::warningFunction())
            Aut::setWarningFunction(warningFunction);
        if (!Aut::errorFunction()) 
            Aut::setErrorFunction(errorFunction);
        if (!Aut::fatalErrorFunction())
            Aut::setFatalErrorFunction(fatalErrorFunction);
        
        Aoc::CppNSOpenGLRequester* requester = new Aoc::CppNSOpenGLRequester;
        requesterToView[requester] = self;
        
        cppBase = Aoc::CppNSOpenGLBase::create(requester);
        if (!cppBase)
            self = nil;
    }
    
    return self;
}

// Defined in NSOpenGLView.
// Called only once after the OpenGL context is made the current context.
// Subclasses that implement this method can use it to configure the Open GL state in preparation for drawing.

- (void)prepareOpenGL
{
    // Subclass initialization code goes here.
    
    NSLog(@"glGetString(GL_VERSION) = \"%s\"\n", glGetString(GL_VERSION));
    NSLog(@"glGetString(GL_SHADING_LANGUAGE_VERSION) = \"%s\"\n", glGetString(GL_SHADING_LANGUAGE_VERSION));
    
    cppBase->init();
}

// Defined in NSOpenGLView.

- (void)reshape
{
    [super reshape];
    
    NSRect rect = [self bounds];
    cppBase->reshape(int(rect.size.width), int(rect.size.height));
}

// Defined in NSView, a base class for NSOpenGLView.
// Overridden in a subclass to draw the receivers image within the argument rectangle.

- (void)drawRect:(NSRect)dirtyRect
{
    // Subclass drawing code goes here.

    cppBase->draw();
    
    [[self openGLContext] flushBuffer];
    
}

@end
