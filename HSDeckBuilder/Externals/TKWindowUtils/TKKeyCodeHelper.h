//
//  TKKeyCodeHelper.h
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const CGKeyCode TK_CGKeyCode_RETURN;
extern const CGKeyCode TK_CGKeyCode_TAB;
extern const CGKeyCode TK_CGKeyCode_SPACE;
extern const CGKeyCode TK_CGKeyCode_DELETE;
extern const CGKeyCode TK_CGKeyCode_ENTER;
extern const CGKeyCode TK_CGKeyCode_ESCAPE;

extern const CGKeyCode TK_CGKeyCode_F5;
extern const CGKeyCode TK_CGKeyCode_F6;
extern const CGKeyCode TK_CGKeyCode_F7;
extern const CGKeyCode TK_CGKeyCode_F3;
extern const CGKeyCode TK_CGKeyCode_F8;
extern const CGKeyCode TK_CGKeyCode_F9;
extern const CGKeyCode TK_CGKeyCode_F11;
extern const CGKeyCode TK_CGKeyCode_F13;
extern const CGKeyCode TK_CGKeyCode_F14;
extern const CGKeyCode TK_CGKeyCode_F10;
extern const CGKeyCode TK_CGKeyCode_F12;
extern const CGKeyCode TK_CGKeyCode_F15;

extern const CGKeyCode TK_CGKeyCode_CLEAR;
extern const CGKeyCode TK_CGKeyCode_SLASH;
extern const CGKeyCode TK_CGKeyCode_NUMPAD_ENTER; // numberpad on full kbd

extern const CGKeyCode TK_CGKeyCode_HELP;
extern const CGKeyCode TK_CGKeyCode_HOME;
extern const CGKeyCode TK_CGKeyCode_PGUP;
extern const CGKeyCode TK_CGKeyCode_NUMPAD_DELETE; // numberpad on full kbd
extern const CGKeyCode TK_CGKeyCode_F4;
extern const CGKeyCode TK_CGKeyCode_END;
extern const CGKeyCode TK_CGKeyCode_F2;
extern const CGKeyCode TK_CGKeyCode_PGDN;
extern const CGKeyCode TK_CGKeyCode_F1;
extern const CGKeyCode TK_CGKeyCode_LEFT;
extern const CGKeyCode TK_CGKeyCode_RIGHT;
extern const CGKeyCode TK_CGKeyCode_DOWN;
extern const CGKeyCode TK_CGKeyCode_UP;

@interface TKKeyCodeHelper : NSObject

/**
 @return array of NSNumber of CGKeyCode, invalid string will be UINT16_MAX
 */
+ (NSArray *)keyCodesFormString:(NSString *)string;

+ (NSString *)stringFromKeyCodes:(NSArray *)keyCodes;

@end
