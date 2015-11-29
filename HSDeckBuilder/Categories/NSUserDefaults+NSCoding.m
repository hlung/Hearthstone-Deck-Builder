//
//  NSUserDefaults+NSCoding.m
//  TweetGecko
//
//  Created by Hlung on 21/11/15.
//  Copyright © 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import "NSUserDefaults+NSCoding.h"

@implementation NSUserDefaults (NSCoding)

- (void)saveNSUserDefaultsObject:(NSObject <NSCoding, NSCopying> *)obj forKey:(NSString *)key {
    [self saveNSUserDefaultsObject:obj forKey:key archive:false];
}

- (void)saveNSUserDefaultsObject:(NSObject <NSCoding, NSCopying> *)obj forKey:(NSString*)key archive:(BOOL)archive {
    if (archive) {
        obj = [NSKeyedArchiver archivedDataWithRootObject:obj];
    }
    if (obj == nil) {
        [self removeObjectForKey:key];
    }
    else {
        [self setObject:obj forKey:key];
    }
    [self synchronize];
}

- (id)loadNSUserDefaultsObjectForKey:(NSString *)key {
    return [self loadNSUserDefaultsObjectForKey:key unarchive:false];
}

- (id)loadNSUserDefaultsObjectForKey:(NSString *)key unarchive:(BOOL)unarchive; {
    id obj = [self objectForKey:key];
    if (unarchive && obj) {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
    }
    return obj;
}

@end
