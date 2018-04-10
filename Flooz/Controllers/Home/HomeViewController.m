//
//  HomeViewController.m
//  Flooz
//
//  Created by Olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "HomeViewController.h"

#import "AppDelegate.h"
#import "TransactionViewController.h"
#import "FLSlide.h"
#import "FXBlurView.h"
#import "WebViewController.h"
#import "FLPhoneField.h"

@interface HomeViewController () {
    UIView *backgroundView;
    UIView *homeView;
    FXBlurView *loginView;
    FXBlurView *signupView;
    FXBlurView *forgetView;
    
    iCarousel *carouselView;
    UIPageControl *carouselControl;
    UIImageView *backgroundImage;
    
    NSMutableDictionary *loginData;
    NSMutableDictionary *signupData;
    NSMutableDictionary *forgetData;
    NSMutableDictionary *secretData;
    
    UIView *loginHeaderView;
    UIView *loginFormView;
    
    UIScrollView *signupScrollView;
    UIView *signupHeaderView;
    UIView *signupFormView;
    UIView *signupFbView;
    UIView *signupFbPicView;
    
    FLPhoneField *signupPhoneField;

    NSMutableArray *signupFormFields;
    
    UILabel *secretQuestion;
    
    UIButton *clearSponsorField;
    
    BOOL keyboardVisible;
    BOOL loginVisible;
    BOOL signupVisible;
    BOOL homeVisible;
    BOOL facebookVisible;
    BOOL facebookPicVisible;
    
    BOOL sponsorVisible;
    
    NSTimer *carouselTimer;
}

@end

#define CAROUSEL_AUTOSLIDE_TIMER 4.0f

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        keyboardVisible = NO;
        loginVisible = NO;
        signupVisible = NO;
        homeVisible = YES;
        facebookVisible = YES;
        facebookPicVisible = NO;
        sponsorVisible = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[Flooz sharedInstance] textObjectFromApi:^(id result) {
        [carouselControl setNumberOfPages:[Flooz sharedInstance].currentTexts.slider.slides.count];
        [carouselView reloadData];
        carouselTimer = [NSTimer scheduledTimerWithTimeInterval:CAROUSEL_AUTOSLIDE_TIMER target:self selector:@selector(changeCurrentCarouselPage) userInfo:nil repeats:NO];
        
        if ([Flooz sharedInstance].currentTexts.signupSponsor && [Flooz sharedInstance].currentTexts.signupSponsor.length) {
            sponsorVisible = YES;
            
            [signupView removeFromSuperview];
            [self createSignupView];

            for (FLTextFieldSignup *textfield in signupFormFields) {
                if ([textfield.dictionaryKey isEqualToString:@"sponsor"]) {
                    [textfield setPlaceholder:[Flooz sharedInstance].currentTexts.signupSponsor forTextField:1];
                    break;
                }
            }
            [signupPhoneField reloadTextField];
        } else {
            sponsorVisible = NO;
        }
    } failure:nil];
    
    [self createBackgroundView];
    [self createHomeView];
    [self createLoginView];
    [self createSignupView];
    [self createForgetView];
    
    [self registerForKeyboardNotifications];
    
    if ([appDelegate branchParam]) {
        if ([appDelegate branchParam][@"cactus"] && [[appDelegate branchParam][@"cactus"] length]) {
            [[Flooz sharedInstance] loadCactusData:[appDelegate branchParam][@"cactus"] success:^(NSDictionary *result) {
                [signupData addEntriesFromDictionary:result[@"item"]];
                for (FLTextFieldSignup *textfield in signupFormFields) {
                    [textfield reloadTextField];
                }
                [signupPhoneField reloadTextField];
            } failure:^(NSError *error) {
                
            }];
        }
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - views creation

- (void)createBackgroundView {
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight())];
    
    backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(backgroundView.frame), CGRectGetHeight(backgroundView.frame))];
    [backgroundImage setImage:[UIImage imageNamed:@"back-secure"]];
    
    [backgroundView addSubview:backgroundImage];
    
    [self.view addSubview:backgroundView];
}

