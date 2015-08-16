//
//  NetEaseCardBuilderImporter.m
//  Hearthstone-Deck-Tracker
//
//  Created by jeswang on 15/1/11.
//  Copyright (c) 2015年 rainy. All rights reserved.
//

#import "NetEaseCardBuilderImporter.h"
//#import "SystemHelper.h"
//#import "Configuration.h"
#import "Deck.h"
#import "Card.h"
#import "AppDelegate.h"

#import "SBJson4.h"
#import "AFNetworking.h"
#import "TFHpple.h"
#import "RegExCategories.h"

@implementation NetEaseCardBuilderImporter

+ (void)importHearthPwnDockerWithId:(NSString*)dockerId
                            success:(void (^)(Deck*))success
                               fail:(void (^)(NSString*))fail {
    NSString* query = [NSString stringWithFormat:@"http://www.hearthpwn.com/decks/%@", dockerId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation *loginRequest  = [manager GET:query parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple * doc       = [TFHpple hppleWithHTMLData:responseObject];
        
        NSArray *cardNameNodes = [doc searchWithXPathQuery:@"//aside//td[contains(@class, 'col-name')]"];
        if ([cardNameNodes count] == 0) {
            fail(@"Wrong build Id");
            return;
        }
        else {
            Deck *deck = [Deck new];
            
            for (TFHppleElement *content in cardNameNodes) {
                TFHppleElement *element = [[content firstChildWithTagName:@"b"] firstChildWithTagName:@"a"];
                if (!element) {
                    continue;
                }
                // parse
                NSString *cardName = [element text];
                NSString *count = [[[content children] lastObject] content];
                int cardCount = [[count firstMatch:RX(@"(\\d+)")] intValue]; // get first number
                
                // generate model
                Card *card = [Card new];
                card.name = cardName;
                card.count = cardCount;
                NSLog(@"Card name: (%ld) %@", (long)card.count, card.name);
                [deck.cards addObject:card];
            }
            
            success(deck);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        fail([error localizedDescription]);
    }];
    
    [loginRequest start];
}

@end
