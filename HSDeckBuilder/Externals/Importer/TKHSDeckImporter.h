//
//  TKHSDeckImporter.h
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Deck.h"

typedef NS_ENUM(NSInteger, TKHSDeckImporterWebsite) {
    TKHSDeckImporterWebsite_unsupported,
    TKHSDeckImporterWebsite_hearthpwn,
    TKHSDeckImporterWebsite_icy_veins,
};

@interface TKHSDeckImporter : NSObject

+ (BOOL)isURLSupported:(NSString*)urlString;

+ (void)importDeckFromURL:(NSString*)urlString
                  success:(void (^)(Deck* deck))success
                     fail:(void (^)(NSString* error))fail;

@end
