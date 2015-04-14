//
//  SignupInvitationViewController.m
//  Flooz
//
//  Created by Epitech on 4/1/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import "SignupInvitationViewController.h"

@interface SignupInvitationViewController () {
    FLTextFieldSignup *_coupon;
    
    FLActionButton *_nextButton;
}

@end

@implementation SignupInvitationViewController

- (id)init {
    self = [super init];
    if (self) {
        self.userDic = [NSMutableDictionary new];
        self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Invitation", @"");
    }
    return self;
}

- (void)initWithData:(NSDictionary *)data {
    [super initWithData:data];
    
    if (self.contentData) {
        if (self.contentData[@"title"])
            self.title = self.contentData[@"title"];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *placeholder = NSLocalizedString(@"FIELD_COUPON", nil);
    NSString *buttonText = NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil);

    if (self.contentData) {
        if (self.contentData[@"placeholder"])
            placeholder = self.contentData[@"placeholder"];
        
        if (self.contentData[@"button"])
            buttonText = self.contentData[@"button"];
    }

    {        
        _coupon = [[FLTextFieldSignup alloc] initWithPlaceholder:placeholder for:self.userDic key:@"coupon" position:CGPointMake(SIGNUP_PADDING_SIDE, self.firstItemY)];
        
        [_coupon addForNextClickTarget:self action:@selector(checkCoupon)];
        [_mainBody addSubview:_coupon];
    }
    
    {
        _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, 0, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:buttonText];
        [_nextButton addTarget:self action:@selector(checkCoupon) forControlEvents:UIControlEventTouchUpInside];
        CGRectSetY(_nextButton.frame, CGRectGetMaxY(_coupon.frame) + 5);
        [_mainBody addSubview:_nextButton];
    }
}

- (void)displayChanges {
    [_coupon reloadTextField];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_coupon becomeFirstResponder];
}

- (void)checkCoupon {
    NSMutableDictionary *dic = [self.userDic mutableCopy];
    if (dic[@"birthdate"])
        [dic setObject:[[Flooz sharedInstance] formatBirthDate:self.userDic[@"birthdate"]] forKey:@"birthdate"];
    if (self.userDic[@"picId"]) {
        [dic setValue:@YES forKey:@"hasImage"];
    }
    else {
        [dic setValue:@NO forKey:@"hasImage"];
    }
    [dic removeObjectForKey:@"picId"];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] signupPassStep:@"invitation" user:dic success:^(NSDictionary *result) {
        SignupBaseViewController *nextViewController = [SignupBaseViewController getViewControllerForStep:result[@"nextStep"] withData:result[@"nextStepData"]];
        if (nextViewController)
            [self.navigationController pushViewController:nextViewController animated:YES];
    } failure:^(NSError *error) {
        [_coupon becomeFirstResponder];
    }];
}

@end
