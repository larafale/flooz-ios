//
//  FirstLaunchContentViewController.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FirstLaunchContentViewController.h"
#import "FLStartButton.h"
#import "FLStartItem.h"

@interface FirstLaunchContentViewController ()

@end

@implementation FirstLaunchContentViewController

- (void)loadView {
    [super loadView];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    CGRect frame    = [[UIScreen mainScreen] bounds];
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor customBackground];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	[self setContent];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	if ([self.delegate respondsToSelector:@selector(firstLaunchContentViewControllerDidDAppear:)]) {
		[self.delegate firstLaunchContentViewControllerDidDAppear:self];
	}
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setContent
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT - 4, CGRectGetWidth(self.view.frame), 100)];
    label.font = [UIFont customTitleExtraLight:28];
    label.textColor = [UIColor customBlue];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];

    switch (_pageIndex) {
		case 0: {
            label.text = @"Bienvenue sur Flooz";
            FLStartButton *startButton  = [[FLStartButton alloc] initWithFrame:CGRectMake(30, PPScreenHeight() - 60, PPScreenWidth() - 90, 45) title:@"Commencez"];
            [self.view addSubview:startButton];
            
            FLStartItem *item = [FLStartItem newWithTitle:@"friend" imageImageName:@"friend.png" contentText:@"coucou"];
            [self.view addSubview:item];

        }
        break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
