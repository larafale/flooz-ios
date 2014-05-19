//
//  SplashViewController.m
//  Flooz
//
//  Created by jonathan on 2014-05-14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    UIImageView *logo = [UIImageView imageNamed:@"home-logo"];
    CGRectSetXY(logo.frame, (SCREEN_WIDTH - logo.image.size.width) / 2., 100);
    [self.view addSubview:logo];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logo.frame) + 5, SCREEN_WIDTH, 65)];
    text.text = NSLocalizedString(@"SPLASH_TEXT", nil);
    text.font = [UIFont customTitleLight:18];
    text.textColor = [UIColor customPlaceholder];
    text.numberOfLines = 0;
    text.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:text];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

@end
