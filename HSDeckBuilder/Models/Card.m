//
//  Card.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "Card.h"

@implementation Card

- (void)setName:(NSString *)name {
    _name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setCount:(NSInteger)count {
    _count = MAX(1, count); // safety, should never be less than 1
}

@end
