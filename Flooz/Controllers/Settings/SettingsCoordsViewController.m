//
//  SettingsCoordsViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-03.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SettingsCoordsViewController.h"

#import "FLKeyboardView.h"

#define PADDING_SIDE 20.0f

@interface SettingsCoordsViewController () {
	UIScrollView *_contentView;

    NSMutableDictionary *_userDic;
    NSMutableDictionary *_addressDic;

	FLUserView *userView;
	FLTextFieldSignup *_phone;
	FLTextFieldSignup *_email;
	FLTextFieldSignup *_address;
	FLTextFieldSignup *_postalCode;
	FLTextFieldSignup *_city;

	UIButton *sendValidationSMS;
	UIButton *sendValidationEmail;

	NSMutableArray *fieldsView;
	FLKeyboardView *inputView;

	NSArray *documents;
	NSMutableArray *documentsButton;

	NSInteger registerButtonCount;
	NSString *currentDocumentKey;

	UIButton *_saveButton;
    CGFloat height;
}

@end

@implementation SettingsCoordsViewController

- (void)viewDidLoad {
	self.title = NSLocalizedString(@"SETTINGS_COORDS", @"");
	[super viewDidLoad];

	[self initWithInfo];
    
    documentsButton = [NSMutableArray new];

	fieldsView = [NSMutableArray new];

	_contentView = [UIScrollView newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
	[_mainBody addSubview:_contentView];


	{
		_phone = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_PHONE" for:_userDic key:@"phone" position:CGPointMake(PADDING_SIDE, 0.0f)];
		[_phone addForNextClickTarget:self action:@selector(focusOnNextInfo)];
        [_phone addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentView addSubview:_phone];
		[fieldsView addObject:_phone];
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
    }
    else {
        [_phone setEnable:NO];
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

    for (NSDictionary *dic in documents) {
        NSString *key = [[dic allKeys] firstObject];
        NSString *value = [[dic allValues] firstObject];
        [self createDocumentsButtonWithKey:key andValue:value];
    }

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
    [self initWithInfo];
}

- (void)initWithInfo {
	FLUser *currentUser = [[Flooz sharedInstance] currentUser];

	_userDic = [NSMutableDictionary new];
	[_userDic setObject:[NSMutableDictionary new] forKey:@"settings"];

	if ([currentUser phone]) {
		[_userDic setObject:[currentUser phone] forKey:@"phone"];
	}
	if ([currentUser email]) {
		[_userDic setObject:[currentUser email] forKey:@"email"];
	}

	_addressDic = [currentUser address];

	documents = @[
	        @{ @"HOME": @"justificatory" }
	    ];

	registerButtonCount = 0;
}

- (void)createDocumentsButtonWithKey:(NSString *)key andValue:(NSString *)value {
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, height, PPScreenWidth() - PADDING_SIDE * 2.0f, 45)];
    [_contentView addSubview:view];
    height = CGRectGetMaxY(view.frame);
    
    [self registerButtonForAction:view];
    view.backgroundColor = [UIColor customBackgroundHeader];
    view.titleLabel.font = [UIFont customTitleExtraLight:16];
    view.titleLabel.textColor = [UIColor whiteColor];
    
    [view setTitle:NSLocalizedString(([NSString stringWithFormat:@"DOCUMENTS_%@", key]), nil) forState:UIControlStateNormal];
    view.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [view setTitleEdgeInsets:UIEdgeInsetsMake(0, 10.0f, 0, 0)];
    
    {
        UIImageView *imageView = [UIImageView imageNamed:@"friends-field-in"];
        if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:value] intValue] == 0){
            imageView = [UIImageView imageNamed:@"document-refused"];
        }
        if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:value] intValue] == 3){
            imageView = [UIImageView imageNamed:@"friends-field-add"];
        }
        [documentsButton addObject:imageView];
        CGRectSetXY(imageView.frame, CGRectGetWidth(view.frame) - CGRectGetWidth(imageView.frame), (CGRectGetHeight(view.frame) - CGRectGetHeight(imageView.frame)) / 2.0f);
        [view addSubview:imageView];
    }
    
    [self createBottomBar:view];
}

