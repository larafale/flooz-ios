//
//  SignupBaseViewController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SignupBaseViewController.h"
#import "SignupSecureCodeViewController.h"
#import "SignupInvitationViewController.h"
#import "SignupCreditCardViewController.h"

@implementation SignupBaseViewController

@synthesize userDic;
@synthesize firstItemY;
@synthesize ratioiPhones;

- (id)init {
    self = [super init];
    if (self) {
        self.userDic = [NSMutableDictionary new];
        self.ratioiPhones = 1.0f;
        if (PPScreenHeight() < 568) {
            self.ratioiPhones = 1.2f;
        }
        self.firstItemY = 25.0f / self.ratioiPhones;
    }
    return self;
}

- (void)initWithData:(NSDictionary *)data {
    self.contentData = data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, STATUSBAR_HEIGHT, PPScreenWidth(), 60.0f)];
    _headerView.backgroundColor = [UIColor customBackgroundHeader];
    [self.view addSubview:_headerView];
    
    {
        _headTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_headerView.frame), CGRectGetHeight(_headerView.frame))];
        _headTitle.font = [UIFont customTitleNav];
        _headTitle.textColor = [UIColor customBlue];
        _headTitle.numberOfLines = 1;
        _headTitle.textAlignment = NSTextAlignmentCenter;
        _headTitle.text = self.title;
        [_headerView addSubview:_headTitle];
    }
    
    {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(17.0f, 0.0f, 30.0f, CGRectGetHeight(_headerView.frame))];
        
        [backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
        [backButton setTag:666];
        [backButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:backButton];
    }
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_headerView.frame), PPScreenWidth(), PPScreenHeight() - CGRectGetMaxY(_headerView.frame))];
    _mainBody.backgroundColor = [UIColor customBackgroundHeader];
    [self.view addSubview:_mainBody];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

+ (SignupBaseViewController *) getViewControllerForStep:(NSString *)step withData:(NSDictionary *)data {    
    if ([step isEqualToString:@"invitation"]) {
        SignupInvitationViewController *controller = [SignupInvitationViewController new];
        [controller initWithData:data];
        return controller;
    } else if ([step isEqualToString:@"secureCode"]) {
        SignupSecureCodeViewController *controller = [[SignupSecureCodeViewController alloc] initWithMode:SecureCodeModeChangeNew];
        [controller initWithData:data];
        return controller;
    } else if ([step isEqualToString:@"sms"]) {
        SignupSMSViewController *controller = [SignupSMSViewController new];
        [controller initWithData:data];
        return controller;
    } else if ([step isEqualToString:@"card"]) {
        SignupCreditCardViewController *controller = [SignupCreditCardViewController new];
        [controller initWithData:data];
        return controller;
    }
    
    return nil;
}

+ (void)handleSignupRequestResponse:(NSDictionary *)result withUserData:(NSDictionary *)signupData andViewController:(UIViewController *)viewController {
    if ([result[@"step"][@"next"] isEqualToString:@"signup"]) {
        NSString *deviceToken = [appDelegate currentDeviceToken];
        
        NSMutableDictionary *mutableData = [signupData mutableCopy];
        
        if (deviceToken) {
            [mutableData setObject:deviceToken forKey:@"device"];
        }
        
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] signupPassStep:@"signup" user:mutableData success:^(NSDictionary *result) {
            [appDelegate resetTuto:YES];
            [appDelegate clearBranchParams];
            [[Flooz sharedInstance] updateCurrentUserAndAskResetCode:result];
            
            SignupBaseViewController *nextViewController = [SignupBaseViewController getViewControllerForStep:result[@"step"][@"next"] withData:result[@"step"]];
            
            if (nextViewController) {
                SignupNavigationController *signupNavigationController = [[SignupNavigationController alloc] initWithRootViewController:nextViewController];
                nextViewController.userDic = mutableData;
                
                [viewController presentViewController:signupNavigationController animated:YES completion:nil];
            }
        } failure:^(NSError *error) {
            
        }];
    } else {
        SignupBaseViewController *nextViewController = [SignupBaseViewController getViewControllerForStep:result[@"step"][@"next"] withData:result[@"step"]];
        
        if (nextViewController) {
            SignupNavigationController *signupNavigationController = [[SignupNavigationController alloc] initWithRootViewController:nextViewController];
            nextViewController.userDic = [signupData mutableCopy];
            
            [viewController presentViewController:signupNavigationController animated:YES completion:nil];
        }
    }
}

+ (void)handleSignupRequestResponse:(NSDictionary *)result withUserData:(NSDictionary *)signupData andNavigationController:(UINavigationController *)navController {
    if ([result[@"step"][@"next"] isEqualToString:@"signup"]) {
        NSString *deviceToken = [appDelegate currentDeviceToken];
        
        NSMutableDictionary *mutableData = [signupData mutableCopy];
        
        if (deviceToken) {
            [mutableData setObject:deviceToken forKey:@"device"];
        }
        
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] signupPassStep:@"signup" user:mutableData success:^(NSDictionary *result) {
            [appDelegate resetTuto:YES];
            [appDelegate clearBranchParams];
            [appDelegate clearPendingData];
            [[Flooz sharedInstance] updateCurrentUserAndAskResetCode:result];
            
            SignupBaseViewController *nextViewController = [SignupBaseViewController getViewControllerForStep:result[@"step"][@"next"] withData:result[@"step"]];
            
            if (nextViewController) {
                nextViewController.userDic = mutableData;
                
                [navController pushViewController:nextViewController animated:YES];
            }
        } failure:^(NSError *error) {
            
        }];
    } else {
        SignupBaseViewController *nextViewController = [SignupBaseViewController getViewControllerForStep:result[@"step"][@"next"] withData:result[@"step"]];
        
        if (nextViewController) {
            nextViewController.userDic = [signupData mutableCopy];
            
            [navController pushViewController:nextViewController animated:YES];
        }
    }
}

- (void)displayChanges {

}

@end
