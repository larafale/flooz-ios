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
    logo.center = self.view.center;
    [self.view addSubview:logo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

@end