- (void)createBottomBar:(UIView *)view {
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(view.frame) - 1.0f, CGRectGetWidth(view.frame), 1.0f)];
    bottomBar.backgroundColor = [UIColor customBackground];
    
    [view addSubview:bottomBar];
}

- (void)createSaveButton {
	_saveButton = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, 34)];

	[_saveButton setTitle:NSLocalizedString(@"Save", nil) forState:UIControlStateNormal];
	[_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_saveButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
	[_saveButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];

	[_saveButton setEnabled:NO];
	[_saveButton setBackgroundColor:[UIColor customBackground]];
}

- (void)registerButtonForAction:(UIButton *)button {
	SEL action;
	switch (registerButtonCount) {
		case 0:
			action = @selector(didDocumentTouch);
			break;

		default:
			action = nil;
			break;
	}

	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	registerButtonCount++;
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
	BOOL canValidate = YES;

    if (!_userDic[@"phone"] || [_userDic[@"phone"] isBlank] || ((NSString *)_userDic[@"phone"]).length < 10) {
        canValidate = NO;
    }
    
    if (!_userDic[@"email"] || [_userDic[@"email"] isBlank]) {
        canValidate = NO;
    }
    
	if (canValidate) {
		[_saveButton setEnabled:YES];
		[_saveButton setBackgroundColor:[UIColor customBlue]];
	}
	else {
		[_saveButton setEnabled:NO];
		[_saveButton setBackgroundColor:[UIColor customBackground]];
	}
	return canValidate;
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

- (void)didDocumentTouch {
	currentDocumentKey = [[documents[0] allValues] firstObject];
	[self showImagePicker];
}

- (void)addTapGestureForDismissKeyboard {
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	tapGesture.cancelsTouchesInView = NO;
	[_mainBody addGestureRecognizer:tapGesture];
	[_contentView addGestureRecognizer:tapGesture];
	[_headerView addGestureRecognizer:tapGesture];
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

#pragma mark - imagePicker

- (void)showImagePicker {
    if ([[[Flooz sharedInstance] currentUser] settings][currentDocumentKey] && [[[[Flooz sharedInstance] currentUser] checkDocuments][currentDocumentKey] intValue] == 1) {
        return;
    }
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        [self createActionSheet];
    }
    else {
        [self createAlertController];
    }
}

- (void)createAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CAMERA", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self displayImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
        }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_ALBUMS", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self displayImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
        }]];
    }
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [menus addObject:NSLocalizedString(@"GLOBAL_CAMERA", nil)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [menus addObject:NSLocalizedString(@"GLOBAL_ALBUMS", nil)];
    }
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"GLOBAL_CAMERA", nil)]) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"GLOBAL_ALBUMS", nil)]) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)displayImagePickerWithType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    cameraUI.sourceType = type;
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	if (!currentDocumentKey) {
		UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
		UIImage *resizedImage = [originalImage resize:CGSizeMake(640, 0)];
		NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);

		[userView setImageFromData:imageData];

		[picker dismissViewControllerAnimated:YES completion: ^{
		    [[Flooz sharedInstance] showLoadView];
		    [[Flooz sharedInstance] uploadDocument:imageData field:@"picId" success:NULL failure:NULL];
		}];
	}
	else {
		UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
		UIImage *resizedImage = [originalImage resize:CGSizeMake(640, 0)];
		NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);

		NSString *key = currentDocumentKey;

		[picker dismissViewControllerAnimated:YES completion: ^{
		    [[Flooz sharedInstance] showLoadView];
		    [[Flooz sharedInstance] uploadDocument:imageData field:key success: ^{
		        NSUInteger index = 0;
		        for (NSDictionary * dic in documents) {
		            if ([[[dic allValues] firstObject] isEqualToString:currentDocumentKey]) {
		                break;
					}
		            index++;
				}
                
                UIImageView *imageView = [documentsButton objectAtIndex:index];
                [imageView setImage:[UIImage imageNamed:@"friends-field-in"]];
			} failure:NULL];
		}];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[picker dismissViewControllerAnimated:YES completion:NULL];
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
