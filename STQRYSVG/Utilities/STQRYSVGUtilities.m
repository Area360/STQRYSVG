//
//  STQRYSVGUtilities.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "STQRYSVGUtilities.h"
#import "STQRYSVGModel.h"
#import <CommonCrypto/CommonDigest.h>

static NSMutableDictionary *_cachedSVGPaths;

@implementation STQRYSVGUtilities

+ (CGPathRef)loadSVGFileNamed:(NSString *)filename
{
    NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:@"svg"];
    if (!url) {
        NSLog(@"Could not find file named %@.svg in application's main bundle.", filename);
        return nil;
    }
    
    STQRYSVGModel *svg = [[STQRYSVGModel alloc] initWithSVGData:[NSData dataWithContentsOfURL:url]];
    CGPathRef     path = svg.path;
    [self saveCachedCGPath:path forKey:filename];
    
    return path;
}

+ (CGPathRef)scalePath:(CGPathRef)path toSize:(CGSize)targetSize
{
    CGRect  boundingRect = CGPathGetPathBoundingBox(path);
    CGFloat scaleFactor = (boundingRect.size.width / boundingRect.size.height > targetSize.width / targetSize.height) ? (targetSize.width / boundingRect.size.width) : (targetSize.height / boundingRect.size.height);
    CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleFactor, scaleFactor), CGAffineTransformMakeTranslation(-boundingRect.origin.x, -boundingRect.origin.y));
    return CGPathCreateCopyByTransformingPath(path, &transform);
}

+ (UIImage *)renderPath:(CGPathRef)path size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetGrayFillColor(context, 0.0, 1.0); // Black 100% alpha
    CGContextAddPath(context, path);
    CGContextEOFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
    NSMutableDictionary *cachedPaths = self.cachedSVGPaths;
    for (NSString *key in cachedPaths) {
        CGPathRef path = (__bridge CGPathRef)(cachedPaths[key]);
        [cachedPaths removeObjectForKey:key];
        CGPathRelease(path);
    }
}

+ (NSString *)md5:(NSString *)string
{
    const char *cStr = [string UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), r);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
}

+ (void)saveCachedCGPath:(CGPathRef)path forKey:(NSString *)key
{
    self.cachedSVGPaths[[self md5:key]] = (__bridge id)(path);
}

+ (CGPathRef)cachedCGPathForKey:(NSString *)key
{
    return (__bridge CGPathRef)(self.cachedSVGPaths[[self md5:key]]);
}

@end
