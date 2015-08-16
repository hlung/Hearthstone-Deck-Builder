//
//  NetEaseCardBuilderImporter.h
//  Hearthstone-Deck-Tracker
//
//  Created by jeswang on 15/1/11.
//  Copyright (c) 2015年 rainy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

@interface NetEaseCardBuilderImporter : NSObject

+ (void)importHearthPwnDockerWithId:(NSString*)dockerId
                            success:(void (^)(Deck*))success
                               fail:(void (^)(NSString*))fail;

@end
