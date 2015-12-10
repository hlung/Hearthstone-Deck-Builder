
//
//  TKKeyCodeHelper.m
//  HSDeckBuilder
//
//  Created by Hlung on 15/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "TKKeyCodeHelper.h"
#include <Carbon/Carbon.h> /* For kVK_ constants, and TIS functions. */

// https://github.com/openstenoproject/plover/blob/master/plover/oslayer/osxkeyboardcontrol.py

// TODO: list all non-printable keys
const CGKeyCode TK_CGKeyCode_RETURN = 36;
const CGKeyCode TK_CGKeyCode_TAB    = 48;
const CGKeyCode TK_CGKeyCode_SPACE  = 49;
const CGKeyCode TK_CGKeyCode_DELETE = 51;
const CGKeyCode TK_CGKeyCode_ENTER  = 52;
const CGKeyCode TK_CGKeyCode_ESCAPE = 53;

const CGKeyCode TK_CGKeyCode_F5 = 96;
const CGKeyCode TK_CGKeyCode_F6 = 97;
const CGKeyCode TK_CGKeyCode_F7 = 98;
const CGKeyCode TK_CGKeyCode_F3 = 99;
const CGKeyCode TK_CGKeyCode_F8 = 100;
const CGKeyCode TK_CGKeyCode_F9 = 101;
const CGKeyCode TK_CGKeyCode_F11 = 103;
const CGKeyCode TK_CGKeyCode_F13 = 105;
const CGKeyCode TK_CGKeyCode_F14 = 107;
const CGKeyCode TK_CGKeyCode_F10 = 109;
const CGKeyCode TK_CGKeyCode_F12 = 111;
const CGKeyCode TK_CGKeyCode_F15 = 113;

const CGKeyCode TK_CGKeyCode_CLEAR = 71;
const CGKeyCode TK_CGKeyCode_SLASH = 75;
const CGKeyCode TK_CGKeyCode_NUMPAD_ENTER = 76;  // numberpad on full kbd

const CGKeyCode TK_CGKeyCode_HELP = 114;
const CGKeyCode TK_CGKeyCode_HOME = 115;
const CGKeyCode TK_CGKeyCode_PGUP = 116;
const CGKeyCode TK_CGKeyCode_NUMPAD_DELETE = 117; // numberpad on full kbd
const CGKeyCode TK_CGKeyCode_F4 = 118;
const CGKeyCode TK_CGKeyCode_END = 119;
const CGKeyCode TK_CGKeyCode_F2 = 120;
const CGKeyCode TK_CGKeyCode_PGDN = 121;
const CGKeyCode TK_CGKeyCode_F1 = 122;
const CGKeyCode TK_CGKeyCode_LEFT = 123;
const CGKeyCode TK_CGKeyCode_RIGHT = 124;
const CGKeyCode TK_CGKeyCode_DOWN = 125;
const CGKeyCode TK_CGKeyCode_UP = 126;


@implementation TKKeyCodeHelper

/* Returns string representation of key, if it is printable.
 * Ownership follows the Create Rule; that is, it is the caller's
 * responsibility to release the returned object. */
CFStringRef createStringForKey(CGKeyCode keyCode)
{
    TISInputSourceRef currentKeyboard = TISCopyCurrentKeyboardInputSource();
    CFDataRef layoutData =
    TISGetInputSourceProperty(currentKeyboard,
                              kTISPropertyUnicodeKeyLayoutData);
    const UCKeyboardLayout *keyboardLayout =
    (const UCKeyboardLayout *)CFDataGetBytePtr(layoutData);
    
    UInt32 keysDown = 0;
    UniChar chars[4];
    UniCharCount realLength;
    
    UCKeyTranslate(keyboardLayout,
                   keyCode,
                   kUCKeyActionDisplay,
                   0,
                   LMGetKbdType(),
                   kUCKeyTranslateNoDeadKeysBit,
                   &keysDown,
                   sizeof(chars) / sizeof(chars[0]),
                   &realLength,
                   chars);
    CFRelease(currentKeyboard);
    
    return CFStringCreateWithCharacters(kCFAllocatorDefault, chars, 1);
}

/* Returns key code for given character via the above function, or UINT16_MAX
 * on error. */
