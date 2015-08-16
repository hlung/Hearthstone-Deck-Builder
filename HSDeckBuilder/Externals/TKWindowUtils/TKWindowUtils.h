//
//  TKWindowUtils.h
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "TKKeyCodeHelper.h"

@class TKWindowListApplierData;

/** Gets window info from other applications */
@interface TKWindowUtils : NSObject

@property (strong) TKWindowListApplierData *windowListData;

- (NSRect)getAppWindowBoundsOfRunningApplication:(NSRunningApplication*)app;

- (void)postEventMouseLeftClickAtPoint:(CGPoint)pt;
- (void)postEventMouseMoveToPoint:(CGPoint)pt;
- (void)postEventKeyboardTypeKeyCode:(CGKeyCode)keyCode;
- (void)postEventKeyboardTypeWithString:(NSString*)str;

@end

/** Data model for use in TKWindowUtils */
@interface TKWindowListApplierData : NSObject
@property (strong, nonatomic) NSMutableArray * outputArray;
@property int order;
- (instancetype)initWindowListData:(NSMutableArray *)array;
@end