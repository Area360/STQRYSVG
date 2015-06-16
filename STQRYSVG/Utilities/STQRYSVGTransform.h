//
//  STQRYSVGTransform.h
//  STQRYSVG
//
//  Created by Jake Bellamy on 16/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(NSInteger, STQRYSVGTransformType) {
    STQRYSVGTransformUnknown,
    STQRYSVGTransformMatrix,
    STQRYSVGTransformTranslate,
    STQRYSVGTransformScale,
    STQRYSVGTransformRotate,
    STQRYSVGTransformSkewX,
    STQRYSVGTransformSkewY
};

STQRYSVGTransformType STQRYSVGTransformTypeFromNSString(NSString *type);

@interface STQRYSVGTransform : NSObject

@property (nonatomic, assign, readonly) CGAffineTransform affineTransform;

+ (instancetype)combinedTransformFromTransformAttributeString:(NSString *)transformString;

- (instancetype)initWithAffineTransform:(CGAffineTransform)transform;

- (instancetype)concatenate:(STQRYSVGTransform *)other;

@end
