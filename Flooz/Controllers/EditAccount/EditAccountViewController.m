//
//  EditAccountViewController.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "EditAccountViewController.h"
#import "AppDelegate.h"

#import "FLSwitchView.h"

#define MARGE 0.
#define MARGE_HEADER 20.

@interface EditAccountViewController () {
	NSMutableDictionary *_user;
	NSMutableDictionary *_sepa;
	FLUserView *userView;
	FLSwitchView *facebookButton;

	FLTextFieldIcon *fieldPhone;
	FLTextFieldIcon *fieldEmail;

	UIButton *sendValidationSMS;
	UIButton *sendValidationEmail;

	NSArray *documents;
	NSMutableArray *documentsButton;

	NSInteger registerButtonCount;
	NSString *currentDocumentKey;
}

@end

@implementation EditAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = NSLocalizedString(@"NAV_EDIT_ACCOUNT", nil);

		FLUser *currentUser = [[Flooz sharedInstance] currentUser];

		_user = [NSMutableDictionary new];
		[_user setObject:[NSMutableDictionary new] forKey:@"settings"];
		[[_user objectForKey:@"settings"] setObject:[[currentUser address] mutableCopy] forKey:@"address"];

		if ([currentUser lastname]) {
			[_user setObject:[currentUser lastname] forKey:@"lastName"];
		}
		if ([currentUser firstname]) {
			[_user setObject:[currentUser firstname] forKey:@"firstName"];
		}
		if ([currentUser email]) {
			[_user setObject:[currentUser email] forKey:@"email"];
		}
		if ([currentUser phone]) {
			[_user setObject:[currentUser phone] forKey:@"phone"];
		}

		_sepa = [[currentUser sepa] mutableCopy];

		documents = @[
		        @{ @"HOME": @"justificatory" }
		    ];

		documentsButton = [NSMutableArray new];

		registerButtonCount = 0;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self registerForKeyboardNotifications];

	self.view.backgroundColor = [UIColor customBackgroundHeader];
	self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(didValidTouch)];

	CGFloat height = 40;

	{
		UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(8, 16, 32, 32)];

		{
			userView = [[FLUserView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
			[userView setImageFromUser:[[Flooz sharedInstance] currentUser]];
			[view addSubview:userView];
		}

		[self registerButtonForAction:view];
		[_contentView addSubview:view];
	}

	{
		fieldPhone = [[FLTextFieldIcon alloc] initWithIcon:@"field-phone" placeholder:@"FIELD_PHONE" for:_user key:@"phone" position:CGPointMake(MARGE, height)];
		[_contentView addSubview:fieldPhone];
		height = CGRectGetMaxY(fieldPhone.frame);
	}

	{
		fieldEmail = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_user key:@"email" position:CGPointMake(MARGE, height)];
		[_contentView addSubview:fieldEmail];
		height = CGRectGetMaxY(fieldEmail.frame);
	}

	{
		sendValidationSMS = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100 - 5, 53, 100, 50)];

		sendValidationSMS.titleLabel.textAlignment = NSTextAlignmentRight;
		sendValidationSMS.titleLabel.font = [UIFont customContentRegular:12];
		[sendValidationSMS setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
		[sendValidationSMS setTitle:NSLocalizedString(@"EDIT_ACCOUNT_SEND_SMS", nil) forState:UIControlStateNormal];
		[_contentView addSubview:sendValidationSMS];

		[sendValidationSMS addTarget:self action:@selector(didSendSMSValidationTouch:) forControlEvents:UIControlEventTouchUpInside];

//        height = CGRectGetMaxY(sendValidationSMS.frame);
	}

	{
		sendValidationEmail = [[UIButton alloc] initWithFrame:CGRectMake(sendValidationSMS.frame.origin.x, 98, 100, CGRectGetHeight(sendValidationSMS.frame))];

		sendValidationEmail.titleLabel.textAlignment = NSTextAlignmentRight;
		sendValidationEmail.titleLabel.font = [UIFont customContentRegular:12];
		[sendValidationEmail setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
		[sendValidationEmail setTitle:NSLocalizedString(@"EDIT_ACCOUNT_SEND_MAIL", nil) forState:UIControlStateNormal];
		[_contentView addSubview:sendValidationEmail];

		[sendValidationEmail addTarget:self action:@selector(didSendEmailValidationTouch:) forControlEvents:UIControlEventTouchUpInside];
	}

	if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:@"phone"] intValue] != 2) {
		sendValidationSMS.hidden = YES;
	}
	else {
		[fieldPhone setReadOnly:YES];
	}

	if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:@"email"] intValue] != 2) {
		sendValidationEmail.hidden = YES;
	}
	else {
		[fieldEmail setReadOnly:YES];
	}

	{
		FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-address" placeholder:@"FIELD_ADDRESS" for:[[_user objectForKey:@"settings"] objectForKey:@"address"] key:@"address" position:CGPointMake(MARGE, height)];
		[_contentView addSubview:view];
		height = CGRectGetMaxY(view.frame);
	}

	{
		FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-zip-code" placeholder:@"FIELD_ZIP_CODE" for:[[_user objectForKey:@"settings"] objectForKey:@"address"] key:@"zipCode" position:CGPointMake(MARGE, height)];
		[_contentView addSubview:view];
		height = CGRectGetMaxY(view.frame);
	}

	{
		FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-city" placeholder:@"FIELD_CITY" for:[[_user objectForKey:@"settings"] objectForKey:@"address"] key:@"city" position:CGPointMake(MARGE, height)];
		[_contentView addSubview:view];
		height = CGRectGetMaxY(view.frame);
	}

	for (NSDictionary *dic in documents) {
		NSString *key = [[dic allKeys] firstObject];
		NSString *value = [[dic allValues] firstObject];

		UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, height, SCREEN_WIDTH, 45)];
		[_contentView addSubview:view];
		height = CGRectGetMaxY(view.frame);

		[self registerButtonForAction:view];
		view.backgroundColor = [UIColor customBackground];
		view.titleLabel.font = [UIFont customTitleExtraLight:16];
		view.titleLabel.textColor = [UIColor whiteColor];

		[view setTitle:NSLocalizedString(([NSString stringWithFormat:@"DOCUMENTS_%@", key]), nil) forState:UIControlStateNormal];
		view.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[view setTitleEdgeInsets:UIEdgeInsetsMake(0, 47, 0, 0)];

		UIImageView *imageView;


		if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:value] intValue] == 2 || ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:value] intValue] == 0 && [[[[Flooz sharedInstance] currentUser] settings] objectForKey:value])
		    ) {
			imageView = [UIImageView imageNamed:@"document-check"];
		}
		else {
			imageView = [UIImageView imageNamed:@"arrow-white-right"];
		}
		[documentsButton addObject:imageView];

		CGRectSetXY(imageView.frame, 290, 17);

		[view addSubview:imageView];

		{
			UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame) - 1, SCREEN_WIDTH, 1)];
			separator.backgroundColor = [UIColor customSeparator];
			[view addSubview:separator];
		}

		{
			UIImageView *icon = [UIImageView imageNamed:@"field-documents"];
			CGRectSetXY(icon.frame, 16, 17);
			[view addSubview:icon];
		}
	}

	_contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), height);
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self.navigationController setNavigationBarHidden:NO animated:YES];

	if ([[Flooz sharedInstance] facebook_token]) {
		facebookButton.on = YES;
	}
	else {
		facebookButton.on = NO;
	}
}

