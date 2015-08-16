//
//  Deck.h
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>
#import "Card.h"

@interface Deck : RLMObject
@property NSString *name;
@property NSString *generatedFromURL;
@property RLMArray<Card> *cards;
- (NSUInteger)cardCount;
//- (NSString*)description;
@end
//RLM_ARRAY_TYPE(Deck)