CGKeyCode keyCodeForChar(const char c)
{
    static CFMutableDictionaryRef charToCodeDict = NULL;
    CGKeyCode code;
    UniChar character = c;
    CFStringRef charStr = NULL;
    
    /* Generate table of keycodes and characters. */
    if (charToCodeDict == NULL) {
        size_t i;
        charToCodeDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                   128,
                                                   &kCFCopyStringDictionaryKeyCallBacks,
                                                   NULL);
        if (charToCodeDict == NULL) return UINT16_MAX;
        
        /* Loop through every keycode (0 - 127) to find its current mapping. */
        for (i = 0; i < 128; ++i) {
            CFStringRef string = createStringForKey((CGKeyCode)i);
            if (string != NULL) {
                CFDictionaryAddValue(charToCodeDict, string, (const void *)i);
                CFRelease(string);
            }
        }
    }
    
    charStr = CFStringCreateWithCharacters(kCFAllocatorDefault, &character, 1);
    
    /* Our values may be NULL (0), so we need to use this function. */
    if (!CFDictionaryGetValueIfPresent(charToCodeDict, charStr,
                                       (const void **)&code)) {
        printf("Cannot find char code for %c", c);
        code = UINT16_MAX;
    }
    
    CFRelease(charStr);
    return code;
}

+ (CGKeyCode)keyCodeFormChar:(const char)c {
    return keyCodeForChar(c);
}

+ (NSArray*)keyCodesFormString:(NSString *)string {
    NSMutableArray *m = [NSMutableArray array];
    if (string.length > 0) {
        const char *mychar = [[string lowercaseString] UTF8String];
        
        // BUG FIX:
        // mychar pointer seems to be NULL when built in Release configuration, which has
        // Optimization Level above "None". The hack is change change it to "None".
        for (int i = 0; mychar[i] != '\0'; i++){
            CGKeyCode keyCode = [self keyCodeFormChar:mychar[i]];
            [m addObject:@(keyCode)];
        }
    }
    return m;
}

+ (NSString *)stringFromKeyCodes:(NSArray *)keyCodes {
    NSMutableString *m = [NSMutableString string];
    for (NSNumber *code in keyCodes) {
        CFStringRef cstring = createStringForKey(code.unsignedIntValue);
        [m appendFormat:@"%@", cstring];
    }
    return m;
}

