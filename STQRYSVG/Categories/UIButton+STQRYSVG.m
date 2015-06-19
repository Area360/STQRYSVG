//
//  UIButton+STQRYSVG.m
//  STQRYSVG
//
//  Created by Daniel Clelland on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "UIButton+STQRYSVG.h"
#import "UIImage+STQRYSVG.h"
#import <objc/runtime.h>

@implementation UIButton (STQRYSVG)

- (NSString *)svgImageName
{
    return objc_getAssociatedObject(self, @selector(svgImageName));
}

- (void)setSvgImageName:(NSString *)svgImageName
{
    objc_setAssociatedObject(self, @selector(svgImageName), svgImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setImage:[UIImage stqry_imageWithSVGNamed:svgImageName size:self.svgImageSize] forState:UIControlStateNormal];
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
      [self setImage:[UIImage stqry_imageWithSVGNamed:self.svgImageName size:svgImageSize] forState:UIControlStateNormal];
    }
}

@end
