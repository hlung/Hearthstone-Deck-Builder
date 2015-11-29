//
//  NSUserDefaults+NSCoding.h
//  TweetGecko
//
//  Created by Hlung on 21/11/15.
//  Copyright © 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A helper for saving and loading objects from NSUserDefaults */
@interface NSUserDefaults (NSCoding)

- (void)saveNSUserDefaultsObject:(NSObject <NSCoding, NSCopying> *)obj forKey:(NSString *)key;

- (void)saveNSUserDefaultsObject:(NSObject <NSCoding, NSCopying> *)obj forKey:(NSString *)key archive:(BOOL)archive;

- (id)loadNSUserDefaultsObjectForKey:(NSString *)key;

- (id)loadNSUserDefaultsObjectForKey:(NSString *)key unarchive:(BOOL)unarchive;

@end
