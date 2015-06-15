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
        transform = [self scaledPath:path toSize:size];
        t = &transform;
        CGPathRelease(path);
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

+ (CGAffineTransform)scaledPath:(CGPathRef)path toSize:(CGSize)targetSize
{
    CGRect boundingRect = CGPathGetPathBoundingBox(path);
    CGFloat scaleFactor = (boundingRect.size.width / boundingRect.size.height > targetSize.width / targetSize.height) ? (targetSize.width / boundingRect.size.width) : (targetSize.height / boundingRect.size.height);
    return CGAffineTransformConcat(CGAffineTransformMakeTranslation(-boundingRect.origin.x, -boundingRect.origin.y), CGAffineTransformMakeScale(scaleFactor, scaleFactor));
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
