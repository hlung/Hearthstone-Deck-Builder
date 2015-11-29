//
//  Card.h
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface Card : MTLModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger count;
@end
