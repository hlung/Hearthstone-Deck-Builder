//
//  TKWindowUtils.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "TKWindowUtils.h"
#include <CoreFoundation/CoreFoundation.h>
#import "TKKeyCodeHelper.h"

@implementation TKWindowListApplierData

- (instancetype)initWindowListData:(NSMutableArray *)array {
    self = [super init];
    self.outputArray = array;
    self.order = 0;
    return self;
}

@end


@implementation TKWindowUtils

#pragma mark Basic Profiling Tools
// Set to 1 to enable basic profiling. Profiling information is logged to console.
#ifndef PROFILE_WINDOW_GRAB
#define PROFILE_WINDOW_GRAB 0
#endif

#if PROFILE_WINDOW_GRAB
#define StopwatchStart() AbsoluteTime start = UpTime()
#define Profile(img) CFRelease(CGDataProviderCopyData(CGImageGetDataProvider(img)))
#define StopwatchEnd(caption) do { Duration time = AbsoluteDeltaToDuration(UpTime(), start); double timef = time < 0 ? time / -1000000.0 : time / 1000.0; NSLog(@"%s Time Taken: %f seconds", caption, timef); } while(0)
#else
#define StopwatchStart()
#define Profile(img)
#define StopwatchEnd(caption)
#endif

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark Window List Methods

NSString *kAppNameKey = @"applicationName";	// Application Name & PID
NSString *kWindowBoundsKey = @"windowBounds"; // Window bounds as NSValue of NSRect
NSString *kWindowIDKey = @"windowID";		// Window ID
NSString *kWindowLevelKey = @"windowLevel";	// Window Level
NSString *kWindowOrderKey = @"windowOrder";	// The overall front-to-back ordering of the windows as returned by the window server

void WindowListApplierFunction(const void *inputDictionary, void *context);
void WindowListApplierFunction(const void *inputDictionary, void *context)
{
    NSDictionary *entry = (__bridge NSDictionary*)inputDictionary;
    TKWindowListApplierData *data = (__bridge TKWindowListApplierData*)context;
    
    // The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
    // However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
    int sharingState = [entry[(id)kCGWindowSharingState] intValue];
    if(sharingState != kCGWindowSharingNone)
    {
        NSMutableDictionary *outputEntry = [NSMutableDictionary dictionary];
        
        // Grab the application name, but since it's optional we need to check before we can use it.
        NSString *applicationName = entry[(id)kCGWindowOwnerName];
        if(applicationName != NULL)
        {
            // PID is required so we assume it's present.
            NSString *nameAndPID = [NSString stringWithFormat:@"%@ (%@)", applicationName, entry[(id)kCGWindowOwnerPID]];
            outputEntry[kAppNameKey] = nameAndPID;
        }
        else
        {
            // The application name was not provided, so we use a fake application name to designate this.
            // PID is required so we assume it's present.
            NSString *nameAndPID = [NSString stringWithFormat:@"((unknown)) (%@)", entry[(id)kCGWindowOwnerPID]];
            outputEntry[kAppNameKey] = nameAndPID;
        }
        
        // Grab the Window Bounds, it's a dictionary in the array, but we want to display it as a string
        CGRect bounds;
        CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)entry[(id)kCGWindowBounds], &bounds);
        outputEntry[kWindowBoundsKey] = [NSValue valueWithRect:bounds];
        
        // Grab the Window ID & Window Level. Both are required, so just copy from one to the other
        outputEntry[kWindowIDKey] = entry[(id)kCGWindowNumber];
        outputEntry[kWindowLevelKey] = entry[(id)kCGWindowLayer];
        
        // Finally, we are passed the windows in order from front to back by the window server
        // Should the user sort the window list we want to retain that order so that screen shots
        // look correct no matter what selection they make, or what order the items are in. We do this
        // by maintaining a window order key that we'll apply later.
        outputEntry[kWindowOrderKey] = @(data.order);
        data.order++;
        
        [data.outputArray addObject:outputEntry];
    }
}

