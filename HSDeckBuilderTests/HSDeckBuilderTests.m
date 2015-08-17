//
//  HSDeckBuilderTests.m
//  HSDeckBuilderTests
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "TKHSDeckImporter.h"

@interface HSDeckBuilderTests : XCTestCase

@end

@implementation HSDeckBuilderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParsingWeb_IcyVeins {
    
    NSString *urlString = @"http://www.icy-veins.com/hearthstone/legendary-prophet-velen-combo-priest-brm-deck";
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    [TKHSDeckImporter
     importDeckFromURL:urlString
     success:^(Deck *deck) {
         XCTAssert(deck.cards.count == 20, @"Pass");
         XCTAssert(deck.cardCount == 30, @"Pass");
         [expectation fulfill];
         
     } fail:^(NSString *error) {
         XCTFail(@"TKHSDeckImporter -importDeckFromURL: Failed with error: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
    
//    NSString *str = [[NSBundle bundleForClass:[self class]] pathForResource:@"html_example_icy-veins" ofType:@"html"];
//    NSData *fileData = [NSData dataWithContentsOfFile:str];
//    XCTAssertNotNil(fileData);
//    
//    TFHpple * doc = [TFHpple hppleWithHTMLData:fileData];
//    NSArray *nodes = [doc searchWithXPathQuery:@"//table[contains(@class, 'deck_card_list')]//tr[2]//td//ul//li"];
//    XCTAssert([nodes count] > 0, @"Pass"); // == 20
//    
//    for (TFHppleElement *content in nodes) {
//        NSString *cardName = [[content firstChildWithTagName:@"a"] text];
//        int cardCount = [[[content text] firstMatch:RX(@"(\\d+)")] intValue]; // get first number
//        NSLog(@"%d x %@", cardCount, cardName);
//        XCTAssert(cardCount > 0, @"Pass");
//        XCTAssert([cardName length] > 0, @"Pass");
//    }
}

- (void)testParsingWeb_Hearthpwn {
    
    NSString *urlString = @"http://www.hearthpwn.com/decks/279780-kolento-combo-priest";
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Method Works!"];
    [TKHSDeckImporter
     importDeckFromURL:urlString
     success:^(Deck *deck) {
         XCTAssert(deck.cards.count == 17, @"Pass");
         XCTAssert(deck.cardCount == 30, @"Pass");
         [expectation fulfill];
         
     } fail:^(NSString *error) {
         XCTFail(@"TKHSDeckImporter -importDeckFromURL: Failed with error: %@", error);
     }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
    }];
    
//    NSString *str = [[NSBundle bundleForClass:[self class]] pathForResource:@"html_example_hearthpwn" ofType:@"html"];
//    NSData *fileData = [NSData dataWithContentsOfFile:str];
//    XCTAssertNotNil(fileData);
//
//    TFHpple * doc = [TFHpple hppleWithHTMLData:fileData];
//    NSArray *cardNameNodes = [doc searchWithXPathQuery:@"//aside//td[contains(@class, 'col-name')]"];
//    XCTAssert([cardNameNodes count] > 0, @"Pass"); // == 16
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
