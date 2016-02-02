//
//  SettingsCoordsViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-03.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SettingsCoordsViewController.h"

#import "FLKeyboardView.h"
#import "FLPhoneField.h"

#define PADDING_SIDE 20.0f

@interface SettingsCoordsViewController () {
	UIScrollView *_contentView;

    NSMutableDictionary *_userDic;
    NSMutableDictionary *_addressDic;

	FLUserView *userView;
    FLTextFieldSignup *_name;
    FLPhoneField *_phone;
	FLTextFieldSignup *_email;
	FLTextFieldSignup *_address;
	FLTextFieldSignup *_postalCode;
	FLTextFieldSignup *_city;

	UIButton *sendValidationSMS;
	UIButton *sendValidationEmail;

	NSMutableArray *fieldsView;
	FLKeyboardView *inputView;

	FLActionButton *_saveButton;
    CGFloat height;
}

@end

@implementation SettingsCoordsViewController

- (void)viewDidLoad {
	[super viewDidLoad];

    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"SETTINGS_COORDS", @"");

	[self initWithInfo];
    
	fieldsView = [NSMutableArray new];

	_contentView = [UIScrollView newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
	[_mainBody addSubview:_contentView];

    {
        _name = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_FIRSTNAME" for:_userDic key:@"firstName" position:CGPointMake(PADDING_SIDE, 0.0f) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
        [_name addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [_name addForTextChangeTarget:self action:@selector(canValidate:)];
        [_contentView addSubview:_name];
        [fieldsView addObject:_name];
    }

	{
        _phone = [[FLPhoneField alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_PHONE", @"") for:_userDic position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_name.frame))];
		[_phone addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [_phone addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentView addSubview:_phone];
		[fieldsView addObject:_phone.textfield];
	}

	{
		sendValidationSMS = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_phone.frame) - 100, CGRectGetMinY(_phone.frame), 100, CGRectGetHeight(_phone.frame))];

		sendValidationSMS.titleLabel.textAlignment = NSTextAlignmentRight;
		sendValidationSMS.titleLabel.font = [UIFont customContentRegular:12];
		[sendValidationSMS setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
		[sendValidationSMS setTitle:NSLocalizedString(@"EDIT_ACCOUNT_SEND_SMS", nil) forState:UIControlStateNormal];
		[_contentView addSubview:sendValidationSMS];

		[sendValidationSMS addTarget:self action:@selector(didSendSMSValidationTouch:) forControlEvents:UIControlEventTouchUpInside];
	}
    
    if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:@"phone"] intValue] != 3) {
        sendValidationSMS.hidden = YES;
        [_phone.textfield setEnabled:YES];
    }
    else {
        [_phone.textfield setEnabled:NO];
    }
    
	{
		_email = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_EMAIL" for:_userDic key:@"email" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_phone.frame))];
		[_email addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_email addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentView addSubview:_email];
		[fieldsView addObject:_email];
	}

	{
		sendValidationEmail = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_email.frame) - 100, CGRectGetMinY(_email.frame), 100, CGRectGetHeight(_email.frame))];

		sendValidationEmail.titleLabel.textAlignment = NSTextAlignmentRight;
		sendValidationEmail.titleLabel.font = [UIFont customContentRegular:12];
		[sendValidationEmail setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
		[sendValidationEmail setTitle:NSLocalizedString(@"EDIT_ACCOUNT_SEND_MAIL", nil) forState:UIControlStateNormal];
		[_contentView addSubview:sendValidationEmail];

		[sendValidationEmail addTarget:self action:@selector(didSendEmailValidationTouch:) forControlEvents:UIControlEventTouchUpInside];
	}

	if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:@"email"] intValue] != 3) {
		sendValidationEmail.hidden = YES;
	}
	else {
		[_email setEnable:NO];
	}

	{
		_address = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_ADDRESS" for:_addressDic key:@"address" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_email.frame))];
		[_address addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_address addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentView addSubview:_address];
		[fieldsView addObject:_address];
	}

	{
		_postalCode = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_ZIP_CODE" for:_addressDic key:@"zipCode" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_address.frame))];
		[_postalCode addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_postalCode addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentView addSubview:_postalCode];
		[fieldsView addObject:_postalCode];
	}

	{
		_city = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_CITY" for:_addressDic key:@"city" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_postalCode.frame))];
		[_city addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_city addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentView addSubview:_city];
		[fieldsView addObject:_city];
	}

	height = CGRectGetMaxY(_city.frame);

	{
		[self createSaveButton];
		CGRectSetY(_saveButton.frame, height + 10.0f);
		[_saveButton addTarget:self action:@selector(saveChanges) forControlEvents:UIControlEventTouchUpInside];
		[_contentView addSubview:_saveButton];
	}
	_contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(_saveButton.frame));

	[self addTapGestureForDismissKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)initWithInfo {
	FLUser *currentUser = [[Flooz sharedInstance] currentUser];

	_userDic = [NSMutableDictionary new];
	[_userDic setObject:[NSMutableDictionary new] forKey:@"settings"];
    
    if ([currentUser lastname] && ![[currentUser lastname] isBlank]) {
        NSString *text = [[currentUser lastname] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[[currentUser lastname] substringToIndex:1] capitalizedString]];
        [_userDic setObject:text forKey:@"lastName"];
    }
    if ([currentUser firstname] && ![[currentUser firstname] isBlank]) {
        NSString *text = [[currentUser firstname] stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[[currentUser firstname] substringToIndex:1] capitalizedString]];
        [_userDic setObject:text forKey:@"firstName"];
    }

	if ([currentUser phone]) {
        NSString *phone = [[currentUser phone] stringByReplacingOccurrencesOfString:[currentUser country].phoneCode withString:@"0"];
        
		[_userDic setObject:phone forKey:@"phone"];
        [_userDic setObject:[currentUser country].code forKey:@"country"];
	}
    
	if ([currentUser email]) {
		[_userDic setObject:[currentUser email] forKey:@"email"];
	}

	_addressDic = [[currentUser address] mutableCopy];
}

- (void)createBottomBar:(UIView *)view {
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(view.frame) - 1.0f, CGRectGetWidth(view.frame), 1.0f)];
    bottomBar.backgroundColor = [UIColor customBackground];
    
    [view addSubview:bottomBar];
}

- (void)createSaveButton {
	_saveButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"GLOBAL_SAVE", nil)];

	[_saveButton setEnabled:YES];
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
				if (![self canValidate:tf]) {
					[fieldsView[0] becomeFirstResponder];
					break;
				}
			}
		}
		index++;
	}
}

- (BOOL)canValidate:(FLTextFieldSignup *)textIcon {
	return YES;
}

- (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (void)saveChanges {
	if (![self canValidate:nil]) {
		return;
	}

	[[self view] endEditing:YES];

	_userDic[@"settings"] = @{ @"address": _addressDic };

	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] updateUser:_userDic success: ^(id result) {
	    [self dismissViewController];
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


- (void)didSendSMSValidationTouch:(UIButton *)sender {
	[[Flooz sharedInstance] sendSMSValidation];
	sender.hidden = YES;
}

- (void)didSendEmailValidationTouch:(UIButton *)sender {
	[[Flooz sharedInstance] sendEmailValidation];
	sender.hidden = YES;
}

@end
