//
//  Card.h
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface Card : RLMObject
@property NSString *name;
@property NSInteger count;
@end
RLM_ARRAY_TYPE(Card)  // define RLMArray<Card>
