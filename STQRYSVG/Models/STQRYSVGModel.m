//
//  STQRYSVGModel.m
//  STQRYSVG
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "STQRYSVGModel.h"
#import "STQRYSVGShape.h"

@interface STQRYSVGModel ()

@property (nonatomic, copy)   NSArray        *shapes;
@property (nonatomic, strong) NSMutableArray *parsingShapes;

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

- (CGPathRef)path
{
    CGMutablePathRef path = CGPathCreateMutable();
    for (STQRYSVGShape *shape in self.shapes) {
        [shape addToPath:path];
    }
    return path;
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.parsingShapes = [NSMutableArray array];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    self.shapes = self.parsingShapes;
    self.parsingShapes = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    STQRYSVGShape *shape = [STQRYSVGShape svgShapeWithTypeName:elementName attributes:attributeDict];
    if (shape) {
        [self.parsingShapes addObject:shape];
    }
}

@end