/*
int keyCodeForKeyString(char * keyString)
{
    if (strcmp(keyString, "a") == 0) return 0;
    if (strcmp(keyString, "s") == 0) return 1;
    if (strcmp(keyString, "d") == 0) return 2;
    if (strcmp(keyString, "f") == 0) return 3;
    if (strcmp(keyString, "h") == 0) return 4;
    if (strcmp(keyString, "g") == 0) return 5;
    if (strcmp(keyString, "z") == 0) return 6;
    if (strcmp(keyString, "x") == 0) return 7;
    if (strcmp(keyString, "c") == 0) return 8;
    if (strcmp(keyString, "v") == 0) return 9;
    // what is 10?
    if (strcmp(keyString, "b") == 0) return 11;
    if (strcmp(keyString, "q") == 0) return 12;
    if (strcmp(keyString, "w") == 0) return 13;
    if (strcmp(keyString, "e") == 0) return 14;
    if (strcmp(keyString, "r") == 0) return 15;
    if (strcmp(keyString, "y") == 0) return 16;
    if (strcmp(keyString, "t") == 0) return 17;
    if (strcmp(keyString, "1") == 0) return 18;
    if (strcmp(keyString, "2") == 0) return 19;
    if (strcmp(keyString, "3") == 0) return 20;
    if (strcmp(keyString, "4") == 0) return 21;
    if (strcmp(keyString, "6") == 0) return 22;
    if (strcmp(keyString, "5") == 0) return 23;
    if (strcmp(keyString, "=") == 0) return 24;
    if (strcmp(keyString, "9") == 0) return 25;
    if (strcmp(keyString, "7") == 0) return 26;
    if (strcmp(keyString, "-") == 0) return 27;
    if (strcmp(keyString, "8") == 0) return 28;
    if (strcmp(keyString, "0") == 0) return 29;
    if (strcmp(keyString, "]") == 0) return 30;
    if (strcmp(keyString, "o") == 0) return 31;
    if (strcmp(keyString, "u") == 0) return 32;
    if (strcmp(keyString, "[") == 0) return 33;
    if (strcmp(keyString, "i") == 0) return 34;
    if (strcmp(keyString, "p") == 0) return 35;
    if (strcmp(keyString, "RETURN") == 0) return 36;
    if (strcmp(keyString, "l") == 0) return 37;
    if (strcmp(keyString, "j") == 0) return 38;
    if (strcmp(keyString, "'") == 0) return 39;
    if (strcmp(keyString, "k") == 0) return 40;
    if (strcmp(keyString, ";") == 0) return 41;
    if (strcmp(keyString, "\\") == 0) return 42;
    if (strcmp(keyString, ",") == 0) return 43;
    if (strcmp(keyString, "/") == 0) return 44;
    if (strcmp(keyString, "n") == 0) return 45;
    if (strcmp(keyString, "m") == 0) return 46;
    if (strcmp(keyString, ".") == 0) return 47;
    if (strcmp(keyString, "TAB") == 0) return 48;
    if (strcmp(keyString, "SPACE") == 0) return 49;
    if (strcmp(keyString, "`") == 0) return 50;
    if (strcmp(keyString, "DELETE") == 0) return 51;
    if (strcmp(keyString, "ENTER") == 0) return 52;
    if (strcmp(keyString, "ESCAPE") == 0) return 53;
    
    // some more missing codes abound, reserved I presume, but it would
    // have been helpful for Apple to have a document with them all listed
    
    if (strcmp(keyString, ".") == 0) return 65;
    
    if (strcmp(keyString, "*") == 0) return 67;
    
    if (strcmp(keyString, "+") == 0) return 69;
    
    if (strcmp(keyString, "CLEAR") == 0) return 71;
    
    if (strcmp(keyString, "/") == 0) return 75;
    if (strcmp(keyString, "ENTER") == 0) return 76;  // numberpad on full kbd
    
    if (strcmp(keyString, "=") == 0) return 78;
    
    if (strcmp(keyString, "=") == 0) return 81;
    if (strcmp(keyString, "0") == 0) return 82;
    if (strcmp(keyString, "1") == 0) return 83;
    if (strcmp(keyString, "2") == 0) return 84;
    if (strcmp(keyString, "3") == 0) return 85;
    if (strcmp(keyString, "4") == 0) return 86;
    if (strcmp(keyString, "5") == 0) return 87;
    if (strcmp(keyString, "6") == 0) return 88;
    if (strcmp(keyString, "7") == 0) return 89;
    
    if (strcmp(keyString, "8") == 0) return 91;
    if (strcmp(keyString, "9") == 0) return 92;
    
    if (strcmp(keyString, "F5") == 0) return 96;
    if (strcmp(keyString, "F6") == 0) return 97;
    if (strcmp(keyString, "F7") == 0) return 98;
    if (strcmp(keyString, "F3") == 0) return 99;
    if (strcmp(keyString, "F8") == 0) return 100;
    if (strcmp(keyString, "F9") == 0) return 101;
    
    if (strcmp(keyString, "F11") == 0) return 103;
    
    if (strcmp(keyString, "F13") == 0) return 105;
    
    if (strcmp(keyString, "F14") == 0) return 107;
    
    if (strcmp(keyString, "F10") == 0) return 109;
    
    if (strcmp(keyString, "F12") == 0) return 111;
    
    if (strcmp(keyString, "F15") == 0) return 113;
    if (strcmp(keyString, "HELP") == 0) return 114;
    if (strcmp(keyString, "HOME") == 0) return 115;
    if (strcmp(keyString, "PGUP") == 0) return 116;
    if (strcmp(keyString, "DELETE") == 0) return 117;
    if (strcmp(keyString, "F4") == 0) return 118;
    if (strcmp(keyString, "END") == 0) return 119;
    if (strcmp(keyString, "F2") == 0) return 120;
    if (strcmp(keyString, "PGDN") == 0) return 121;
    if (strcmp(keyString, "F1") == 0) return 122;
    if (strcmp(keyString, "LEFT") == 0) return 123;
    if (strcmp(keyString, "RIGHT") == 0) return 124;
    if (strcmp(keyString, "DOWN") == 0) return 125;
    if (strcmp(keyString, "UP") == 0) return 126;
    
    fprintf(stderr, "keyString %s Not Found. Aborting...\n", keyString);
//    exit(EXIT_FAILURE);
    return UINT16_MAX;
}*/

@end