- (void)createHomeView {
    
    CGFloat carouselHorizontalMargin = 30;
    CGFloat carouselTopMargin = 40;
    CGFloat logoTopMargin = 60;
    CGFloat actionButtonHeight = FLActionButtonDefaultHeight;
    CGFloat actionHorizontalMargin = 30;
    CGFloat actionVerticalMargin = 40;
    
    homeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight())];
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-title"]];
    [logoView setContentMode:UIViewContentModeScaleAspectFit];
    
    CGFloat scaleFactor = CGRectGetWidth(logoView.frame) / CGRectGetHeight(logoView.frame);
    
    CGRectSetWidth(logoView.frame, CGRectGetWidth(homeView.frame) - 150);
    CGRectSetHeight(logoView.frame, CGRectGetWidth(logoView.frame) / scaleFactor);
    
    CGRectSetX(logoView.frame, CGRectGetWidth(homeView.frame) / 2 - CGRectGetWidth(logoView.frame) / 2);
    CGRectSetY(logoView.frame, logoTopMargin);
    
    CGFloat carouselHeight = CGRectGetHeight(homeView.frame);
    carouselHeight -=  CGRectGetMaxY(logoView.frame);
    carouselHeight -=  carouselTopMargin;
    carouselHeight -=  (2 * actionVerticalMargin + actionButtonHeight) + 20;
    
    carouselView = [[iCarousel alloc] initWithFrame:CGRectMake(carouselHorizontalMargin, CGRectGetMaxY(logoView.frame) + carouselTopMargin, CGRectGetWidth(homeView.frame) - carouselHorizontalMargin * 2, carouselHeight)];
    [carouselView setDelegate:self];
    [carouselView setDataSource:self];
    [carouselView setType:iCarouselTypeLinear];
    [carouselView setScrollEnabled:YES];
    [carouselView setPagingEnabled:YES];
    
    carouselControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(carouselView.frame), CGRectGetWidth(homeView.frame), 20)];
    [carouselControl addTarget:self action:@selector(updatePage:) forControlEvents:UIControlEventValueChanged];
    [carouselControl setHidesForSinglePage:YES];
    [carouselControl setNumberOfPages:0];
    [carouselControl setCurrentPage:0];
    
    if ([Flooz sharedInstance].currentTexts)
        [carouselControl setNumberOfPages:[Flooz sharedInstance].currentTexts.slider.slides.count];

    FLActionButton *loginHomeButton = [[FLActionButton alloc] initWithFrame:CGRectMake(actionHorizontalMargin, CGRectGetMaxY(carouselControl.frame) + actionVerticalMargin, CGRectGetWidth(homeView.frame) / 2 - 1.5 * actionHorizontalMargin, actionButtonHeight) title:[NSLocalizedString(@"GLOBAL_LOGIN", nil) uppercaseString]];
    [loginHomeButton.titleLabel setFont:[UIFont customContentRegular:15]];
    [loginHomeButton addTarget:self action:@selector(didLoginHomeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    FLActionButton *signupHomeButton = [[FLActionButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(homeView.frame) / 2 + actionHorizontalMargin / 2, CGRectGetMaxY(carouselControl.frame) + actionVerticalMargin, CGRectGetWidth(homeView.frame) / 2 - 1.5 * actionHorizontalMargin, actionButtonHeight) title:[NSLocalizedString(@"GLOBAL_SIGNUP", nil) uppercaseString]];
    [signupHomeButton.titleLabel setFont:[UIFont customContentRegular:15]];
    [signupHomeButton addTarget:self action:@selector(didSignupHomeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [homeView addSubview:logoView];
    [homeView addSubview:carouselView];
    [homeView addSubview:carouselControl];
    [homeView addSubview:loginHomeButton];
    [homeView addSubview:signupHomeButton];
    
    [self.view addSubview:homeView];
}

- (void)createLoginView {
    
    CGFloat titleTopMargin = 15;
    CGFloat facebookTopMargin = 40;
    CGFloat loginHorizontalMargin = 30;
    CGFloat separatorVerticalMargin = 30;
    
    loginData = [NSMutableDictionary new];
    
    loginView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight())];
    [loginView setHidden:YES];
    [loginView setDynamic:NO];
    [loginView setBlurRadius:10];
    [loginView setTintColor:[UIColor clearColor]];
    [loginView setUnderlyingView:backgroundView];
    
    UIButton *loginBackButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 40, 40)];
    [loginBackButton setContentMode:UIViewContentModeScaleAspectFit];
    [loginBackButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
    [loginBackButton addTarget:self action:@selector(didLoginBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *loginTitle = [[UILabel alloc] initWithText:NSLocalizedString(@"WELCOME_BACK", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleLight:25] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    
    CGRectSetX(loginTitle.frame, CGRectGetWidth(loginView.frame) / 2 - CGRectGetWidth(loginTitle.frame) / 2);
    CGRectSetY(loginTitle.frame, titleTopMargin);
    
    FLActionButton *facebookLoginButton = [[FLActionButton alloc] initWithFrame:CGRectMake(loginHorizontalMargin, CGRectGetMaxY(loginTitle.frame) + facebookTopMargin, CGRectGetWidth(loginView.frame) - loginHorizontalMargin * 2, FLActionButtonDefaultHeight)];
    
    [facebookLoginButton setTitle:NSLocalizedString(@"LOGIN_FACEBOOK", nil) forState:UIControlStateNormal];
    [facebookLoginButton.titleLabel setFont:[UIFont customTitleExtraLight:17]];
    [facebookLoginButton setBackgroundColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.6] forState:UIControlStateNormal];
    [facebookLoginButton setBackgroundColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.3]  forState:UIControlStateDisabled];
    [facebookLoginButton setBackgroundColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.3]  forState:UIControlStateHighlighted];
    [facebookLoginButton setImage:[UIImage imageNamed:@"facebook"] size:CGSizeMake(16.0f, 16.0f)];
    
    [facebookLoginButton addTarget:self action:@selector(didFacebookLoginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(loginHorizontalMargin, CGRectGetMaxY(facebookLoginButton.frame) + separatorVerticalMargin, CGRectGetWidth(loginView.frame) - loginHorizontalMargin * 2, 20)];
    
    {
        UILabel *separatorLabel = [[UILabel alloc] initWithText:[NSLocalizedString(@"GLOBAL_OR", nil) uppercaseString] textColor:[UIColor customPlaceholder] font:[UIFont customContentLight:12] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        CGRectSetX(separatorLabel.frame, CGRectGetWidth(separatorView.frame) / 2 - CGRectGetWidth(separatorLabel.frame) / 2);
        CGRectSetY(separatorLabel.frame, CGRectGetHeight(separatorView.frame) / 2 - CGRectGetHeight(separatorLabel.frame) / 2);
        
        UIView *leftSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(separatorView.frame) / 2 - CGRectGetWidth(separatorLabel.frame) / 2 - 10, 0.5)];
        [leftSeparator setBackgroundColor:[UIColor customPlaceholder]];
        
        UIView *rightSeparator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(separatorView.frame) / 2 + CGRectGetWidth(separatorLabel.frame) / 2 + 10, 10, CGRectGetWidth(separatorView.frame) / 2 - CGRectGetWidth(separatorLabel.frame) / 2 - 10, 0.5)];
        [rightSeparator setBackgroundColor:[UIColor customPlaceholder]];
        
        [separatorView addSubview:separatorLabel];
        [separatorView addSubview:leftSeparator];
        [separatorView addSubview:rightSeparator];
    }
    
    loginHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(loginView.frame), CGRectGetMaxY(separatorView.frame))];
    
    [loginHeaderView addSubview:loginTitle];
    [loginHeaderView addSubview:facebookLoginButton];
    [loginHeaderView addSubview:separatorView];
    
    FLPhoneField *loginPhoneField = [[FLPhoneField alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_PHONE", @"") for:loginData frame:CGRectMake(loginHorizontalMargin, separatorVerticalMargin, CGRectGetWidth(loginView.frame) - 2 * loginHorizontalMargin, 40)];
    
    FLTextFieldSignup *passwordTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_PASSWORD_LOGIN", @"") for:loginData key:@"password" position:CGPointMake(loginHorizontalMargin, CGRectGetMaxY(loginPhoneField.frame) + 10)];
    [passwordTextfield seTsecureTextEntry:YES];
    
    [loginPhoneField addForNextClickTarget:passwordTextfield action:@selector(becomeFirstResponder)];
    [passwordTextfield addForNextClickTarget:passwordTextfield action:@selector(resignFirstResponder)];
    
    FLActionButton *loginButton = [[FLActionButton alloc] initWithFrame:CGRectMake(loginHorizontalMargin, CGRectGetMaxY(passwordTextfield.frame) + 30, CGRectGetWidth(loginView.frame) - loginHorizontalMargin * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"GLOBAL_LOGIN", nil)];
    [loginButton addTarget:self action:@selector(didLoginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *forgotPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(loginHorizontalMargin, CGRectGetMaxY(loginButton.frame) + 15, CGRectGetWidth(loginView.frame) - loginHorizontalMargin * 2, 15)];
    [forgotPasswordButton setTitle:NSLocalizedString(@"LOGIN_PASSWORD_FORGOT", nil) forState:UIControlStateNormal];
    [forgotPasswordButton.titleLabel setFont:[UIFont customContentLight:14]];
    [forgotPasswordButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    [forgotPasswordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [forgotPasswordButton addTarget:self action:@selector(didForgotPasswordButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    loginFormView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(loginHeaderView.frame), CGRectGetWidth(loginView.frame), CGRectGetMaxY(forgotPasswordButton.frame) + separatorVerticalMargin)];
    [loginFormView addSubview:loginPhoneField];
    [loginFormView addSubview:passwordTextfield];
    [loginFormView addSubview:loginButton];
    [loginFormView addSubview:forgotPasswordButton];
    
    [loginView addSubview:loginHeaderView];
    [loginView addSubview:loginFormView];
    [loginView addSubview:loginBackButton];
    
    [self.view addSubview:loginView];
}

- (void)createSignupView {
    
    CGFloat titleTopMargin = 15;
    CGFloat facebookTopMargin = 40;
    CGFloat signupHorizontalMargin = 30;
    CGFloat separatorVerticalMargin = 20;
    CGFloat signupFormVerticalMargin = 10;
    
    signupData = [NSMutableDictionary new];
    signupFormFields = [NSMutableArray new];
    
    signupView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight())];
    [signupView setDynamic:NO];
    [signupView setBlurRadius:10];
    [signupView setTintColor:[UIColor clearColor]];
    [signupView setUnderlyingView:backgroundView];
    
    [signupView setHidden:!signupVisible];
    
    signupScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight())];
    [signupScrollView setContentSize:CGSizeMake(CGRectGetWidth(signupView.frame), CGRectGetHeight(signupView.frame))];

    if (!IS_IPHONE_4)
        [signupScrollView setScrollEnabled:NO];

    [signupScrollView setBounces:NO];
    
    UIButton *signupBackButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 40, 40)];
    [signupBackButton setContentMode:UIViewContentModeScaleAspectFit];
    [signupBackButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
    [signupBackButton addTarget:self action:@selector(didSignupBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *loginTitle = [[UILabel alloc] initWithText:NSLocalizedString(@"WELCOME", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleLight:25] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [loginTitle setTag:10];
    
    CGRectSetX(loginTitle.frame, CGRectGetWidth(signupView.frame) / 2 - CGRectGetWidth(loginTitle.frame) / 2);
    CGRectSetY(loginTitle.frame, titleTopMargin);
    
    signupHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(signupScrollView.frame), CGRectGetMaxY(loginTitle.frame))];
    
    [signupHeaderView addSubview:signupBackButton];
    [signupHeaderView addSubview:loginTitle];
    
    FLActionButton *facebookSignupButton = [[FLActionButton alloc] initWithFrame:CGRectMake(signupHorizontalMargin, facebookTopMargin, CGRectGetWidth(loginView.frame) - signupHorizontalMargin * 2, FLActionButtonDefaultHeight)];
    
    [facebookSignupButton setTitle:NSLocalizedString(@"LOGIN_FACEBOOK", nil) forState:UIControlStateNormal];
    [facebookSignupButton.titleLabel setFont:[UIFont customTitleExtraLight:17]];
    [facebookSignupButton setBackgroundColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.6] forState:UIControlStateNormal];
    [facebookSignupButton setBackgroundColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.3]  forState:UIControlStateDisabled];
    [facebookSignupButton setBackgroundColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.3]  forState:UIControlStateHighlighted];
    [facebookSignupButton setImage:[UIImage imageNamed:@"facebook"] size:CGSizeMake(16.0f, 16.0f)];
    
    [facebookSignupButton addTarget:self action:@selector(didFacebookSignupButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(signupHorizontalMargin, CGRectGetMaxY(facebookSignupButton.frame) + separatorVerticalMargin, CGRectGetWidth(loginView.frame) - signupHorizontalMargin * 2, 20)];
    
    {
        UILabel *separatorLabel = [[UILabel alloc] initWithText:[NSLocalizedString(@"GLOBAL_OR", nil) uppercaseString] textColor:[UIColor customPlaceholder] font:[UIFont customContentLight:12] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        CGRectSetX(separatorLabel.frame, CGRectGetWidth(separatorView.frame) / 2 - CGRectGetWidth(separatorLabel.frame) / 2);
        CGRectSetY(separatorLabel.frame, CGRectGetHeight(separatorView.frame) / 2 - CGRectGetHeight(separatorLabel.frame) / 2);
        
        UIView *leftSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(separatorView.frame) / 2 - CGRectGetWidth(separatorLabel.frame) / 2 - 10, 0.5)];
        [leftSeparator setBackgroundColor:[UIColor customPlaceholder]];
        
        UIView *rightSeparator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(separatorView.frame) / 2 + CGRectGetWidth(separatorLabel.frame) / 2 + 10, 10, CGRectGetWidth(separatorView.frame) / 2 - CGRectGetWidth(separatorLabel.frame) / 2 - 10, 0.5)];
        [rightSeparator setBackgroundColor:[UIColor customPlaceholder]];
        
        [separatorView addSubview:separatorLabel];
        [separatorView addSubview:leftSeparator];
        [separatorView addSubview:rightSeparator];
    }
    
    signupFbView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(signupHeaderView.frame), CGRectGetWidth(signupScrollView.frame), CGRectGetMaxY(separatorView.frame))];
    
    [signupFbView addSubview:facebookSignupButton];
    [signupFbView addSubview:separatorView];
    
    CGFloat size = 60;
    FLUserView *picView = [[FLUserView alloc] initWithFrame:CGRectMake(((CGRectGetWidth(signupView.frame) - size) / 2.0) - 5.0f, signupFormVerticalMargin, size, size)];
    [picView setTag:42];
    [picView setContentMode:UIViewContentModeScaleAspectFit];
    
    signupFbPicView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(signupHeaderView.frame), CGRectGetWidth(signupView.frame), CGRectGetMaxY(picView.frame))];
    [signupFbPicView setHidden:YES];
    
    [signupFbPicView addSubview:picView];
    
    FLTextFieldSignup *fullnameTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_LASTNAME", @"") for:signupData key:@"lastName" position:CGPointMake(signupHorizontalMargin, separatorVerticalMargin / 2) placeholder2:NSLocalizedString(@"FIELD_FIRSTNAME", @"") key2:@"firstName"];
    [fullnameTextfield addForNextClickTarget:self action:@selector(signupTextFieldNext)];
    
    CGRectSetX(fullnameTextfield.frame, (CGRectGetWidth(signupScrollView.frame) - CGRectGetWidth(fullnameTextfield.frame)) / 2);
    
    FLTextFieldSignup *usernameTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_USERNAME", @"") for:signupData key:@"nick" position:CGPointMake(signupHorizontalMargin, CGRectGetMaxY(fullnameTextfield.frame) + signupFormVerticalMargin)];
    [usernameTextfield addForNextClickTarget:self action:@selector(signupTextFieldNext)];
    
    CGRectSetX(usernameTextfield.frame, (CGRectGetWidth(signupScrollView.frame) - CGRectGetWidth(usernameTextfield.frame)) / 2);
    
    signupPhoneField = [[FLPhoneField alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_PHONE", @"") for:signupData frame:CGRectMake(signupHorizontalMargin, CGRectGetMaxY(usernameTextfield.frame) + signupFormVerticalMargin, CGRectGetWidth(signupScrollView.frame) - 2 * signupHorizontalMargin, CGRectGetHeight(usernameTextfield.frame))];
    [signupPhoneField addForNextClickTarget:self action:@selector(signupTextFieldNext)];
    
    CGRectSetX(signupPhoneField.frame, (CGRectGetWidth(signupScrollView.frame) - CGRectGetWidth(signupPhoneField.frame)) / 2);
    
    FLTextFieldSignup *emailTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_EMAIL", @"") for:signupData key:@"email" position:CGPointMake(signupHorizontalMargin, CGRectGetMaxY(signupPhoneField.frame) + signupFormVerticalMargin)];
    [emailTextfield addForNextClickTarget:self action:@selector(signupTextFieldNext)];
    
    CGRectSetX(emailTextfield.frame, (CGRectGetWidth(signupScrollView.frame) - CGRectGetWidth(emailTextfield.frame)) / 2);

    FLTextFieldSignup *birthdateTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_BIRTHDATE", @"") for:signupData key:@"birthdate" position:CGPointMake(signupHorizontalMargin, CGRectGetMaxY(emailTextfield.frame) + signupFormVerticalMargin)];
    [birthdateTextfield addForNextClickTarget:self action:@selector(signupTextFieldNext)];
    
    CGRectSetX(birthdateTextfield.frame, (CGRectGetWidth(signupScrollView.frame) - CGRectGetWidth(birthdateTextfield.frame)) / 2);
    
    FLTextFieldSignup *passwordTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_PASSWORD", @"") for:signupData key:@"password" position:CGPointMake(signupHorizontalMargin, CGRectGetMaxY(birthdateTextfield.frame) + signupFormVerticalMargin)];
    [passwordTextfield seTsecureTextEntry:YES];
    [passwordTextfield addForNextClickTarget:self action:@selector(signupTextFieldNext)];
    
    CGRectSetX(passwordTextfield.frame, (CGRectGetWidth(signupScrollView.frame) - CGRectGetWidth(passwordTextfield.frame)) / 2);
    
    FLTextFieldSignup *sponsorTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_SPONSOR", @"") for:signupData key:@"sponsor" position:CGPointMake(signupHorizontalMargin, CGRectGetMaxY(passwordTextfield.frame) + signupFormVerticalMargin)];
    [sponsorTextfield addForNextClickTarget:self action:@selector(signupTextFieldNext)];
    [sponsorTextfield addForTextChangeTarget:self action:@selector(signupSponsorChange)];
    [sponsorTextfield setHidden:!sponsorVisible];
    
    CGRectSetX(sponsorTextfield.frame, (CGRectGetWidth(signupScrollView.frame) - CGRectGetWidth(sponsorTextfield.frame)) / 2);
    
    clearSponsorField = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(sponsorTextfield.frame) - 25, CGRectGetHeight(sponsorTextfield.frame) / 2 - 10, 20, 20)];
    [clearSponsorField setContentMode:UIViewContentModeScaleAspectFit];
    [clearSponsorField setTintColor:[UIColor customPlaceholder]];
    [clearSponsorField setImage:[[UIImage imageNamed:@"close-activities"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [clearSponsorField addTarget:self action:@selector(didClearSponsorButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [clearSponsorField setHidden:YES];
    
    [sponsorTextfield addSubview:clearSponsorField];

    CGFloat offsetY;
    
    if (sponsorVisible)
        offsetY = CGRectGetMaxY(sponsorTextfield.frame);
    else
        offsetY = CGRectGetMaxY(passwordTextfield.frame);
    
    FLActionButton *signupButton = [[FLActionButton alloc] initWithFrame:CGRectMake(signupHorizontalMargin, offsetY + signupFormVerticalMargin, CGRectGetWidth(loginView.frame) - signupHorizontalMargin * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"GLOBAL_SIGNUP", nil)];
    [signupButton setTag:89];
    [signupButton addTarget:self action:@selector(didSignupButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    TTTAttributedLabel *tttLabel = [TTTAttributedLabel newWithFrame:CGRectMake(signupHorizontalMargin, CGRectGetMaxY(signupButton.frame) + signupFormVerticalMargin, CGRectGetWidth(loginView.frame) - signupHorizontalMargin * 2, 45)];
    {
        NSString *labelText = NSLocalizedString(@"SIGNUP_READ_CGU", @"");
        [tttLabel setNumberOfLines:0];
        [tttLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [tttLabel setTextAlignment:NSTextAlignmentCenter];
        [tttLabel setTextColor:[UIColor customPlaceholder]];
        [tttLabel setFont:[UIFont customTitleExtraLight:13]];
        NSRange CGURange = [labelText rangeOfString:NSLocalizedString(@"SIGNUP_READ_CGU", @"")];
        [tttLabel setText:labelText afterInheritingLabelAttributesAndConfiguringWithBlock: ^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            
            return mutableAttributedString;
        }];
        [tttLabel sizeToFit];
        [tttLabel setTag:90];
        [tttLabel setLinkAttributes:@{ NSForegroundColorAttributeName : [UIColor customPlaceholder] }];
        [tttLabel addLinkToURL:[NSURL URLWithString:@"action://show-CGU"] withRange:CGURange];
        [tttLabel setDelegate:self];
        CGRectSetX(tttLabel.frame, (CGRectGetWidth(signupScrollView.frame) - CGRectGetWidth(tttLabel.frame)) / 2);
    }
    
    signupFormView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(signupFbView.frame), CGRectGetWidth(signupScrollView.frame), CGRectGetMaxY(tttLabel.frame))];
    
    [signupFormFields addObject:fullnameTextfield];
    [signupFormFields addObject:usernameTextfield];
    [signupFormFields addObject:emailTextfield];
    [signupFormFields addObject:birthdateTextfield];
    [signupFormFields addObject:passwordTextfield];
    [signupFormFields addObject:sponsorTextfield];
    
    [signupFormView addSubview:fullnameTextfield];
    [signupFormView addSubview:usernameTextfield];
    [signupFormView addSubview:signupPhoneField];
    [signupFormView addSubview:emailTextfield];
    [signupFormView addSubview:birthdateTextfield];
    [signupFormView addSubview:passwordTextfield];
    [signupFormView addSubview:sponsorTextfield];
    [signupFormView addSubview:signupButton];
    [signupFormView addSubview:tttLabel];
    
    [signupScrollView addSubview:signupFbPicView];
    [signupScrollView addSubview:signupHeaderView];
    [signupScrollView addSubview:signupFbView];
    [signupScrollView addSubview:signupFormView];
    
    [signupScrollView setContentSize:CGSizeMake(CGRectGetWidth(signupView.frame), CGRectGetMaxY(signupFormView.frame) + 10)];
    
    [signupView addSubview:signupScrollView];
    
    [self.view addSubview:signupView];
}

- (void)createForgetView {
    CGFloat titleTopMargin = 15;
    CGFloat forgetHorizontalMargin = 30;
    CGFloat forgetFormVerticalMargin = 20;
    
    forgetData = [NSMutableDictionary new];
    
    forgetView = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight())];
    [forgetView setDynamic:NO];
    [forgetView setBlurRadius:10];
    [forgetView setTintColor:[UIColor clearColor]];
    [forgetView setUnderlyingView:backgroundView];
    [forgetView setHidden:YES];
    
    UIButton *forgetBackButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 10, 40, 40)];
    [forgetBackButton setContentMode:UIViewContentModeScaleAspectFit];
    [forgetBackButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
    [forgetBackButton addTarget:self action:@selector(didForgetBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *forgetTitle = [[UILabel alloc] initWithText:NSLocalizedString(@"FORGOT_OBJECT", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleLight:25] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    
    CGRectSetX(forgetTitle.frame, CGRectGetWidth(forgetView.frame) / 2 - CGRectGetWidth(forgetTitle.frame) / 2);
    CGRectSetY(forgetTitle.frame, titleTopMargin);
    
    FLTextFieldSignup *forgetLoginTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_EMAIL", nil) for:forgetData key:@"email" position:CGPointMake(forgetHorizontalMargin, CGRectGetMaxY(forgetTitle.frame) + 100)];
    
    CGRectSetX(forgetLoginTextfield.frame, (CGRectGetWidth(forgetView.frame) - CGRectGetWidth(forgetLoginTextfield.frame)) / 2);
    
    FLActionButton *forgetButton = [[FLActionButton alloc] initWithFrame:CGRectMake(forgetHorizontalMargin, CGRectGetMaxY(forgetLoginTextfield.frame) + forgetFormVerticalMargin, CGRectGetWidth(forgetView.frame) - forgetHorizontalMargin * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil)];
    [forgetButton addTarget:self action:@selector(didForgetNextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [forgetView addSubview:forgetBackButton];
    [forgetView addSubview:forgetTitle];
    [forgetView addSubview:forgetLoginTextfield];
    [forgetView addSubview:forgetButton];
    
    [self.view addSubview:forgetView];
}

- (void)setUserDataForSignup:(NSDictionary*)data {
    [signupData addEntriesFromDictionary:data];
    
    FLUserView *userPicView = (FLUserView *)[signupFbPicView viewWithTag:42];
    
    if (!signupVisible) {
        [UIView transitionWithView:self.view
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [homeView setHidden:YES];
                            [loginView setHidden:YES];
                            [forgetView setHidden:YES];
                            [signupView setHidden:NO];
                        } completion:^(BOOL finished) {
                            if (finished) {
                                loginVisible = NO;
                                signupVisible = YES;
                                homeVisible = NO;
                            }
                            
                            facebookVisible = NO;
                            facebookPicVisible = YES;
                            
                            [signupFbView setHidden:YES];
                            [signupFbPicView setHidden:NO];
                            [userPicView setImageFromURLAnimate:data[@"avatarURL"]];
                            
                            CGRectSetY(signupFormView.frame, CGRectGetMaxY(signupFbPicView.frame) + 10);
                            
                            [signupScrollView setContentSize:CGSizeMake(CGRectGetWidth(signupView.frame), CGRectGetMaxY(signupFormView.frame) + 10)];
                        }];
    } else {
        facebookVisible = NO;
        facebookPicVisible = YES;
        
        [signupFbView setHidden:YES];
        [signupFbPicView setHidden:NO];
        [userPicView setImageFromURLAnimate:data[@"avatarURL"]];
        
        CGRectSetY(signupFormView.frame, CGRectGetMaxY(signupFbPicView.frame) + 10);
        
        [signupScrollView setContentSize:CGSizeMake(CGRectGetWidth(signupView.frame), CGRectGetMaxY(signupFormView.frame) + 10)];
    }
    
    for (FLTextFieldSignup *textfield in signupFormFields) {
        [textfield reloadTextField];
    }
    
    [signupPhoneField reloadTextField];
}

#pragma mark - button action

- (void)didClearSponsorButtonClick {
    FLTextFieldSignup *sponsorTextfield;
    
    for (FLTextFieldSignup *textfield in signupFormFields) {
        if ([textfield.dictionaryKey isEqualToString:@"sponsor"]) {
            sponsorTextfield  = textfield;
            break;
        }
    }
    
    [sponsorTextfield setTextOfTextField:@""];
    clearSponsorField.hidden = YES;
}

- (void)didLoginHomeButtonClick {
    [UIView transitionWithView:self.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [homeView setHidden:YES];
                        [loginView setHidden:NO];
                    } completion:^(BOOL finished) {
                        if (finished)
                            loginVisible = YES;
                    }];
}

- (void)didSignupHomeButtonClick {
    [UIView transitionWithView:self.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [homeView setHidden:YES];
                        [signupView setHidden:NO];
                    } completion:^(BOOL finished) {
                        if (finished)
                            signupVisible = YES;
                    }];
}

- (void)didLoginBackButtonClick {
    if (keyboardVisible) {
        [self.view endEditing:YES];
    } else {
        [UIView transitionWithView:self.view
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [homeView setHidden:NO];
                            [loginView setHidden:YES];
                        } completion:^(BOOL finished) {
                            if (finished) {
                                loginVisible = NO;
                                homeVisible = YES;
                            }
                        }];
    }
}

- (void)didSignupBackButtonClick {
    if (keyboardVisible) {
        [self.view endEditing:YES];
    } else {
        [UIView transitionWithView:self.view
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [homeView setHidden:NO];
                            [signupView setHidden:YES];
                        } completion:^(BOOL finished) {
                            if (finished) {
                                signupVisible = NO;
                                homeVisible = YES;
                            }
                        }];
    }
}

- (void)didForgetBackButtonClick {
    if (keyboardVisible) {
        [self.view endEditing:YES];
    } else {
        [UIView transitionWithView:self.view
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [loginView setHidden:NO];
                            [forgetView setHidden:YES];
                        } completion:^(BOOL finished) {
                            if (finished)
                                loginVisible = YES;
                        }];
    }
}

