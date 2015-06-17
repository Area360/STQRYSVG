//
//  ViewController.m
//  STQRYSVGExample
//
//  Created by Jake Bellamy on 15/06/15.
//  Copyright (c) 2015 STQRY. All rights reserved.
//

#import "ViewController.h"
#import <UIImageView+STQRYSVG.h>

@interface ViewController ()

@property (nonatomic, copy, readonly) NSArray *svgAssetNames;

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation ViewController

- (NSArray *)svgAssetNames
{
    return @[@"Happyface", @"fb", @"appleLogo", @"star", @"male", @"atom", @"close", @"location", @"marker", @"recent", @"search", @"walking", @"wheelchair", @"polyline"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self displaySVGAtIndex:0];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.imageView.svgImageSize = self.imageView.bounds.size;
}

- (IBAction)nextBarButtonPressed:(UIBarButtonItem *)sender
{
    NSUInteger currentIndex = [self.svgAssetNames indexOfObject:self.imageView.svgImageName];
    
    // Wrap back to 0 once end of array has been reached.
    NSUInteger nextIndex = currentIndex + 1 >= self.svgAssetNames.count ? 0 : currentIndex + 1;
    
    [self displaySVGAtIndex:nextIndex];
}

- (void)displaySVGAtIndex:(NSUInteger)index
{
    NSString *svgName = self.svgAssetNames[index];
    
    // Image view
    self.imageView.svgImageName = svgName;
    
    // Web view
    NSURL *url = [[NSBundle mainBundle] URLForResource:svgName withExtension:@"svg"];
    NSString *svgString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:svgString baseURL:nil];
}


@end
