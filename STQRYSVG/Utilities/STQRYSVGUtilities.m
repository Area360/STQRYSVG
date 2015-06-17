//
//  STQRYSVGUtilities.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "STQRYSVGUtilities.h"
#import <CommonCrypto/CommonDigest.h>

static NSMutableDictionary * STQRYCachedSVGPaths()
{
    static NSMutableDictionary *_cachedSVGPaths;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cachedSVGPaths = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_cachedSVGPaths removeAllObjects];
        }];
    });
    return _cachedSVGPaths;
}

static NSCache * STQRYCachedRenderedImages()
{
    static NSCache *_cachedRenderedImages;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cachedRenderedImages = [NSCache new];
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * __unused notification) {
            [_cachedRenderedImages removeAllObjects];
        }];
    });
    return _cachedRenderedImages;
}

NS_INLINE NSString * STQRYCachedRenderedImagesKey(STQRYSVGModel *model, CGSize size)
{
    return [NSString stringWithFormat:@"%@-%.0f-%.0f", model.name, size.width, size.height];
}

@implementation STQRYSVGUtilities

#pragma mark - Public

+ (STQRYSVGModel *)SVGModelNamed:(NSString *)filename
{
    STQRYSVGModel *svgModel = STQRYCachedSVGPaths()[filename];
    
    if (!svgModel) {
        svgModel = [self loadSVGModelFileNamed:filename];
        STQRYCachedSVGPaths()[filename] = svgModel;
    }
    
    return svgModel;
}

+ (UIImage *)renderSVGModel:(STQRYSVGModel *)svgModel size:(CGSize)size
{
    NSParameterAssert(svgModel);
    
    NSString *cacheKey = STQRYCachedRenderedImagesKey(svgModel, size);
    UIImage *cachedImage = [STQRYCachedRenderedImages() objectForKey:cacheKey];
    if (cachedImage) {
        return cachedImage;
    }
    
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
    [STQRYCachedRenderedImages() setObject:image forKey:cacheKey];
    
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
    
    return [[STQRYSVGModel alloc] initWithName:filename data:[NSData dataWithContentsOfURL:url]];
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
}

@end
