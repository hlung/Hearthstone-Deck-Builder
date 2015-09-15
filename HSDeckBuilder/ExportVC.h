//
//  ExportVC.h
//  HSDeckBuilder
//
//  Created by Hlung on 22/8/15 A.
//  Copyright (c) 2015 Thongchai Kolyutsakul. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ExportVC, Card;

@protocol ExportVCDelegate <NSObject>
@optional
/** This is called in main thread */
- (void)exportVC:(ExportVC*)vc processingCardIndex:(NSInteger)index;
@end

@interface ExportVC : NSViewController
@property (weak, nonatomic) NSObject <ExportVCDelegate>*delegate;
@end
