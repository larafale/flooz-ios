//
//  PasswordViewController.m
//  Flooz
//
//  Created by olivier on 2/14/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "PasswordViewController.h"
#import "FLTextFieldTitle2.h"
#import "FLTextFieldSignup.h"

#define PADDING_SIDE 20.0f

@interface PasswordViewController () {
    NSMutableDictionary *_password;
    UIScrollView *_contentView;
    UIButton *_nextButton;
    NSMutableArray *fieldsView;
    UIButton *_passwordForgetButton;
}

@end

@implementation PasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"SETTINGS_PASSWORD", nil);
        
        _password = [NSMutableDictionary new];
        fieldsView = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentView = [UIScrollView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [_contentView setBackgroundColor:[UIColor customBackgroundHeader]];
    
    [_mainBody addSubview:_contentView];
    [self registerForKeyboardNotifications];
    
    CGFloat height = 0;
    
    {
        FLTextFieldSignup *view = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_CURRENT_PASSWORD" for:_password key:@"password" position:CGPointMake(PADDING_SIDE, 30)];
        [_contentView addSubview:view];
        [view seTsecureTextEntry:YES];
        [view addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [view addForTextChangeTarget:self action:@selector(canValidate:)];
        height = CGRectGetMaxY(view.frame);
        [fieldsView addObject:view];
    }
    
    {
        FLTextFieldSignup *view = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_NEW_PASSWORD" for:_password key:@"newPassword" position:CGPointMake(PADDING_SIDE, height)];
        [_contentView addSubview:view];
        [view seTsecureTextEntry:YES];
        [view addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [view addForTextChangeTarget:self action:@selector(canValidate:)];
        height = CGRectGetMaxY(view.frame);
        [fieldsView addObject:view];
    }
    
    {
        FLTextFieldSignup *view = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_PASSWORD_CONFIRMATION" for:_password key:@"confirm" position:CGPointMake(PADDING_SIDE, height)];
        [_contentView addSubview:view];
        [view seTsecureTextEntry:YES];
        [view addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [view addForTextChangeTarget:self action:@selector(canValidate:)];
        height = CGRectGetMaxY(view.frame);
        [fieldsView addObject:view];
    }
    
    {
        [self createNextButton];
        CGRectSetY(_nextButton.frame, height + 10.0f);
        [_nextButton addTarget:self action:@selector(didValidTouch) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_nextButton];
    }
    
    {
        _passwordForgetButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_nextButton.frame) + 10, PPScreenWidth(), 30)];
        _passwordForgetButton.titleLabel.textAlignment = NSTextAlignmentRight;
        _passwordForgetButton.titleLabel.font = [UIFont customContentRegular:12];
        [_passwordForgetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_passwordForgetButton setTitle:NSLocalizedString(@"LOGIN_PASSWORD_FORGOT", nil) forState:UIControlStateNormal];
        [_passwordForgetButton addTarget:self action:@selector(didPasswordForgetTouch) forControlEvents:UIControlEventTouchUpInside];
        height = CGRectGetMaxY(_passwordForgetButton.frame);
        [_contentView addSubview:_passwordForgetButton];
    }
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height);
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didValidTouch {
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updatePassword:_password success: ^(id result) {
        [self.navigationController popViewControllerAnimated:YES];
    } failure:NULL];
}

- (void)createNextButton {
    _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"GLOBAL_CONFIRM", nil)];
}

- (void)focusOnNextInfo {
    NSInteger index = 0;
    for (FLTextFieldSignup *tf in fieldsView) {
        if ([tf isFirstResponder]) {
            if (index < fieldsView.count - 1) {
                [fieldsView[index + 1] becomeFirstResponder];
                break;
            }
            else {
                if ([self canValidate:tf]) {
                    [self didValidTouch];
                    break;
                }
                else {
                    [fieldsView[0] becomeFirstResponder];
                    break;
                }
            }
        }
        index++;
    }
}

- (BOOL)canValidate:(FLTextFieldSignup *)textIcon {
    BOOL canValidate = YES;
    
    //	if ((_password[@"password"] && [_password[@"password"] length] >= 1)
    //        && (_password[@"newPassword"] && [_password[@"newPassword"] length] >= 6)
    //        && (_password[@"confirm"] && [_password[@"confirm"] length] >= 6)
    //        && [_password[@"newPassword"] isEqualToString:_password[@"confirm"]]) {
    //		canValidate = YES;
    //	}
    //
    //	if (canValidate) {
    //		[_nextButton setEnabled:YES];
    //		[_nextButton setBackgroundColor:[UIColor customBlue]];
    //	}
    //	else {
    //		[_nextButton setEnabled:NO];
    //		[_nextButton setBackgroundColor:[UIColor customBackground]];
    //	}
    
    return canValidate;
}

- (void)didPasswordForgetTouch {
    NSString *number = [Flooz sharedInstance].currentUser.email;
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] passwordForget:number success:^(NSDictionary *result){
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear {
    _contentView.contentInset = UIEdgeInsetsZero;
}

@end
