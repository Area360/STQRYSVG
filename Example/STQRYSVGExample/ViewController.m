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

@property (nonatomic, copy) NSArray *svgAssetNames;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.svgAssetNames = @[@"Happyface", @"fb", @"appleLogo", @"star", @"male", @"close", @"location", @"marker", @"recent", @"search", @"walking", @"wheelchair"];
    self.imageView.svgImageName = [self.svgAssetNames firstObject];
}

- (IBAction)nextBarButtonPressed:(UIBarButtonItem *)sender
{
    NSUInteger currentIndex = [self.svgAssetNames indexOfObject:self.imageView.svgImageName];
    
    // Wrap back to 0 once end of array has been reached.
    NSUInteger nextIndex = currentIndex + 1 >= self.svgAssetNames.count ? 0 : currentIndex + 1;
    
    self.imageView.svgImageName = self.svgAssetNames[nextIndex];
}

@end
