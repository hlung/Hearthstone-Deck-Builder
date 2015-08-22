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

+ (Deck*)loadDefaultDeck {
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *d = [Deck allObjectsInRealm:realm];
    return [d firstObject];
    //    return nil;
}

- (void)saveAsDefaultDeck {
    // Persist data
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
        [realm addObject:self];
    }];
}

//- (NSString*)description {
//    return [NSString stringWithFormat:@"Deck with %lu cards", (unsigned long)self.cardCount];
//}

@end
