//
//  STQRYSVGModel.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "STQRYSVGModel.h"

@interface STQRYSVGModel ()

@property (nonatomic, copy)   NSArray        *shapes;
@property (nonatomic, strong) NSMutableArray *parsingShapes;
@property (nonatomic, strong) NSMutableArray *groups;

@end

@implementation STQRYSVGModel

#pragma mark - Public

- (instancetype)initWithSVGData:(NSData *)svgData
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:svgData];
    parser.delegate = self;
    
    if ([parser parse]) {
        return self;
    } else {
        NSLog(@"Error parsing SVG XML: %@, Error: %@", [[NSString alloc] initWithData:svgData encoding:NSUTF8StringEncoding], parser.parserError);
        return nil;
    }
}

- (CGPathRef)combinedPathsWithTransform:(CGAffineTransform *)sharedTransform
{
    CGMutablePathRef path = CGPathCreateMutable();
    
    for (STQRYSVGShape *shape in self.shapes) {
        CGAffineTransform transform = [self concatenateTransformsIfNeeded:shape.transform with:sharedTransform];
        CGAffineTransform *transformPtr = CGAffineTransformIsIdentity(transform) ? NULL : &transform;
        
        // Append path.
        if (shape.shouldStroke) {
            CGPathRef strokedPath = [shape strokePathWithTransform:transformPtr];
            CGPathAddPath(path, NULL, strokedPath);
            CGPathRelease(strokedPath);
        } else {
            [shape addToPath:path transform:transformPtr];
        }
    }
    return path;
}

- (void)renderInContext:(CGContextRef)context transform:(CGAffineTransform *)sharedTransform
{
    CGMutablePathRef fillPath = CGPathCreateMutable();
    
    for (STQRYSVGShape *shape in self.shapes) {
        CGAffineTransform transform = [self concatenateTransformsIfNeeded:shape.transform with:sharedTransform];
        CGAffineTransform *transformPtr = CGAffineTransformIsIdentity(transform) ? NULL : &transform;
        
        CGPathRef subpath = [shape pathWithTransform:transformPtr];
        if (shape.shouldStroke) {
            [shape strokePath:subpath inContext:context];
        }
        if (shape.shouldFill) {
            CGPathAddPath(fillPath, NULL, subpath);
        }
    }
    
    CGContextAddPath(context, fillPath);
    
    STQRYSVGShape *shape = [self.shapes firstObject];
    CGContextSetGrayFillColor(context, 0.0, shape.fillOpacity);
    if (shape.usesEvenOddFillRule) {
        CGContextEOFillPath(context);
    } else {
        CGContextFillPath(context);
    }
    CGPathRelease(fillPath);
}

#pragma mark - Private Helper

- (CGAffineTransform)concatenateTransformsIfNeeded:(CGAffineTransform)t1 with:(CGAffineTransform *)t2
{
    return t2 ? CGAffineTransformConcat(t1, *t2) : t1;
}

- (NSDictionary *)combineGroupAttributesFromDictionary:(NSDictionary *)attributes
{
    NSMutableDictionary *sharedAttributes = [[self.groups lastObject] mutableCopy];
    [sharedAttributes addEntriesFromDictionary:attributes];
    return sharedAttributes ?: attributes;
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.parsingShapes = [NSMutableArray array];
    self.groups        = [NSMutableArray array];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.shapes = self.parsingShapes;
    self.parsingShapes = nil;
    self.groups = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"g"] || [elementName isEqualToString:@"svg"]) {
        attributeDict = [self combineGroupAttributesFromDictionary:attributeDict];
        [self.groups addObject:attributeDict];
    } else {
        attributeDict = [self combineGroupAttributesFromDictionary:attributeDict];
        STQRYSVGShape *shape = [STQRYSVGShape svgShapeWithTypeName:elementName attributes:attributeDict];
        if (shape) {
            [self.parsingShapes addObject:shape];
        }
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"g"] || [elementName isEqualToString:@"svg"]) {
        [self.groups removeLastObject];
    }
}

@end
