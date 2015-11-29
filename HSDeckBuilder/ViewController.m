//
//  ViewController.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "ViewController.h"
#import "ImportFromWebVC.h"
#import "ExportVC.h"

@interface ViewController () <ExportVCDelegate>
@property (weak) IBOutlet NSButton *importBtn;
@property (weak) IBOutlet NSButton *exportDeckBtn;
@property (weak) IBOutlet NSArrayController *cardArrayController;
@property (weak) IBOutlet NSTableView *cardTable;
@property (weak) IBOutlet NSTextField *tableTitleLabel;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    // OMG!!! SETTING BACKGROUND COLOR IS SO DAMN HARD!!!
//    [self.view setWantsLayer:YES];
//    [self.view.layer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.4)];
    
#if DEBUG
    // clear all data
//    [Deck deleteDefaultDeck];
#endif
    
    Deck *loadedDeck = [Deck loadDefaultDeck];
//    NSLog(@"loadedDeck: %@", loadedDeck);
    self.selectedDeck = loadedDeck;
}

- (void)setSelectedDeck:(Deck *)selectedDeck {
    _selectedDeck = selectedDeck;
    
    NSString *yourDeckStr = @"";
    if (selectedDeck.cardCount > 0) {
        // has deck
        yourDeckStr = [NSString stringWithFormat:@"Your deck: (%lu cards)", (unsigned long)selectedDeck.cardCount];
        //self.exportDeckBtn.highlighted = true;
        //[self.exportDeckBtn setKeyEquivalent:@"\r"];
    }
    else {
        // no deck
        //[self.exportDeckBtn setKeyEquivalent:nil];
    }
    self.tableTitleLabel.stringValue = yourDeckStr;
    
    //[self.cardArrayController setContent:@[@{@"name":@"haha", @"count": @2}]];
    [self.cardArrayController setContent:selectedDeck.contentForArrayController];
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

#pragma mark - buttons and segue

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"import"]) {
        ImportFromWebVC *vc = segue.destinationController;
        vc.mainVC = self;
    }
    else if ([segue.identifier isEqualToString:@"export"]) {
        ExportVC *vc = segue.destinationController;
        vc.delegate = self;
    }
}

- (IBAction)onDonate:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=thongchaikol%40gmail%2ecom&lc=US&item_name=HSDeckBuilder"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)onHelpBtn:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://github.com/hlung/Hearthstone-Deck-Builder/blob/master/README.md#hearthstone-deck-builder"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

//- (CGPoint)mousePointFromScreenPoint:(CGPoint)sp {
//    return CGPointMake(sp.x, theScreen.frame.size.height - sp.y);
//}

#pragma mark - ExportVCDelegate

- (void)exportVC:(ExportVC*)vc processingCardIndex:(NSInteger)index {
    Card *c = self.selectedDeck.cards[index];
    if (c) {
        NSLog(@"card: %@", c.name);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        [self.cardTable selectRowIndexes:indexSet byExtendingSelection:false];
    }
}

@end
