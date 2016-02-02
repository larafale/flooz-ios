//
//  SettingsIdentityViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-03.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SettingsDocumentsViewController.h"

#import "FLKeyboardView.h"

#define PADDING_SIDE 20.0f

@interface SettingsDocumentsViewController () {
	UIScrollView *_contentView;

	NSMutableDictionary *_userDic;
	NSMutableDictionary *_sepa;

	FLUserView *userView;

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

@implementation SettingsDocumentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"SETTINGS_DOCUMENTS", @"");

	[self initWithInfo];
    
    documentsButton = [NSMutableArray new];
	fieldsView = [NSMutableArray new];

    _contentView = [UIScrollView newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
	[_mainBody addSubview:_contentView];
    
	height = 5.0f;
    
    for (NSDictionary *dic in documents) {
        NSString *key = [[dic allKeys] firstObject];
        NSString *value = [[dic allValues] firstObject];
        [self createDocumentsButtonWithKey:key andValue:value];
    }

    UILabel *infos = [[UILabel alloc] initWithText:[Flooz sharedInstance].currentTexts.menu[@"documents"][@"info"] textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    [infos setLineBreakMode:NSLineBreakByWordWrapping];
    
    CGRectSetWidth(infos.frame, CGRectGetWidth(_contentView.frame) - PADDING_SIDE * 2);
    [infos sizeToFit];
    CGRectSetXY(infos.frame, CGRectGetWidth(_contentView.frame) / 2 - CGRectGetWidth(infos.frame) / 2, height + PADDING_SIDE);

    [_contentView addSubview:infos];
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), height);
    
    [self addTapGestureForDismissKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {

}

- (void)initWithInfo {

	documents = @[
	        @{ @"CARD_ID_RECTO": @"cniRecto" },
	        @{ @"CARD_ID_VERSO": @"cniVerso" },
            @{ @"HOME": @"justificatory" },
            @{ @"HOME2": @"justificatory2" }
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

- (void)registerButtonForAction:(UIButton *)button {
	SEL action;
	switch (registerButtonCount) {
		case 0:
			action = @selector(didDocumentTouch0);
			break;

		case 1:
			action = @selector(didDocumentTouch1);
			break;
            
        case 2:
            action = @selector(didDocumentTouch2);
            break;
            
        case 3:
            action = @selector(didDocumentTouch3);
            break;

		default:
			action = nil;
			break;
	}

	[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
	registerButtonCount++;
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

- (void)didDocumentTouch3 {
    currentDocumentKey = [[documents[3] allValues] firstObject];
    [self showImagePicker];
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
            UIAlertView* curr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CAMERA_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CAMERA_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
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
