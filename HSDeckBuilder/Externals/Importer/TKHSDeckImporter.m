//
//  TKHSDeckImporter.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "TKHSDeckImporter.h"
#import "AppDelegate.h"
//#import "SBJson4.h"
#import "AFNetworking.h"
#import "TFHpple.h"
#import "RegExCategories.h"

@implementation TKHSDeckImporter

// create NSData from a local html file
// NSString *str = [[NSBundle bundleForClass:[self class]] pathForResource:@"html_example_icy-veins" ofType:@"html"];
// NSData *fileData = [NSData dataWithContentsOfFile:str];

+ (BOOL)isURLSupported:(NSString*)urlString {
    if ([self websiteTypeFromURL:urlString] != TKHSDeckImporterWebsite_unsupported) {
        return true;
    }
    return false;
}

+ (TKHSDeckImporterWebsite)websiteTypeFromURL:(NSString*)urlString {
    if ([urlString isMatch:RX(@"hearthpwn.com/decks/")]) {
        NSString *dockerId = [urlString firstMatch:RX(@"(\\d+)")]; // get first number
        if (dockerId != nil) {
            return TKHSDeckImporterWebsite_hearthpwn;
        }
    }
    if ([urlString isMatch:RX(@"icy-veins.com/hearthstone/")]) {
        return TKHSDeckImporterWebsite_icy_veins;
    }
    return TKHSDeckImporterWebsite_unsupported;
}

+ (void)importDeckFromURL:(NSString*)urlString
                  success:(void (^)(Deck*))success
                     fail:(void (^)(NSString*))fail {
    
    TKHSDeckImporterWebsite type = [self websiteTypeFromURL:urlString];
    
    switch (type) {
        case TKHSDeckImporterWebsite_hearthpwn:
            [self importHearthPwnWithURL:urlString
                                 success:success
                                    fail:fail];
            break;
        case TKHSDeckImporterWebsite_icy_veins:
            [self importIcyVeinsWithURL:urlString
                                success:success
                                   fail:fail];
            break;
            
        default:
            if (fail) {
                fail(@"URL not supported");
            }
            break;
    }
    
}

+ (void)importHearthPwnWithURL:(NSString*)urlString
                       success:(void (^)(Deck*))success
                          fail:(void (^)(NSString*))fail {
    
    if ([self websiteTypeFromURL:urlString] != TKHSDeckImporterWebsite_hearthpwn) {
        if (fail) fail(@"URL not supported");
        return;
    }
    
    NSString *dockerId = [urlString firstMatch:RX(@"(\\d+)")]; // get first number
    
    NSString* query = [NSString stringWithFormat:@"http://www.hearthpwn.com/decks/%@", dockerId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation *loginRequest =
    [manager GET:query
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple * doc = [TFHpple hppleWithHTMLData:responseObject];
        
        NSArray *cardNameNodes = [doc searchWithXPathQuery:@"//aside//td[contains(@class, 'col-name')]"];
        if ([cardNameNodes count] == 0) {
            if (fail) fail(@"Website format is not recognized");
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
                NSLog(@"Card: (%ld) %@", (long)card.count, card.name);
                [deck.cards addObject:card];
            }
            if (success) success(deck);
        }
             
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (fail) fail([error localizedDescription]);
    }];
    
    [loginRequest start];
}

+ (void)importIcyVeinsWithURL:(NSString*)urlString
                      success:(void (^)(Deck* deck))success
                         fail:(void (^)(NSString* error))fail {
    
    if ([self websiteTypeFromURL:urlString] != TKHSDeckImporterWebsite_icy_veins) {
        if (fail) fail(@"URL not supported");
        return;
    }
    
//    NSString* query = [NSString stringWithFormat:@"http://www.hearthpwn.com/decks/%@", dockerId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation *loginRequest =
    [manager GET:urlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             TFHpple * doc = [TFHpple hppleWithHTMLData:responseObject];
             NSArray *nodes = [doc searchWithXPathQuery:@"//table[contains(@class, 'deck_card_list')]//tr[2]//td//ul//li"];
             if([nodes count] == 0) {
                 if (fail) fail(@"Website format is not recognized");
                 return;
             }
             
             Deck *deck = [Deck new];

             for (TFHppleElement *content in nodes) {
                 TFHppleElement *cardNameElement = [content firstChildWithTagName:@"a"];
                 if (!cardNameElement) {
                     continue;
                 }
                 
                 // parse
                 NSString *cardName = [cardNameElement text];
                 int cardCount = [[[content text] firstMatch:RX(@"(\\d+)")] intValue]; // get first number

                 // generate model
                 Card *card = [Card new];
                 card.name = cardName;
                 card.count = cardCount;
                 NSLog(@"Card: (%ld) %@", (long)card.count, card.name);
                 [deck.cards addObject:card];
             }

             success(deck);

         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             fail([error localizedDescription]);
         }];
    
    [loginRequest start];
}

@end
