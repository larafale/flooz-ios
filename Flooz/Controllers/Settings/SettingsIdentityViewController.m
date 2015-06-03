//
//  SettingsIdentityViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-03.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SettingsIdentityViewController.h"

#import "FLKeyboardView.h"

#define PADDING_SIDE 20.0f

@interface SettingsIdentityViewController () {
	UIScrollView *_contentView;

	NSMutableDictionary *_userDic;
	NSMutableDictionary *_sepa;

	FLUserView *userView;
	FLTextFieldSignup *_name;
	FLTextFieldSignup *_userName;
	FLTextFieldSignup *_birthday;
    FLTextFieldSignup *_coupon;

	NSMutableArray *fieldsView;
	FLKeyboardView *inputView;


	NSArray *documents;
	NSMutableArray *documentsButton;

	NSInteger registerButtonCount;
	NSString *currentDocumentKey;

	FLActionButton *_saveButton;
    
    CGFloat height;
}

@end

@implementation SettingsIdentityViewController

- (void)viewDidLoad {
	self.title = NSLocalizedString(@"SETTINGS_IDENTITY", @"");
	[super viewDidLoad];

	[self initWithInfo];
    
    documentsButton = [NSMutableArray new];
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
		_userName = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_USERNAME" for:_userDic key:@"nick" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_name.frame) + 3.0f)];
		[_userName addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_userName addForTextChangeTarget:self action:@selector(canValidate:)];
		[_userName setUserInteractionEnabled:NO];
		[_userName setEnable:NO];
//		[_contentView addSubview:_userName];
	}

	{
		_birthday = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_BIRTHDAY" for:_userDic key:@"birthdate" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_name.frame) + 3.0f)];
		[_birthday addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_birthday addForTextChangeTarget:self action:@selector(canValidate:)];
//		[_contentView addSubview:_birthday];
//		[fieldsView addObject:_birthday];

		inputView = [FLKeyboardView new];
		inputView.textField = _birthday.textfield;
		_birthday.textfield.inputView = inputView;
	}

	height = CGRectGetMaxY(_name.frame);
    
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
	if ([currentUser username]) {
		[_userDic setObject:[currentUser username] forKey:@"nick"];
	}
    if ([currentUser birthdate]) {
        [_userDic setObject:[currentUser birthdate] forKey:@"birthdate"];
    }
	_sepa = [[currentUser sepa] mutableCopy];

	documents = @[
	        @{ @"CARD_ID_RECTO": @"cniRecto" },
	        @{ @"CARD_ID_VERSO": @"cniVerso" }
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
	_saveButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"Save", nil)];
	[_saveButton setEnabled:NO];
}

- (void)registerButtonForAction:(UIButton *)button {
	SEL action;
	switch (registerButtonCount) {
		case 0:
			action = @selector(didDocumentTouch0);
			break;

		case 1:
			action = @selector(didDocumentTouch1);
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

	if (!_userDic[@"lastName"] || !_userDic[@"firstName"] || [_userDic[@"lastName"] isBlank] || [_userDic[@"firstName"] isBlank]) {
		canValidate = NO;
	}

	if (!_userDic[@"birthdate"] || !([_userDic[@"birthdate"] length] == 12 || [_userDic[@"birthdate"] length] == 14)) {
		canValidate = NO;
	}

	if (canValidate) {
		[_saveButton setEnabled:YES];
	}
	else {
		[_saveButton setEnabled:NO];
	}
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
	    [self dismissViewController];
	} failure:NULL];
}

- (void)didDocumentTouch0 {
	currentDocumentKey = [[documents[0] allValues] firstObject];
	[self showImagePicker];
}

- (void)didDocumentTouch1 {
	currentDocumentKey = [[documents[1] allValues] firstObject];
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
    if ([[[Flooz sharedInstance] currentUser] settings][currentDocumentKey] && ([[[[Flooz sharedInstance] currentUser] checkDocuments][currentDocumentKey] intValue] == 1 || [[[[Flooz sharedInstance] currentUser] checkDocuments][currentDocumentKey] intValue] == 2)) {
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
    if (type == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (authStatus == AVAuthorizationStatusAuthorized) {
            UIImagePickerController *cameraUI = [UIImagePickerController new];
            cameraUI.sourceType = type;
            cameraUI.delegate = self;
            cameraUI.allowsEditing = YES;
            [self presentViewController:cameraUI animated:YES completion: ^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
        } else if (authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted){
                    UIImagePickerController *cameraUI = [UIImagePickerController new];
                    cameraUI.sourceType = type;
                    cameraUI.delegate = self;
                    cameraUI.allowsEditing = YES;
                    [self presentViewController:cameraUI animated:YES completion: ^{
                        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                    }];
                } else {
                    
                }
            }];
        } else {
            UIAlertView* curr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CAMERA_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CAMERA_CONTENT", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
            [curr setTag:125];
            dispatch_async(dispatch_get_main_queue(), ^{
                [curr show];
            });
        }
    } else {
        UIImagePickerController *cameraUI = [UIImagePickerController new];
        cameraUI.sourceType = type;
        cameraUI.delegate = self;
        cameraUI.allowsEditing = YES;
        [self presentViewController:cameraUI animated:YES completion: ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 125 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	if (currentDocumentKey) {
		UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
		UIImage *resizedImage = [originalImage resize:CGSizeMake(640, 0)];
		NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);

		NSString *key = currentDocumentKey;

		[picker dismissViewControllerAnimated:YES completion: ^{
		    [[Flooz sharedInstance] uploadDocument:imageData field:key success:nil failure:NULL];
            
            NSUInteger index = 0;
            for (NSDictionary * dic in documents) {
                if ([[[dic allValues] firstObject] isEqualToString:currentDocumentKey]) {
                    break;
                }
                index++;
            }
            
            UIImageView *imageView = [documentsButton objectAtIndex:index];
            [imageView setImage:[UIImage imageNamed:@"friends-field-in"]];
		}];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
