//
//  TKKeyCodeHelperTests.m
//  HSDeckBuilder
//
//  Created by Hlung on 11/12/15 A.
//  Copyright © 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TKKeyCodeHelper.h"

@interface TKKeyCodeHelperTests : XCTestCase

@end

@implementation TKKeyCodeHelperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSString *)exampleString {
    return @"abcdefg xyz 1234";
}

- (NSArray *)exampleKeyCodes {
    return @[@0, @45, @34, @4, @2, @16, @32, @49,
             @11, @17, @44, @49,
             @18, @19, @20, @21];
}

- (void)testAlphanumerics {
    NSArray *array = [TKKeyCodeHelper keyCodesFormString:[self exampleString]];
    NSArray *expected = [self exampleKeyCodes];
    XCTAssertEqualObjects(array, expected);
}

- (void)testSomeSymbols {
    NSArray *array = [TKKeyCodeHelper keyCodesFormString:@":"];
    NSArray *expected = @[@5];
    XCTAssertEqualObjects(array, expected);
}

- (void)testStringFromKeyCodes {
    NSString *string = [TKKeyCodeHelper stringFromKeyCodes:[self exampleKeyCodes]];
    NSString *expected = [self exampleString];
    XCTAssertEqualObjects(string, expected);
}

//- (void)testStringFromKeyCodesAll {
//    NSMutableArray *all = [NSMutableArray array];
//    for (uint16_t i = 0; i < 128; i++) {
//        [all addObject:@(i)];
//    }
//    NSString *string = [TKKeyCodeHelper stringFromKeyCodes:all];
//    NSString *expected = @"aoeudi;qjk§x',.pfy123465]97[80=rg/clnh-ts\\wzbmv	 `䓀䓀䓀䓀䓀䓀䓀䓀䓀䓀䓀.*䓀+䓀䓀/-䓀䓀=01234567䓀89䓀䓀䓀䓀";
//    XCTAssertEqualObjects(string, expected);
//}

@end