- (void)didFacebookLoginButtonClick {
    [[Flooz sharedInstance] connectFacebook];
}

- (void)didFacebookSignupButtonClick {
    [[Flooz sharedInstance] connectFacebook];
}

- (void)didLoginButtonClick {
    [self.view endEditing:YES];
    [[Flooz sharedInstance] showLoadView];
    
    if (!loginData[@"phone"])
        [loginData setObject:@"" forKey:@"phone"];
    
    if (!loginData[@"password"])
        [loginData setObject:@"" forKey:@"password"];
    
    NSString *phone = [FLHelper fullPhone:loginData[@"phone"] withCountry:loginData[@"country"]];
    if (!phone)
        phone = @"";
    
    [[Flooz sharedInstance] loginWithPseudoAndPassword:@{@"login": phone, @"password": loginData[@"password"]} success: ^(id result) {
        [appDelegate resetTuto:YES];
        [appDelegate goToAccountViewController];
    }];
}

- (void)didForgotPasswordButtonClick {
    [self.view endEditing:YES];
    
    [UIView transitionWithView:self.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [forgetView setHidden:NO];
                        [loginView setHidden:YES];
                    } completion:^(BOOL finished) {
                        if (finished)
                            loginVisible = NO;
                    }];
}

- (void)didForgetNextButtonClick {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] passwordForget:forgetData[@"email"] success:^(NSDictionary *result){
        [self didForgetBackButtonClick];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didSignupButtonClick {
    [self.view endEditing:YES];
    
    [signupData setObject:[[Mixpanel sharedInstance] distinctId] forKey:@"distinctId"];
    
    if ([appDelegate branchParam]) {
        if ([appDelegate branchParam][@"referrer"] && [[appDelegate branchParam][@"referrer"] length]) {
            [signupData setObject:[appDelegate branchParam][@"referrer"] forKey:@"referrer"];
        }
    }
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] signupPassStep:@"profile" user:signupData success:^(NSDictionary *result) {
        [SignupBaseViewController handleSignupRequestResponse:result withUserData:signupData andViewController:self];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Textfields Delegate

- (void)signupSponsorChange {
    FLTextFieldSignup *sponsorTextfield;
    
    for (FLTextFieldSignup *textfield in signupFormFields) {
        if ([textfield.dictionaryKey isEqualToString:@"sponsor"]) {
            sponsorTextfield  = textfield;
            break;
        }
    }
    
    //    if (sponsorTextfield.textfield.text.length > 0)
    //        clearSponsorField.hidden = NO;
    //    else
    clearSponsorField.hidden = YES;
}

- (void)signupTextFieldNext {
    BOOL nextFocus = false;
    
    if ([signupPhoneField isFirstResponder]) {
        [signupFormFields[2] becomeFirstResponder];
        return;
    }
    
    for (FLTextFieldSignup *field in signupFormFields) {
        if (nextFocus && ![field isHidden]) {
            [field becomeFirstResponder];
            CGRect activeRect = field.frame;
            activeRect.origin.x += signupFormView.frame.origin.x;
            activeRect.origin.y += signupFormView.frame.origin.y;
            
            [signupScrollView scrollRectToVisible:activeRect animated:YES];
            nextFocus = false;
            break;
        }
        
        if ([field isFirstResponder]) {
            if ([signupFormFields indexOfObject:field] == 1) {
                [signupPhoneField becomeFirstResponder];
                nextFocus = false;
                break;
            }
            nextFocus = true;
        }
    }
    
    if (nextFocus) {
        [self.view endEditing:YES];
    }
}

#pragma mark - iCarousel Data Source

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel {
    FLSlider *slider = [Flooz sharedInstance].currentTexts.slider;
    
    if (slider)
        return slider.slides.count;
    return 0;
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    FLSlider *slider = [Flooz sharedInstance].currentTexts.slider;
    
    UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(carousel.frame), CGRectGetHeight(carousel.frame))];
    
    UILabel *slideText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(itemView.frame), 20)];
    [slideText setTextAlignment:NSTextAlignmentCenter];
    [slideText setNumberOfLines:0];
    [slideText setLineBreakMode:NSLineBreakByWordWrapping];
    [slideText setFont:[UIFont customContentRegular:17]];
    [slideText setTextColor:[UIColor whiteColor]];
    [slideText setText:[slider.slides[index] text]];
    [slideText sizeToFit];
    
    CGRectSetX(slideText.frame, CGRectGetWidth(itemView.frame) / 2 - CGRectGetWidth(slideText.frame) / 2);
    CGRectSetY(slideText.frame, CGRectGetHeight(itemView.frame) - CGRectGetHeight(slideText.frame) - 20);
    
    [itemView addSubview:slideText];
    
    return itemView;
}

