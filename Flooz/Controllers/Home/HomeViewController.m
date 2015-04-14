//
//  HomeViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "HomeViewController.h"

#import "AppDelegate.h"
#import "TransactionViewController.h"
#import "FLSlide.h"

@interface HomeViewController () {
    UITableView *_tableView;
    
    UIView *_mainView;
    UIView *_footerView;
    
    UIImageView *logo;
    FLActionButton *couponButton;
}

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    {
        UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        [backgroundImage setImage:[UIImage imageNamed:@"back-secure"]];
        [self.view addSubview:backgroundImage];
    }
    
    {
        _mainView = [UIView newWithFrame:CGRectMake(0, STATUSBAR_HEIGHT, PPScreenWidth(), PPScreenHeight() - 150.0f - STATUSBAR_HEIGHT)];
        [self.view addSubview:_mainView];
    }
    
    [self createMainView];
    
    {
        _footerView = [UIView newWithFrame:CGRectMake(0, CGRectGetMaxY(_mainView.frame), PPScreenWidth(), PPScreenHeight() - CGRectGetMaxY(_mainView.frame))];
        [self.view addSubview:_footerView];
    }
    
    [self createButtonSend];
    
    [[Flooz sharedInstance] textObjectFromApi:^(id result) {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"IntroSliders"])
            [self showIntro];
        [self generateCouponButton];
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createMainView {
    logo = [[UIImageView alloc] initWithImageName:@"home-title"];
    [logo setFrame:CGRectMake(SCREEN_WIDTH / 2 - CGRectGetWidth(logo.frame) / 2, 60, CGRectGetWidth(logo.frame), CGRectGetHeight(logo.frame))];
    [logo setContentMode:UIViewContentModeScaleAspectFit];
    
    [logo addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showIntro)]];
    [logo setUserInteractionEnabled:YES];
    
    [_mainView addSubview:logo];
}

- (void)createButtonSend {
    
    FLActionButton *signupButton = [[FLActionButton alloc] initWithFrame:CGRectMake(50, 5, CGRectGetWidth(_footerView.frame) - 100, 50) title:NSLocalizedString(@"Signup", nil)];
    signupButton.layer.masksToBounds = YES;
    signupButton.layer.cornerRadius = 25;
    
    [signupButton setBackgroundColor:[UIColor customBackgroundHeader] forState:UIControlStateNormal];
    [signupButton setBackgroundColor:[UIColor customBlue] forState:UIControlStateHighlighted];
    [signupButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signupButton.titleLabel setFont:[UIFont customTitleLight:20]];
    
    [signupButton addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *loginButton = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(signupButton.frame) + 20, CGRectGetWidth(_footerView.frame) - 100, 30)];
    loginButton.backgroundColor = [UIColor clearColor];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle), NSForegroundColorAttributeName: [UIColor customGreyPseudo]};
    
    [loginButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Login", nil) attributes:underlineAttribute] forState:UIControlStateNormal];
    
    [loginButton.titleLabel setFont:[UIFont customTitleLight:16]];
    
    [loginButton addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
    
    [_footerView addSubview:signupButton];
    [_footerView addSubview:loginButton];
}

- (void)generateCouponButton {
    NSDictionary *couponButtonData = [Flooz sharedInstance].currentTexts.couponButton;
    
    if (couponButtonData != nil) {
        if (couponButton == nil) {
            couponButton = [[FLActionButton alloc] initWithFrame:CGRectMake(50, CGRectGetHeight(_mainView.frame) - 70, CGRectGetWidth(_mainView.frame) - 100, 50)];
            couponButton.layer.masksToBounds = YES;
            couponButton.layer.cornerRadius = 25;
            
            [couponButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [couponButton.titleLabel setFont:[UIFont customTitleLight:20]];
            
            [couponButton addTarget:self action:@selector(connectWithCoupon) forControlEvents:UIControlEventTouchUpInside];
            [_mainView addSubview:couponButton];
        }
        
        [couponButton setTitle:couponButtonData[@"text"] forState:UIControlStateNormal];
        
        if (couponButtonData[@"icon"] && ![couponButtonData[@"icon"] isBlank])
            [couponButton setImageWithURL:couponButtonData[@"icon"] size:CGSizeMake(20, 20)];
        
        [couponButton setBackgroundColor:[UIColor colorWithHexString:couponButtonData[@"bgcolor"]] forState:UIControlStateNormal];
        [couponButton setBackgroundColor:[[UIColor colorWithHexString:couponButtonData[@"bgcolor"]] colorWithAlphaComponent:0.5f] forState:UIControlStateHighlighted];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - button action

- (void)connect {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"IntroSliders"];
    [appDelegate displaySignin:nil];
}

- (void)connectWithCoupon {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"IntroSliders"];
    [appDelegate displaySignin:[Flooz sharedInstance].currentTexts.couponButton[@"coupon"]];
}

- (void)showIntro {
    FLSlider *slider = [Flooz sharedInstance].currentTexts.slider;
    if (slider && slider.slides.count > 0) {
        NSMutableArray *slides = [NSMutableArray new];
        
        EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:slides];
        
        [[slider.slides lastObject] enableLastPageConfig:intro];
        
        for (FLSlide *slide in slider.slides) {
            [slides addObject:slide.page];
        }
        
        [intro setPages:slides];
        [intro setDelegate:self];
        [intro setSkipButtonAlignment:EAViewAlignmentRight];
        [intro setSkipButtonY:SCREEN_HEIGHT - 10];
        [intro setSkipButtonSideMargin:20];
        [intro.skipButton.titleLabel setFont:[UIFont customTitleLight:17]];
        [intro.skipButton setTitle:NSLocalizedString(@"Skip", @"Skip") forState:UIControlStateNormal];
        [intro setUseMotionEffects:YES];
        [intro setTapToNext:YES];
        [intro setEaseOutCrossDisolves:YES];
        
        [intro showInView:self.view animateDuration:0.3];
    }
}

#pragma mark - EAIntroView delegate

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSUInteger)pageIndex {
    if (pageIndex == 0)
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)introDidFinish:(EAIntroView *)introView {
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

@end
