//
//  Deck.h
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "Card.h"

@interface Deck : MTLModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *generatedFromURL;
@property (nonatomic, strong) NSMutableArray<Card *> *cards;

+ (Deck*)loadDefaultDeck;
+ (void)deleteDefaultDeck;

- (NSArray<NSDictionary *>*)contentForArrayController;
- (NSUInteger)cardCount;
- (void)saveAsDefaultDeck;

@end
