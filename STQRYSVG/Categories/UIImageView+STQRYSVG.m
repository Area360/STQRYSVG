//
//  UIImageView+STQRYSVG.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "UIImageView+STQRYSVG.h"
#import "UIImage+STQRYSVG.h"
#import <objc/runtime.h>

@implementation UIImageView (STQRYSVG)

- (NSString *)svgImageName
{
    return objc_getAssociatedObject(self, @selector(svgImageName));
}

- (void)setSvgImageName:(NSString *)svgImageName
{
    objc_setAssociatedObject(self, @selector(svgImageName), svgImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
    self.image = [UIImage stqry_imageWithSVGNamed:svgImageName size:self.svgImageSize];
}

- (CGSize)svgImageSize
{
    NSValue *svgImageSize = objc_getAssociatedObject(self, @selector(svgImageSize));
    return svgImageSize ? [svgImageSize CGSizeValue] : CGSizeZero;
}

- (void)setSvgImageSize:(CGSize)svgImageSize
{
    objc_setAssociatedObject(self, @selector(svgImageSize), [NSValue valueWithCGSize:svgImageSize], OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (self.svgImageName) {
        self.image = [UIImage stqry_imageWithSVGNamed:self.svgImageName size:svgImageSize];
    }
}

@end
