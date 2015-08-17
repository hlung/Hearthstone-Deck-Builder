//
//  ImportFromWebVC.m
//  HSDeckBuilder
//
//  Created by Hlung on 16/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "ImportFromWebVC.h"

#import "RegExCategories.h"
#import "TKHSDeckImporter.h"

@interface ImportFromWebVC ()
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSTextField *statusLabel;

@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (weak) IBOutlet NSButton *importBtn;
@property (weak) IBOutlet NSButton *cancelBtn;
@end

@implementation ImportFromWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    if (self.mainVC.selectedDeck) {
        self.urlTextField.stringValue = self.mainVC.selectedDeck.generatedFromURL;
    }
    
    [self.importBtn setKeyEquivalent:@"\r"];
    
#if DEBUG
//    self.urlTextField.stringValue = @"http://www.hearthpwn.com/decks/224656-senfglas-1-legend-grim-patron-warrior";
    
//    self.urlTextField.stringValue = @"http://www.hearthpwn.com/decks/279780-kolento-combo-priest";
#endif
}

- (IBAction)onImportBtn:(id)sender {
    
    NSString *urlString = self.urlTextField.stringValue;
    //NSURL *url = [NSURL URLWithString:urlString];
    
    [self.indicator startAnimation:nil];
    self.statusLabel.stringValue = @"Downloading...";
    self.importBtn.enabled = self.cancelBtn.enabled = false;
    
    [TKHSDeckImporter
     importDeckFromURL:urlString
     success:^(Deck *deck) {
         
         deck.generatedFromURL = urlString;
         [self.indicator stopAnimation:nil];
         NSString *str = [NSString stringWithFormat:@"Download Completed"];
         //NSString *str = [NSString stringWithFormat:@"Download Completed, got %ld cards", (long)[deck cardCount]];
         self.statusLabel.stringValue = str;
         
         // pass deck back
         self.mainVC.selectedDeck = deck;
         
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
             [self dismissViewController:self];
         });
         
     } fail:^(NSString *error) {
         
         [self.indicator stopAnimation:nil];
         self.statusLabel.stringValue = error;
         self.importBtn.enabled = self.cancelBtn.enabled = true;
     }];

}

@end
