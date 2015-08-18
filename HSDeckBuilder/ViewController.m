//
//  ViewController.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "ViewController.h"

#import "TKWindowUtils.h"
#import "RLMArray+TKHelper.h"
#import "ImportFromWebVC.h"

@interface ViewController ()
@property (weak) IBOutlet NSButton *importBtn;
@property (weak) IBOutlet NSButton *exportDeckBtn;
@property (weak) IBOutlet NSArrayController *cardArrayController;
@property (weak) IBOutlet NSTableView *cardTable;
@property (weak) IBOutlet NSTextField *tableTitleLabel;
@property (assign, nonatomic) float delaySpeedAdjust;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delaySpeedAdjust = 1.0f;
    
    // OMG!!! SETTING BACKGROUND COLOR IS SO DAMN HARD!!!
//    [self.view setWantsLayer:YES];
//    [self.view.layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.4)];
    
#if DEBUG
    // clear all data
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
    }];
#endif
    
    Deck *loadedDeck = [self loadDefaultDeck];
//    Deck *loadedDeck = nil;
//    NSLog(@"loadedDeck: %@", loadedDeck);

    self.selectedDeck = loadedDeck;
}

- (void)setSelectedDeck:(Deck *)selectedDeck {
    _selectedDeck = selectedDeck;
    
    NSString *yourDeckStr = @"";
    if (selectedDeck.cardCount > 0) {
        yourDeckStr = [NSString stringWithFormat:@"Your deck: (%lu cards)", (unsigned long)selectedDeck.cardCount];
        [self saveDefaultDeck:selectedDeck];
    }
    self.tableTitleLabel.stringValue = yourDeckStr;
    
    [self.cardArrayController setContent:selectedDeck.cards.allObjects];
}

- (NSString *)documentsPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"import"]) {
        ImportFromWebVC *vc = segue.destinationController;
        vc.mainVC = self;
    }
}

- (void)saveDefaultDeck:(Deck*)deck {
    // Persist data
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
        [realm addObject:deck];
    }];
}

- (Deck*)loadDefaultDeck {
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *d = [Deck allObjectsInRealm:realm];
    return [d firstObject];
//    return nil;
}

#pragma mark - buttons

- (IBAction)onExportToHearthstone:(id)sender {
    
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
    
    TKWindowUtils *winUtils = [[TKWindowUtils alloc] init];
    NSRect hsWindowRect = [winUtils getAppWindowBoundsOfRunningApplication:hsApp];
    NSLog(@"hsWindowRect %@", NSStringFromRect(hsWindowRect));
    
    if (hsWindowRect.size.height == 0) {
        [self showAlert:@"Hearthstone window not found!"];
        return;
    }
    
//    NSPoint testPoint = NSMakePoint(hsWindowRect.origin.x + 40,
//                                    hsWindowRect.origin.y + 40);
//    [winUtils postEventMouseLeftClickAtPoint:testPoint];
    
    NSRect hsGameRect = [self hsGameRectFromWindowRect:hsWindowRect];
    NSLog(@"hsGameRect %@", NSStringFromRect(hsGameRect));
    
    NSPoint hsCardSerchBoxPoint = [self hsPointOfCardSearchBoxFromGameRect:hsGameRect];
    NSPoint hsResultCardPoint = [self hsPointOfCardResultFromGameRect:hsGameRect];
//    [winUtils postEventMouseMoveToPoint:hsResultCardPoint];
    
    for (Card *card in self.selectedDeck.cards) {
        [winUtils postEventMouseLeftClickAtPoint:hsCardSerchBoxPoint];
        [self delay:0.1]; // add delay so text box is fully focused
        [winUtils postEventKeyboardTypeWithString:card.name];
        [winUtils postEventKeyboardTypeKeyCode:TK_CGKeyCode_RETURN];
        [self delay:0.1];
        for (int i = 0; i < card.count; i++) {
            [winUtils postEventMouseLeftClickAtPoint:hsResultCardPoint];
            [self delay:0.2];
        }
        [self delay:0.2];
    }
    
    NSLog(@"DONE!");
}

- (IBAction)onDonate:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=thongchaikol%40gmail%2ecom&lc=US&item_name=HSDeckBuilder"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)onHelpBtn:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://github.com/hlung/Hearthstone-Deck-Builder/blob/master/README.md#hearthstone-deck-builder"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

#pragma mark - utilities

- (void)showAlert:(NSString*)string {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:string];
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].mainWindow
                  completionHandler:nil];
}

- (void)delay:(float)sec {
    usleep(sec * 1000000 * self.delaySpeedAdjust);
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

//- (CGPoint)mousePointFromScreenPoint:(CGPoint)sp {
//    return CGPointMake(sp.x, theScreen.frame.size.height - sp.y);
//}

@end