#pragma mark - iCarousel Delegate

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value {
    if (option == iCarouselOptionWrap)
        return 1.0f;
    else if (option == iCarouselOptionSpacing)
        return 1.5f;
    
    return value;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel {
    [carouselTimer invalidate];
    carouselTimer = [NSTimer scheduledTimerWithTimeInterval:CAROUSEL_AUTOSLIDE_TIMER target:self selector:@selector(changeCurrentCarouselPage) userInfo:nil repeats:NO];
    
    [carouselControl setCurrentPage:carousel.currentItemIndex];
}

- (void)updatePage:(UIPageControl *)pageControl {
    [carouselView scrollToItemAtIndex:pageControl.currentPage animated:YES];
}

- (void)changeCurrentCarouselPage {
    unsigned long currentIndex = (carouselView.currentItemIndex + 1) % [Flooz sharedInstance].currentTexts.slider.slides.count;
    
    [carouselView scrollToItemAtIndex:currentIndex animated:YES];
}

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([[url scheme] hasPrefix:@"action"]) {
        if ([[url host] hasPrefix:@"show-CGU"]) {
            [self displayCGU];
        }
    }
}

- (void)displayCGU {
    WebViewController *controller = [WebViewController new];
    [controller setUrl:@"https://www.flooz.me/cgu?layout=webview"];
    controller.title = NSLocalizedString(@"INFORMATIONS_TERMS", nil);
    UINavigationController *controller2 = [[FLNavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:controller2 animated:YES completion:NULL];
}

#pragma mark - Keyboard Notifications

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    keyboardVisible = YES;
    
    if (loginVisible) {
        if (!IS_IPHONE_6 && !IS_IPHONE_6P)
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [loginHeaderView setAlpha:0.0f];
                CGRectSetY(loginFormView.frame, 40);
            } completion:^(BOOL finished) {
                [loginHeaderView setHidden:YES];
            }];
    } else if (signupVisible) {
        [signupScrollView setScrollEnabled:YES];
        NSDictionary* info = [notification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        
        CGRectSetHeight(signupScrollView.frame, CGRectGetHeight(signupView.frame) - kbSize.height);
        
        if (facebookVisible) {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [signupFbView setAlpha:0.0f];
                CGRectSetY(signupFormView.frame, CGRectGetMaxY(signupHeaderView.frame));
                
                [signupScrollView setContentSize:CGSizeMake(CGRectGetWidth(signupView.frame), CGRectGetMaxY(signupFormView.frame) + 10)];
                
            } completion:^(BOOL finished) {
                [signupFbView setHidden:YES];
                
                UIView *activeField = nil;
                
                for (FLTextFieldSignup *textfield in signupFormFields) {
                    if ([textfield isFirstResponder]) {
                        activeField = textfield;
                        break;
                    }
                }
                if (!activeField && [signupPhoneField isFirstResponder])
                    activeField = signupPhoneField;

                CGRect activeRect = activeField.frame;
                activeRect.origin.x += signupFormView.frame.origin.x;
                activeRect.origin.y += signupFormView.frame.origin.y;
                
                [signupScrollView scrollRectToVisible:activeRect animated:YES];
            }];
        } else if (facebookPicVisible) {
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [signupFbPicView setAlpha:0.0f];
                CGRectSetY(signupFormView.frame, CGRectGetMaxY(signupHeaderView.frame));
                
                [signupScrollView setContentSize:CGSizeMake(CGRectGetWidth(signupView.frame), CGRectGetMaxY(signupFormView.frame) + 10)];
                
            } completion:^(BOOL finished) {
                [signupFbPicView setHidden:YES];
                
                UIView *activeField = nil;
                
                for (FLTextFieldSignup *textfield in signupFormFields) {
                    if ([textfield isFirstResponder]) {
                        activeField = textfield;
                        break;
                    }
                }
                
                if (!activeField && [signupPhoneField isFirstResponder])
                    activeField = signupPhoneField;

                CGRect activeRect = activeField.frame;
                activeRect.origin.x += signupFormView.frame.origin.x;
                activeRect.origin.y += signupFormView.frame.origin.y;
                
                [signupScrollView scrollRectToVisible:activeRect animated:YES];
            }];
        } else {
            UIView *activeField = nil;
            
            for (FLTextFieldSignup *textfield in signupFormFields) {
                if ([textfield isFirstResponder]) {
                    activeField = textfield;
                    break;
                }
            }
            
            if (!activeField && [signupPhoneField isFirstResponder])
                activeField = signupPhoneField;

            CGRect activeRect = activeField.frame;
            activeRect.origin.x += signupFormView.frame.origin.x;
            activeRect.origin.y += signupFormView.frame.origin.y;
            
            [signupScrollView scrollRectToVisible:activeRect animated:YES];
        }
        
    }
}

