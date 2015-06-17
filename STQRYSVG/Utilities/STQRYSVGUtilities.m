//
//  STQRYSVGUtilities.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "STQRYSVGUtilities.h"
#import <CommonCrypto/CommonDigest.h>

static NSMutableDictionary *_cachedSVGPaths;

@implementation STQRYSVGUtilities

#pragma mark - Public

+ (STQRYSVGModel *)SVGModelNamed:(NSString *)filename
{
    STQRYSVGModel *svgModel = [self cachedSVGModelForKey:filename];
    
    if (!svgModel) {
        svgModel = [self loadSVGModelFileNamed:filename];
        [self saveCachedSVGModel:svgModel forKey:filename];
    }
    
    return svgModel;
}

+ (UIImage *)renderSVGModel:(STQRYSVGModel *)svgModel size:(CGSize)size
{
    NSParameterAssert(svgModel);
    
    CGAffineTransform transform;
    CGAffineTransform *t = NULL;
    
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        CGPathRef path = [svgModel combinedPathsWithTransform:NULL];
        CGRect boundingRect = CGPathGetPathBoundingBox(path);
        CGPathRelease(path);
        
        transform = [self transformForScalingRect:boundingRect toSize:size];
        t = &transform;
        
        CGFloat scaleFactor = [self aspectFitScaleFactorForSize:boundingRect.size scalingToSize:size];
        CGSize scaledSize = CGSizeApplyAffineTransform(boundingRect.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
        size = CGSizeMake(MIN(size.width, scaledSize.width), MIN(size.height, scaledSize.height));
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [svgModel renderInContext:UIGraphicsGetCurrentContext() transform:t];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - Private Helpers

+ (STQRYSVGModel *)loadSVGModelFileNamed:(NSString *)filename
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"svg"];
    if (!url) {
        NSLog(@"Could not find file named %@.svg in application's main bundle.", filename);
        return nil;
    }
    
    return [[STQRYSVGModel alloc] initWithSVGData:[NSData dataWithContentsOfURL:url]];
}

+ (CGFloat)aspectFitScaleFactorForSize:(CGSize)size1 scalingToSize:(CGSize)size2
{
    CGFloat w1 = size1.width, h1 = size1.height, w2 = size2.width, h2 = size2.height;
    return (w1 / h1 > w2 / h2) ? (w2 / w1) : (h2 / h1);
}

+ (CGAffineTransform)transformForScalingRect:(CGRect)boundingRect toSize:(CGSize)targetSize
{
    CGFloat x = boundingRect.origin.x, y = boundingRect.origin.y;
    CGFloat scale = [self aspectFitScaleFactorForSize:boundingRect.size scalingToSize:targetSize];
    return CGAffineTransformConcat(CGAffineTransformMakeTranslation(-x, -y), CGAffineTransformMakeScale(scale, scale));
//    return CGAffineTransformScale(CGAffineTransformMakeTranslation(-x, -y), scale, scale);
}

#pragma mark - Caching

+ (NSMutableDictionary *)cachedSVGPaths
{
    if (!_cachedSVGPaths) {
        _cachedSVGPaths = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarningNotification:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return _cachedSVGPaths;
}

+(void)didReceiveMemoryWarningNotification:(NSNotification *)notification
{
    [self.cachedSVGPaths removeAllObjects];
}

+ (NSString *)md5:(NSString *)string
{
    const char *cStr = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}

+ (void)saveCachedSVGModel:(STQRYSVGModel *)model forKey:(NSString *)key
{
    self.cachedSVGPaths[[self md5:key]] = model;
}

+ (STQRYSVGModel *)cachedSVGModelForKey:(NSString *)key
{
    return self.cachedSVGPaths[[self md5:key]];
}

@end
