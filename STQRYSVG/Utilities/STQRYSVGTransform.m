//
//  STQRYSVGTransform.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 16/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "STQRYSVGTransform.h"

STQRYSVGTransformType STQRYSVGTransformTypeFromNSString(NSString *type)
{
    if      ([type isEqualToString:@"matrix"])    return STQRYSVGTransformMatrix;
    else if ([type isEqualToString:@"translate"]) return STQRYSVGTransformTranslate;
    else if ([type isEqualToString:@"scale"])     return STQRYSVGTransformScale;
    else if ([type isEqualToString:@"rotate"])    return STQRYSVGTransformRotate;
    else if ([type isEqualToString:@"skewX"])     return STQRYSVGTransformSkewX;
    else if ([type isEqualToString:@"skewY"])     return STQRYSVGTransformSkewY;
    else                                          return STQRYSVGTransformUnknown;
}

@interface STQRYSVGTransform ()

@end

@implementation STQRYSVGTransform

#pragma mark - Public

+ (instancetype)combinedTransformFromTransformAttributeString:(NSString *)transformString
{
    NSArray *transforms = [self splitTransformArrayStringToComponents:transformString];
    __block CGAffineTransform affineTransform = [[transforms firstObject] affineTransform];
    
    [transforms enumerateObjectsUsingBlock:^(STQRYSVGTransform *transform, NSUInteger idx, BOOL *stop) {
        if (idx > 0) {
            affineTransform = CGAffineTransformConcat(affineTransform, transform.affineTransform);
        }
    }];
    
    return [[self alloc] initWithAffineTransform:affineTransform];
}

- (instancetype)initWithAffineTransform:(CGAffineTransform)transform
{
    self = [self init];
    if (self) {
        _affineTransform = transform;
    }
    return self;
}

- (instancetype)concatenate:(STQRYSVGTransform *)other
{
    return [[[self class] alloc] initWithAffineTransform:CGAffineTransformConcat(self.affineTransform, other.affineTransform)];
}

#pragma mark - Private Helpers

+ (NSArray *)validTransformProperties
{
    return @[@"matrix", @"translate", @"scale", @"rotate", @"skewX", @"skewY"];
}

+ (NSArray *)splitTransformArrayStringToComponents:(NSString *)combinedTransformString
{
    NSMutableArray *transformComponents = [NSMutableArray array];
    NSArray *ranges = [self rangesOfValidTransformPropertiesInTransformString:combinedTransformString];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    
    for (NSValue *transformRangeValue in ranges) {
        NSRange transformRange;
        [transformRangeValue getValue:&transformRange];
        
        NSString *singleTransformString       = [combinedTransformString substringFromIndex:transformRange.location];
        NSUInteger endTransformStringLocation = [combinedTransformString rangeOfString:@")"].location + 1;
        singleTransformString                 = [singleTransformString   substringToIndex:endTransformStringLocation];
        NSUInteger openBracketLocation        = [singleTransformString   rangeOfString:@"("].location;
        NSUInteger closeBracketLocation       = [singleTransformString   rangeOfString:@")"].location;
        NSRange valuesRange = NSMakeRange(openBracketLocation + 1, closeBracketLocation - openBracketLocation - 1);
        
        NSString *typeString = [[singleTransformString substringToIndex:openBracketLocation] stringByTrimmingCharactersInSet:whitespace];
        NSString *valuesString = [singleTransformString substringWithRange:valuesRange];
        
        CGAffineTransform transform = [self parseValueString:valuesString type:STQRYSVGTransformTypeFromNSString(typeString)];
        [transformComponents addObject:[[STQRYSVGTransform alloc] initWithAffineTransform:transform]];
    }
    
    return transformComponents;
}

+ (NSArray *)rangesOfValidTransformPropertiesInTransformString:(NSString *)transformString
{
    NSMutableArray *transforms = [NSMutableArray array];
    
    // Split the transform string into an array of individual transforms.
    for (NSString *transformProperty in self.validTransformProperties) {
        NSRange foundRange;
        NSRange searchRange = NSMakeRange(0, transformString.length);
        while ((foundRange = [transformString rangeOfString:transformProperty options:0 range:searchRange]).location != NSNotFound) {
            NSUInteger startSearchRange = foundRange.location + foundRange.length;
            searchRange = NSMakeRange(startSearchRange, transformString.length - startSearchRange);
            [transforms addObject:[NSValue value:&foundRange withObjCType:@encode(NSRange)]];
        }
    }
    
    // Sort back into order based so each transform is applied in the correct order.
    [transforms sortUsingComparator:^NSComparisonResult(NSValue *t1, NSValue *t2) {
        NSRange r1, r2;
        [t1 getValue:&r1];
        [t2 getValue:&r2];
        return r1.location > r2.location;
    }];
    
    return transforms;
}

+ (CGAffineTransform)parseValueString:(NSString *)valueString type:(STQRYSVGTransformType)type
{
    NSCharacterSet *numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789+-.eE"];
    NSScanner *scanner = [NSScanner scannerWithString:valueString];
    scanner.charactersToBeSkipped = [numberSet invertedSet];
    
    int idx = 0;
    double vals[6] = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
    while (!scanner.isAtEnd && idx < 6) {
        double val;
        if ([scanner scanDouble:&val]) {
            vals[idx++] = val;
        }
    }
    
    switch (type) {
        case STQRYSVGTransformMatrix:
            return CGAffineTransformMake(vals[0], vals[1], vals[2], vals[3], vals[4], vals[5]);
        case STQRYSVGTransformTranslate:
            return CGAffineTransformMakeTranslation(vals[0], vals[1]);
        case STQRYSVGTransformScale:
            if (vals[1] == 0.0)
                vals[1] = vals[0];
            return CGAffineTransformMakeScale(vals[0], vals[1]);
        case STQRYSVGTransformRotate:
            vals[0] = vals[0] * M_PI / 180;
            if (vals[1] == 0.0 && vals[2] == 0.0)
                return CGAffineTransformMakeRotation(vals[0]);
            else
                return CGAffineTransformTranslate(CGAffineTransformRotate(CGAffineTransformMakeTranslation(vals[1], vals[2]), vals[0]), -vals[1], -vals[2]);
        case STQRYSVGTransformSkewX:
            return CGAffineTransformMake(1.0, tan(vals[0]), 0.0, 1.0, 0.0, 0.0);
        case STQRYSVGTransformSkewY:
            return CGAffineTransformMake(1.0, 0.0, tan(vals[0]), 1.0, 0.0, 0.0);
        default:
            return CGAffineTransformIdentity;
    }
}

@end
