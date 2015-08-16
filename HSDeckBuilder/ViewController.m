//
//  ViewController.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "ViewController.h"
#import "NetEaseCardBuilderImporter.h"
#import "TKWindowUtils.h"
#import "RLMArray+TKHelper.h"

#import "RegExCategories.h"

@interface ViewController ()
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSTextField *statusLabel;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSButton *exportDeckBtn;

@property (weak) IBOutlet NSArrayController *cardArrayController;
@property (weak) IBOutlet NSTableView *cardTable;

@property (strong, nonatomic) Deck *selectedDeck;
@property (assign, nonatomic) float delaySpeedAdjust;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delaySpeedAdjust = 2.0f;
    
    Deck *loadedDeck = [self loadDefaultDeck];
//    NSLog(@"loadedDeck: %@", loadedDeck);
    
    if (loadedDeck) {
        self.urlTextField.stringValue = loadedDeck.generatedFromURL;
        self.statusLabel.stringValue = @"Previous deck loaded";
        self.selectedDeck = loadedDeck;
    }
}

- (void)setSelectedDeck:(Deck *)selectedDeck {
    _selectedDeck = selectedDeck;
    
    // setContent requires an array
//    NSMutableArray *m = [NSMutableArray array];
//    for (Card *c in selectedDeck.cards) {
//        [m addObject:c];
//    }
    
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


- (IBAction)onDownload:(id)sender {
    
//    NSString *urlString = @"http://www.hearthpwn.com/decks/224656-senfglas-1-legend-grim-patron-warrior";
    
    NSString *urlString = self.urlTextField.stringValue;
    //NSURL *url = [NSURL URLWithString:urlString];
    
    // hearthpwn.com
    if ([urlString isMatch:RX(@"hearthpwn.com/decks/")]) {
        
        NSString *dockerId = [urlString firstMatch:RX(@"(\\d+)")]; // get first number

        [self.indicator startAnimation:nil];
        self.statusLabel.stringValue = @"Downloading...";
        
        [NetEaseCardBuilderImporter
         importHearthPwnDockerWithId:dockerId //@"224656"
         success:^(Deck *deck) {
             
             deck.generatedFromURL = urlString;
             
             [self.indicator stopAnimation:nil];
             NSString *str = [NSString stringWithFormat:@"Download Completed"]; // [NSString stringWithFormat:@"Download Completed, got %ld cards", (long)[deck cardCount]];
             self.statusLabel.stringValue = str;
             
             self.selectedDeck = deck;
             [self saveDefaultDeck:deck];
             
         } fail:^(NSString *string) {
             [self.indicator stopAnimation:nil];
             self.statusLabel.stringValue = @"Download Failed";
             
         }];
    }
    else {
        self.statusLabel.stringValue = @"URL not supported :(";
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
//    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *customRealmPath = [documentsDirectory stringByAppendingPathComponent:@"example.realm"];
//    RLMRealm *realm = [RLMRealm realmWithPath:customRealmPath];
    
    RLMResults *d = [Deck allObjectsInRealm:realm];
    return [d firstObject];
//    return nil;
}

- (IBAction)onExportToHearthstone:(id)sender {
    
    // Note: run `[[NSWorkspace sharedWorkspace] runningApplications]` to see all running app bundle IDs
    NSString *hsAppBundleID = @"unity.Blizzard Entertainment.Hearthstone";
//    NSString *hsAppBundleID = @"com.apple.TextEdit";
    //NSString *hsAppBundleID = @"com.sublimetext.2";

    // try to bring Hearthstone window to front
    NSRunningApplication *hsApp = [[NSRunningApplication runningApplicationsWithBundleIdentifier:hsAppBundleID] firstObject];
    if ([hsApp activateWithOptions:NSApplicationActivateAllWindows] == false) {
        self.statusLabel.stringValue = @"Hearthstone is not running!";
        return;
    }
    
    [self delay:1]; // wait for activate
    
    TKWindowUtils *winUtils = [[TKWindowUtils alloc] init];
    NSRect hsWindowRect = [winUtils getAppWindowBoundsOfRunningApplication:hsApp];
    NSLog(@"hsWindowRect %@", NSStringFromRect(hsWindowRect));
    
    if (hsWindowRect.size.height == 0) {
        self.statusLabel.stringValue = @"Hearthstone is not running!";
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

#pragma mark - utilities

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
