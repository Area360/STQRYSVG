//
//  STQRYSVGUtilities.h
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STQRYSVGUtilities : NSObject

+ (CGPathRef)loadSVGFileNamed:(NSString *)filename;
+ (CGPathRef)scalePath:(CGPathRef)path toSize:(CGSize)targetSize;
+ (UIImage *)renderPath:(CGPathRef)path size:(CGSize)size;

+ (void)saveCachedCGPath:(CGPathRef)path forKey:(NSString *)key;
+ (CGPathRef)cachedCGPathForKey:(NSString *)key;

@end
