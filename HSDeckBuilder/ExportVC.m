//
//  ExportVC.m
//  HSDeckBuilder
//
//  Created by Hlung on 22/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "ExportVC.h"
#import "TKWindowUtils.h"
#import "SGHotKey.h"
#import "SGHotKeyCenter.h"
#import "Deck.h"

@interface ExportVC ()
@property (assign, nonatomic) float delaySpeedAdjust;
@property (assign, nonatomic) BOOL shouldCancelExportToHearthstone;
@property (strong, nonatomic) SGHotKey *escHotKey;
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSTextField *subtitleLabel;
@end

@implementation ExportVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delaySpeedAdjust = 1.2f;
    [self setupHotkeys];
    self.subtitleLabel.stringValue = @"Starting...";
    [self.indicator startAnimation:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self onExportToHearthstone];
    });
}

- (void)delay:(float)sec {
    usleep(sec * USEC_PER_SEC * self.delaySpeedAdjust);
}

- (void)setupHotkeys {
    self.escHotKey = [[SGHotKey alloc]
                      initWithIdentifier:@"esc"
                      keyCombo:[[SGKeyCombo alloc] initWithKeyCode:53 modifiers:1]
                      target:self
                      action:@selector(onEsc:)];
}

- (void)onEsc:(SGHotKey*)hotkey {
    NSLog(@"ESC");
    self.subtitleLabel.stringValue = @"Canceling...";
    self.shouldCancelExportToHearthstone = true;
}

- (void)onExportToHearthstone {
    
    // --- check game is running ---
    // Note: use `[[NSWorkspace sharedWorkspace] runningApplications]` to see app bundle IDs
    NSString *hsAppBundleID = @"unity.Blizzard Entertainment.Hearthstone";
    //    NSString *hsAppBundleID = @"com.apple.TextEdit";
    //NSString *hsAppBundleID = @"com.sublimetext.2";
    
    // try to bring Hearthstone window to front
    NSRunningApplication *hsApp = [[NSRunningApplication runningApplicationsWithBundleIdentifier:hsAppBundleID] firstObject];
    if ([hsApp activateWithOptions:NSApplicationActivateAllWindows] == false) {
        [self showAlert:@"Hearthstone is not running!"];
        return;
    }
    
    [self delay:1]; // wait for activate
    
    // --- check window ---
    TKWindowUtils *winUtils = [[TKWindowUtils alloc] init];
    NSRect hsWindowRect = [winUtils getAppWindowBoundsOfRunningApplication:hsApp];
    NSLog(@"hsWindowRect %@", NSStringFromRect(hsWindowRect));
    if (hsWindowRect.size.height == 0) {
        [self showAlert:@"Hearthstone window not found!"];
        return;
    }
    
    // --- export ---
    [self startExportToHearthstone];
    // do in background to allow escHotKey to work
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        // Perform async operation
        [self doExportToHearthstoneInBackground:hsWindowRect];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update UI
            [self endExportToHearthstone];
            NSLog(@"DONE!");
        });
    });
}

- (void)doExportToHearthstoneInBackground:(NSRect)hsWindowRect {
    
    NSRect hsGameRect = [self hsGameRectFromWindowRect:hsWindowRect];
    NSPoint hsCardSerchBoxPoint = [self hsPointOfCardSearchBoxFromGameRect:hsGameRect];
    NSPoint hsResultCardPoint = [self hsPointOfCardResultFromGameRect:hsGameRect];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"hsGameRect %@", NSStringFromRect(hsGameRect));
        NSLog(@"hsCardSerchBoxPoint %@", NSStringFromPoint(hsCardSerchBoxPoint));
        NSLog(@"hsResultCardPoint %@", NSStringFromPoint(hsResultCardPoint));
    });
    
    TKWindowUtils *winUtils = [[TKWindowUtils alloc] init];
    //    [winUtils postEventMouseMoveToPoint:hsResultCardPoint];
    //    NSPoint testPoint = NSMakePoint(hsWindowRect.origin.x + 40,
    //                                    hsWindowRect.origin.y + 40);
    //    [winUtils postEventMouseLeftClickAtPoint:testPoint];
    
    // Load the deck again to access in this thread, because Realm objects can only be
    // accessed from the thread it is created. Otherwise Realm will throw an exception.
    Deck *deck = [Deck loadDefaultDeck];
    __block NSUInteger importedCardCount = 0;
    NSUInteger totalCardCount = deck.cardCount;
    for (Card *card in deck.cards) {
        
        if (self.shouldCancelExportToHearthstone) break; // cancel
        
        if ([self.delegate respondsToSelector:@selector(exportVC:processingCardIndex:)]) {
            NSInteger index = [deck.cards indexOfObject:card];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate exportVC:self processingCardIndex:index];
            });
        }
        
        // click search box
        [winUtils postEventMouseLeftClickAtPoint:hsCardSerchBoxPoint];
        [self delay:0.1];
        
        // enter card name
        [winUtils postEventKeyboardTypeWithString:card.name];
        [winUtils postEventKeyboardTypeKeyCode:TK_CGKeyCode_RETURN];
        [self delay:0.3];
        
        for (NSUInteger i = 0; i < card.count; i++) {
            
            if (self.shouldCancelExportToHearthstone) break; // cancel
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                // Update UI
                self.subtitleLabel.stringValue =
                [NSString stringWithFormat:@"%lu / %lu cards", ++importedCardCount, (unsigned long)totalCardCount];
            });
            
            // select card
            [winUtils postEventMouseLeftClickAtPoint:hsResultCardPoint];
            [self delay:0.2];
        }
    }
}

- (void)startExportToHearthstone {
    [[SGHotKeyCenter sharedCenter] registerHotKey:self.escHotKey];
    self.shouldCancelExportToHearthstone = false;
}

- (void)endExportToHearthstone {
    [[SGHotKeyCenter sharedCenter] unregisterHotKey:self.escHotKey];
    self.shouldCancelExportToHearthstone = false;
    [self dismissViewController:self];
}

#pragma mark - utilities

- (void)showAlert:(NSString*)string {
    [self dismissViewController:self];
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:string];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow
                  completionHandler:nil];
}

const NSSize HS_WINDOW_W_H_RATIO = {1024, 768};
- (NSRect)hsGameRectFromWindowRect:(NSRect)rect {
    NSSize newSize = NSSizeAspectFit(HS_WINDOW_W_H_RATIO, rect.size);
    return NSMakeRect(floorf(rect.origin.x + ((rect.size.width - newSize.width)/2)),
                      floorf(rect.origin.y + ((rect.size.height - newSize.height)/2)),
                      newSize.width,
                      newSize.height);
}

- (NSPoint)hsPointOfCardSearchBoxFromGameRect:(NSRect)gameRect {
    return NSMakePoint(gameRect.origin.x + gameRect.size.width * 0.5,
                       gameRect.origin.y + gameRect.size.height * 0.925);
}

- (NSPoint)hsPointOfCardResultFromGameRect:(NSRect)gameRect {
    return NSMakePoint(gameRect.origin.x + gameRect.size.width * 0.12,
                       gameRect.origin.y + gameRect.size.height * 0.3);
}

NSSize NSSizeAspectFit(NSSize aspectRatio, NSSize boundingSize) {
    float mW = boundingSize.width / aspectRatio.width;
    float mH = boundingSize.height / aspectRatio.height;
    if( mH < mW )
        boundingSize.width = boundingSize.height / aspectRatio.height * aspectRatio.width;
    else if( mW < mH )
        boundingSize.height = boundingSize.width / aspectRatio.width * aspectRatio.height;
    return boundingSize;
}

@end
