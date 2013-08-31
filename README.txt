Aoc: An Objective-C-in-C++ Library
By Philip M. Hubbard, 2013


Overview

Aoc is a library for using some of Apple's Objective-C libraries with C++ code.  The Objective-C functionality supported includes access to a computer's video camera, tracking of faces in video images, and rendering with OpenGL in an application window.  While the library was designed to be relatively general, it was implemented to meet the needs of the Facetious application.


Implementation

Aoc::CppAVFoundationCamera is a C++ class that maintains an instance of the Objective-C AVFoundationCamera class, which accesses a computer's video camera.  Clients use Aoc::CppAVFoundationCamera as a base class, with a derived class redefining a virtual function that gets called with a CGImageRef for each captured frame of video.  The Objective-C code allocates some memory that must be managed by an autorelease pool; the main thread of a Cocoa application will have such a pool, but if the Aoc::CppAVFoundationCamera instance is owned by another thread, the instance can create its own pool if specified by an argument to its constructor.

Aoc::CppCIDetector is a C++ class that maintains an instance of the Objective-C CIDetector class, which detects human faces in images.  Its function to perform detection takes a CGImageRef and fills a vector with Aoc::CppCIDetector::Face instances, each specifying the rectangular region for a detected face.  Since CIDetector can take a relatively long time to perform detection, it makes sense to use Aoc::CppCIDetector in a worker thread instead of the main application thread; the Aoc::CppCIDetector constructor thus has an argument to specify that it should create its own Objective-C autorelease pool, as discussed above for Aoc::CppAVFoundationCamera.

AocNSOpenGLView is an Objective-C class that derives from NSOpenGLView, the main class for displaying OpenGL renderings in a Cocoa application.  So that the code to generate the rendering can be written in C++, AocNSOpenGLView delegates redraw and resizing operations to an instance of the C++ class Aoc::CppNSOpenGLBase.  This class serves as a base class, with a derived class adding custom OpenGL-related behaviors by redefining virtual functions.  Aoc::CppNSOpenGLBase also has virtual functions that the derived class can redefine for event handling, like processing key presses.  Since this event processing may require redrawing, the derived class is given an instance of the Aoc::CppNSOpenGLRequester class, whose API includes a function for requesting a redraw.

Although AocNSOpenGLView's implementation calls C++ code via Aoc::CppNSOpenGLBase, its external API is pure Objective-C, so it can be used in an Objective-C Cocoa application.  A bit of indirection is needed, therefore, to get AocNSOpenGLView to create an instance of a particular C++ class derived from Aoc::CppNSOpenGLBase.  Aoc::CppNSOpenGLBase has a static function, setCreator(...), which takes the function AocNSOpenGLView will call to create the instance of the C++ class derived from Aoc::CppNSOpenGLBase.  This static function can be called from a helper function which appears to be pure C code to the Objective-C application's AppDelegate instance.  For example, say that the C++ class derived from Aoc::CppNSOpenGLBase is MyAppOpenGL defined in MyAppOpenGL.{h,cpp}.  The pure C function can be defined in MyAppInit.{h,cpp} and used by the AppDelegate as follows:

  MyAppOpenGL.h:

    #include "Aoc/AocCppNSOpenGLBase.h"

    class MyAppOpenGL : public Aoc::CppNSOpenGLBase { ... };

  MyAppInit.h:

    // Note that this file is very simple, so it can be imported as
    // valid Objective-C code in addition to being included as
    // valid C++ code.
    void myAppInit();

  MyAppInit.cpp:

    #include "MyAppOpenGL.h"

    Aoc::CppNSOpenGLBase* myAppCreator(Aoc::CppNSOpenGLRequestor* r)
    { return new MyAppOpenGL(r); }

    // Note the specification that this function is plain C, so it
    // can be called by Objective-C code.
    extern "C" void myAppInit()
    { Aoc::CppNSOpenGLBase::setCreator(myAppCreator); }

  AppDelegate.m:

    import "MyAppInit.h"

    - (void)applicationDidFinishLaunching:(NSNotification *)aNotification
    { myAppInit(); ... }



Building

Since Aoc is designed to work with Cocoa libraries, it requires an Apple OS X platform.  It uses the following frameworks: ApplicationServices.framework, AVFoundation.framework, CoreMedia.framework, OpenGL.framework, QuartzCore.framework.  Aoc also requires a compiler that supports Objective-C++ in addition to Objective-C and C++.  The particular version of Xcode used for Facetious development was 4.6.3.

Aoc also depends on Aut, A Utility Toolkit, which has some error-reporting API that AocNSOpenGLView sets up to display messages with the NSAlert class.

The Xcode project build settings assume that all code---Aoc, Aut and any other projects used by an application---are siblings at the same level in the directory hierarchy.  In the "Build Settings," the "Header Search Paths" is set to "$(SRCROOT)/..", allowing source code to have include statements like the following:

	#include "Aoc/AocCppAVFoundationCamera.h"


Future Work

* Aoc::CppAVFoundationCamera should have API to control the options for AVFoundationCamera.
* Aoc::CppAVFoundationCamera's code for converting the video image to a CGImageRef may not be as efficient as it could be (although it did not appear to be a problem in profiling of the Facetious application).
* Aoc::CppAVFoundationCamera should have better error handling for cases like dropped frames.
* Aoc::CppCIDetector should have API to control the options for CIDetector.
* Aoc::CppNSOpenGLBase should have virtual functions for a more complete set of events, beyond key presses.

