//
//  SignupUsernameViewController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SignupUsernameViewController.h"
#import "SignupPhotoViewController.h"

@interface SignupUsernameViewController () {
    FLTextFieldSignup *_userName;
    FLKeyboardView *_inputView;
    
    FLActionButton *_nextButton;
}

@end

@implementation SignupUsernameViewController

- (id)init {
    self = [super init];
    if (self) {
        self.userDic = [NSMutableDictionary new];
        self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Pseudo", @"");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        _userName = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_USERNAME" for:self.userDic key:@"nick" position:CGPointMake(SIGNUP_PADDING_SIDE, self.firstItemY)];
        
        [_userName addForNextClickTarget:self action:@selector(checkPseudo)];
        [_userName addForTextChangeTarget:self action:@selector(canValidate:)];
        [_mainBody addSubview:_userName];
    }
    
    {
        _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, 0, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil)];
        [_nextButton setEnabled:NO];
        [_nextButton addTarget:self action:@selector(checkPseudo) forControlEvents:UIControlEventTouchUpInside];
        CGRectSetY(_nextButton.frame, CGRectGetMaxY(_userName.frame) + 5);
        [_mainBody addSubview:_nextButton];
    }
    
    {
        UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_nextButton.frame), PPScreenWidth() - 30, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_nextButton.frame) - 216)];
        firstTimeText.textColor = [UIColor whiteColor];
        firstTimeText.font = [UIFont customTitleExtraLight:14];
        firstTimeText.numberOfLines = 0;
        firstTimeText.textAlignment = NSTextAlignmentCenter;
        firstTimeText.text = NSLocalizedString(@"SIGNUP_PSEUDO_EXPLICATION", nil);
        [_mainBody addSubview:firstTimeText];
    }
    
}

- (void)displayChanges {
    [_userName reloadTextField];
    [self canValidate:_userName];
}

- (void)canValidate:(FLTextFieldSignup *)textIcon {
    BOOL canValidate = NO;
    if (self.userDic[@"nick"] && ((NSString *)self.userDic[@"nick"]).length >= 3) {
        canValidate = YES;
    }
    
    if (canValidate) {
        [_nextButton setEnabled:YES];
    }
    else {
        [_nextButton setEnabled:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_userName becomeFirstResponder];
}

- (void)checkPseudo {
    if (self.userDic[@"nick"] && ((NSString *)self.userDic[@"nick"]).length >= 3) {
        NSMutableDictionary *dic = [self.userDic mutableCopy];
        [dic setObject:[[Flooz sharedInstance] formatBirthDate:self.userDic[@"birthdate"]] forKey:@"birthdate"];
        if (self.userDic[@"picId"]) {
            [dic setValue:@YES forKey:@"hasImage"];
        }
        else {
            [dic setValue:@NO forKey:@"hasImage"];
        }
        [dic removeObjectForKey:@"picId"];

        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] signupPassStep:@"nick" user:dic success:^(id result) {
            [self.navigationController pushViewController:[SignupPhotoViewController new] animated:YES];
        } failure:^(NSError *error) {
            [_userName becomeFirstResponder];
        }];
    }
}


@end
