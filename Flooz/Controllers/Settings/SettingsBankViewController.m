//
//  SettingsBankViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-03.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SettingsBankViewController.h"
#import "FLKeyboardView.h"

#define PADDING_SIDE 20.0f

@interface SettingsBankViewController () {
	UIScrollView *_contentView;

	NSMutableDictionary *_userDic;
	NSMutableDictionary *_sepa;

	FLTextFieldSignup *_IBAN;

    FLActionButton *_saveButton;
}

@end

@implementation SettingsBankViewController

- (void)viewDidLoad {
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"SETTINGS_BANK", @"");
    
	[super viewDidLoad];

	[self initWithInfo];

	_contentView = [UIScrollView newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
	[_mainBody addSubview:_contentView];

	{
		_IBAN = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_IBAN_PLACEHOLDER" for:_sepa key:@"iban" position:CGPointMake(PADDING_SIDE, PADDING_SIDE)];
		[_IBAN addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentView addSubview:_IBAN];
	}

	{
		[self createSaveButton];
		CGRectSetY(_saveButton.frame, CGRectGetMaxY(_IBAN.frame) + 10.0f);
		[_saveButton addTarget:self action:@selector(saveChanges) forControlEvents:UIControlEventTouchUpInside];
		[_contentView addSubview:_saveButton];
	}
	_contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(_saveButton.frame));

	[self addTapGestureForDismissKeyboard];
}

- (void)initWithInfo {
	FLUser *currentUser = [[Flooz sharedInstance] currentUser];

	_userDic = [NSMutableDictionary new];
	[_userDic setObject:[NSMutableDictionary new] forKey:@"settings"];
	_sepa = [[currentUser sepa] mutableCopy];
}

- (void)createSaveButton {
	_saveButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SAVE_IBAN", nil)];

	[_saveButton setEnabled:YES];
}

- (BOOL)canValidate:(FLTextFieldSignup *)textIcon {
	BOOL canValidate = YES;

    return canValidate;
}

- (void)saveChanges {
	if (![self canValidate:nil]) {
		return;
	}

	[[self view] endEditing:YES];

	_userDic[@"settings"] = @{ @"sepa": _sepa };

	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] updateUser:_userDic success: ^(id result) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.triggerData && self.triggerData[@"success"]) {
                [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:self.triggerData[@"success"]]];
            }
        }];
    } failure:NULL];
}

- (void)addTapGestureForDismissKeyboard {
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	tapGesture.cancelsTouchesInView = NO;
	[_mainBody addGestureRecognizer:tapGesture];
	[_contentView addGestureRecognizer:tapGesture];
	[self registerForKeyboardNotifications];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
	[self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
	[self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;

	_contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0);
}

- (void)keyboardWillDisappear {
	_contentView.contentInset = UIEdgeInsetsZero;
}

- (void)hideKeyboard {
	[self.view endEditing:YES];
}

@end
