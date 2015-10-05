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
    
    NSString *imageNamed = @"back-secure";

    logo = [UIImageView imageNamed:imageNamed];
    [logo setContentMode:UIViewContentModeScaleAspectFill];
    [logo setFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight())];
    [self.view addSubview:logo];
    
    title = [UIImageView imageNamed:@"home-title"];
    [title setContentMode:UIViewContentModeScaleAspectFit];
    
    CGFloat scaleFactor = CGRectGetWidth(title.frame) / CGRectGetHeight(title.frame);
    
    CGRectSetWidth(title.frame, PPScreenWidth() - 150);
    CGRectSetHeight(title.frame, CGRectGetWidth(title.frame) / scaleFactor);
    CGRectSetX(title.frame, PPScreenWidth() / 2 - CGRectGetWidth(title.frame) / 2);

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
    
#ifdef FLOOZ_DEV_LOCAL
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"IP Address"
                                                    message:@"Enter custom IP address"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Local", nil];
    alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [[alert textFieldAtIndex:1] setSecureTextEntry:NO];
    [[alert textFieldAtIndex:0] setText:@"172.20.113."];
    [[alert textFieldAtIndex:1] setText:@"3002"];
    [[alert textFieldAtIndex:0] setPlaceholder:@"IP"];
    [[alert textFieldAtIndex:1] setPlaceholder:@"Port"];
    [alert show];
#endif
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0)
        [appDelegate initTestingWithIP:@"dev.flooz.me:80"];
    else
        [appDelegate initTestingWithIP:[NSString stringWithFormat:@"%@:%@", [alertView textFieldAtIndex:0].text, [alertView textFieldAtIndex:1].text]];
}

@end