- (NSRect)getAppWindowBoundsOfRunningApplication:(NSRunningApplication*)app {
    
    // process inputs
    NSString *pid = [NSString stringWithFormat:@"%d", app.processIdentifier];
    CGWindowListOption listOptions = kCGWindowListOptionAll;
    
    // Ask the window server for the list of windows.
    StopwatchStart();
    CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
    StopwatchEnd("Create Window List");
    
    // Copy the returned list, further pruned, to another list. This also adds some bookkeeping
    // information to the list as well as
    NSMutableArray * prunedWindowList = [NSMutableArray array];
    self.windowListData = [[TKWindowListApplierData alloc] initWindowListData:prunedWindowList];
    
    CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, (__bridge void *)(self.windowListData));
    CFRelease(windowList);
    
    // prunedWindowList is an array of NSDictionary
    /*
         applicationName = "Hearthstone (4415)";
         windowID = 10512;
         windowLevel = 0;
         windowOrder = 5;
         windowOrigin = "189/50"; // "0/0";
         windowSize = "855*664";  // "1280*22";
     */
//    NSLog(@"prunedWindowList %@", prunedWindowList);
    
    // add open parenthesis to mark the start of process id
    NSString *appPIDSuffix = [NSString stringWithFormat:@"%@)", pid];
    
    for (NSDictionary *d in prunedWindowList) {
        NSString *applicationName = d[@"applicationName"];
        NSRect windowBounds = [(NSValue *)d[@"windowBounds"] rectValue];
        
        // somehow there are other windows with same application name,
        // having (0,0) or (1,1) or (1280, 22) sizes, so we have to filter them
        if ([applicationName hasSuffix:appPIDSuffix] &&
            windowBounds.size.width > 22 && windowBounds.size.height > 22) {
//            NSLog(@"windowBounds %@", NSStringFromRect(windowBounds));
            return windowBounds;
        }
    }
    
    return NSMakeRect(0, 0, 0, 0);
}

#pragma mark - Mouse & Keyboard Events

- (void)postEventMouseLeftClickAtPoint:(CGPoint)pt {
    CGEventRef mouseDownEv = CGEventCreateMouseEvent(NULL,kCGEventLeftMouseDown,pt,kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mouseDownEv);
    CFRelease(mouseDownEv);
    CGEventRef mouseUpEv = CGEventCreateMouseEvent(NULL,kCGEventLeftMouseUp,pt,kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mouseUpEv );
    CFRelease(mouseUpEv);
}

- (void)postEventMouseMoveToPoint:(CGPoint)pt {
    CGEventRef mouseUpEv = CGEventCreateMouseEvent(NULL,kCGEventMouseMoved,pt,kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mouseUpEv );
    CFRelease(mouseUpEv);
}

- (void)postEventKeyboardTypeKeyCode:(CGKeyCode)keyCode {
    CGEventRef eventDown = CGEventCreateKeyboardEvent(NULL, keyCode, true);
    CGEventPost(kCGHIDEventTap, eventDown);
    CFRelease(eventDown);
    CGEventRef eventUp = CGEventCreateKeyboardEvent(NULL, keyCode, false);
    CGEventPost(kCGHIDEventTap, eventUp);
    CFRelease(eventUp);
    //NSLog(@"keyCode: %d", keyCode);
}

const useconds_t kStringTypingDelay = 0.01 * 1000000;

- (void)postEventKeyboardTypeWithString:(NSString*)str {
//    CGKeyCode keyCode = [TKKeyCodeHelper keyCodeFormChar:'h']; // 38
    printf("typing key codes:");
    
    NSArray *arr = [TKKeyCodeHelper keyCodesFormString:str];
    for (NSNumber *keyCodeNum in arr) {
        CGKeyCode keyCode = [keyCodeNum unsignedShortValue];
        printf(" %d", keyCode);
        [self postEventKeyboardTypeKeyCode:keyCode];
        usleep(kStringTypingDelay);
    }
    printf("\n");
}

@end