- (void)keyboardDidDisappear:(NSNotification *)notification {
    
}

- (void)keyboardWillDisappear:(NSNotification *)notification {
    keyboardVisible = NO;
    
    if (loginVisible) {
        if (!IS_IPHONE_6 && !IS_IPHONE_6P)
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGRectSetY(loginFormView.frame, CGRectGetMaxY(loginHeaderView.frame));
            } completion:^(BOOL finished) {
                [loginHeaderView setHidden:NO];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [loginHeaderView setAlpha:1.0f];
                } completion:nil];
            }];
    } else if (signupVisible) {
        if (!IS_IPHONE_4)
            [signupScrollView setScrollEnabled:NO];
        
        CGRectSetHeight(signupScrollView.frame, PPScreenHeight());
        [signupScrollView scrollsToTop];
        
        if (facebookVisible) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGRectSetY(signupFormView.frame, CGRectGetMaxY(signupFbView.frame));
            } completion:^(BOOL finished) {
                [signupFbView setHidden:NO];
                [signupScrollView setContentSize:CGSizeMake(CGRectGetWidth(signupView.frame), CGRectGetMaxY(signupFormView.frame) + 10)];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [signupFbView setAlpha:1.0f];
                } completion:nil];
            }];
        } else if (facebookPicVisible) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                CGRectSetY(signupFormView.frame, CGRectGetMaxY(signupFbPicView.frame));
            } completion:^(BOOL finished) {
                [signupFbPicView setHidden:NO];
                [signupScrollView setContentSize:CGSizeMake(CGRectGetWidth(signupView.frame), CGRectGetMaxY(signupFormView.frame) + 10)];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    [signupFbPicView setAlpha:1.0f];
                } completion:nil];
            }];
        }
    }
}

@end
