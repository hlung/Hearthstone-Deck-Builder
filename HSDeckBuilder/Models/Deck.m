//
//  Deck.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "Deck.h"

@implementation Deck

- (NSUInteger)cardCount {
    NSUInteger count = 0;
    for (Card *card in self.cards) {
        count += card.count;
    }
    return count;
}

+ (NSDictionary *)defaultPropertyValues {
    return @{@"name": @"",
             @"generatedFromURL": @""
             };
}

//- (NSString*)description {
//    return [NSString stringWithFormat:@"Deck with %lu cards", (unsigned long)self.cardCount];
//}

@end
