//
//  AppDelegate.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong, nonatomic) NSWindow *myWindow;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    // Reopen window when dock icon is clicked after closing by red button.
    // Note: mainWindow is not nil at this point,
    // so need to get the window from the list of all windows
    NSWindow *window = [[[NSApplication sharedApplication] windows] objectAtIndex:0];
    [window makeKeyAndOrderFront:self];
    return YES;
}

@end
