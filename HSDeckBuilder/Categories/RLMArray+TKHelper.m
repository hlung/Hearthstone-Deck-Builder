//
//  RLMArray+TKHelper.m
//  HSDeckBuilder
//
//  Created by Hlung on 16/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "RLMArray+TKHelper.h"

@implementation RLMArray (TKHelper)
- (NSArray*)allObjects {
    NSMutableArray *m = [NSMutableArray array];
    for (id obj in self) {
        [m addObject:obj];
    }
    return m;
}
@end