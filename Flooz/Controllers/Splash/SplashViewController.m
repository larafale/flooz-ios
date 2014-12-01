//
//  SplashViewController.m
//  Flooz
//
//  Created by Arnaud Lays on 2014-05-14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SplashViewController.h"

@interface SplashViewController () {
	UIImageView *logo;
    UIImageView *title;
    UILabel *waitingLabel;
}

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor customBackground];
    
    NSString *imageNamed = @"LaunchImage";
    if (IS_IPHONE4) {
        imageNamed = [imageNamed stringByAppendingString:@"-iphone4"];
    }
	logo = [UIImageView imageNamed:imageNamed];
	logo.center = self.view.center;
	[self.view addSubview:logo];
    
    title = [UIImageView imageNamed:@"home-title"];
    title.frame = CGRectMake((PPScreenWidth() - CGRectGetWidth(title.frame)) / 2.0f, PPScreenHeight() * 2.0f / 3.0f, CGRectGetWidth(title.frame), CGRectGetHeight(title.frame));
    [self.view addSubview:title];
    
    waitingLabel = [UILabel newWithText:@"chargement..." textColor:[UIColor customBlue] font:[UIFont customTitleBook:18] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    waitingLabel.frame = CGRectMake(0.0f, CGRectGetMaxY(title.frame) + 10.0f, PPScreenWidth(), 50);
    [self.view addSubview:waitingLabel];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[[self navigationController] setNavigationBarHidden:YES animated:YES];
    logo.center = self.view.center;
    CGRectSetY(title.frame, PPScreenHeight() * 2.0f / 3.0f);
    CGRectSetY(waitingLabel.frame, CGRectGetMaxY(title.frame) + 10.0f);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    logo.center = self.view.center;
    CGRectSetY(title.frame, PPScreenHeight() * 2.0f / 3.0f);
    CGRectSetY(waitingLabel.frame, CGRectGetMaxY(title.frame) + 10.0f);
}

@end