- (void)didValidTouch {
	[[self view] endEditing:YES];

	_user[@"settings"] = @{ @"sepa": _sepa };

	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] updateUser:_user success: ^(id result) {
	    [self dismissViewControllerAnimated:YES completion:NULL];
	} failure:NULL];
}

- (void)didFacebookTouch {
	[[Flooz sharedInstance] showLoadView];

	if ([[Flooz sharedInstance] facebook_token]) {
		facebookButton.on = NO;
		[[Flooz sharedInstance] disconnectFacebook];
	}
	else {
		facebookButton.on = YES;
		[[Flooz sharedInstance] connectFacebook];
	}
}

- (void)didSwitchViewSelected {
	[self didFacebookTouch];
}

- (void)didSwitchViewUnselected {
	[self didFacebookTouch];
}

- (void)registerButtonForAction:(UIButton *)button {
	SEL action;
	switch (registerButtonCount) {
		case 0:
			action = @selector(didDocumentTouch2);
			break;

		default:
			action = nil;
			break;
	}

	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	registerButtonCount++;
}

- (void)didEditAvatarTouch {
	currentDocumentKey = nil;
	[self showImagePicker];
}

- (void)didDocumentTouch0 {
	currentDocumentKey = [[documents[0] allValues] firstObject];
	[self showImagePicker];
}

- (void)didDocumentTouch1 {
	currentDocumentKey = [[documents[1] allValues] firstObject];
	[self showImagePicker];
}

- (void)didDocumentTouch2 {
	currentDocumentKey = [[documents[2] allValues] firstObject];
	[self showImagePicker];
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
    cameraUI.allowsEditing = YES;
    
    [self presentViewController:cameraUI animated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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

#pragma mark - ImagePicker

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
		        imageView.image = [UIImage imageNamed:@"document-check"];
		        CGRectSetWidthHeight(imageView.frame, imageView.image.size.width, imageView.image.size.height);
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
