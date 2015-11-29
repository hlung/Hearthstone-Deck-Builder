//
//  Deck.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "Deck.h"
#import "NSUserDefaults+NSCoding.h"

NSString * const NSUserDefaultsKeyDeck = @"deck";
NSString * const NSUserDefaultsKeyDeckVersion = @"deck-version";
const NSInteger CurrentDeckVersion = 1; // increase this to delete old versions

@interface Deck ()

@end

@implementation Deck

+ (void)initialize {
    if (self == [Deck class]) {
        [self deleteDefaultDeckIfVersionIncreased];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cards = [NSMutableArray arrayWithCapacity:30];
    }
    return self;
}

- (void)setName:(NSString *)name {
    _name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setGeneratedFromURL:(NSString *)generatedFromURL {
    _generatedFromURL = [generatedFromURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSArray<NSDictionary *>*)contentForArrayController {
    NSMutableArray *m = [NSMutableArray array];
    for (Card *card in self.cards) {
        [m addObject:card.dictionaryValue];
    }
    return m;
}

- (NSUInteger)cardCount {
    NSUInteger count = 0;
    for (Card *card in self.cards) {
        count += card.count;
    }
    return count;
}

#pragma mark - NSUserDefaults

+ (Deck*)loadDefaultDeck {
    return [[NSUserDefaults standardUserDefaults]
            loadNSUserDefaultsObjectForKey:NSUserDefaultsKeyDeck
            unarchive:YES];
}

- (void)saveAsDefaultDeck {
    [[NSUserDefaults standardUserDefaults]
     saveNSUserDefaultsObject:self
     forKey:NSUserDefaultsKeyDeck
     archive:YES];
}

+ (void)deleteDefaultDeck {
    [[NSUserDefaults standardUserDefaults]
     saveNSUserDefaultsObject:nil
     forKey:NSUserDefaultsKeyDeck
     archive:YES];
}

+ (void)deleteDefaultDeckIfVersionIncreased {
    NSInteger savedVersion = [[NSUserDefaults standardUserDefaults] integerForKey:NSUserDefaultsKeyDeckVersion];
    if (savedVersion < CurrentDeckVersion) {
        NSLog(@"version increased from %ld to %ld, deleting old data...", (long)savedVersion, (long)CurrentDeckVersion);
        [self deleteDefaultDeck];
        [[NSUserDefaults standardUserDefaults] setInteger:CurrentDeckVersion forKey:NSUserDefaultsKeyDeckVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
