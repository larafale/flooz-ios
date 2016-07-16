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
    //
    //	NSMutableArray *fieldsView;
    //	FLKeyboardView *inputView;
    
    
    NSArray *documents;
    NSMutableArray *buttons;
    NSMutableArray *documentsButton;
    
    NSString *currentDocumentKey;
    
    //	FLActionButton *_saveButton;
    
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
    buttons = [NSMutableArray new];
    
    _contentView = [UIScrollView newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [_mainBody addSubview:_contentView];
    
    height = PADDING_SIDE;
    
    NSString *contentString = [Flooz sharedInstance].currentTexts.menu[@"documents"][@"content"];
    
    if (self.triggerData && self.triggerData[@"content"] && ![self.triggerData[@"content"] isBlank])
        contentString = self.triggerData[@"content"];
    
    if (contentString && ![contentString isBlank]) {
        UILabel *infosLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE, height, PPScreenWidth() - 2 * PADDING_SIDE, 0)];
        [infosLabel setText:contentString];
        [infosLabel setTextColor:[UIColor whiteColor]];
        [infosLabel setTextAlignment:NSTextAlignmentCenter];
        [infosLabel setFont:[UIFont customContentRegular:15]];
        [infosLabel setNumberOfLines:0];
        [infosLabel setLineBreakMode:NSLineBreakByWordWrapping];
        
        [infosLabel setHeightToFit];
        
        [_contentView addSubview:infosLabel];
        
        height = CGRectGetMaxY(infosLabel.frame) + PADDING_SIDE;
    }
    
    NSString *picString = [Flooz sharedInstance].currentTexts.menu[@"documents"][@"pic"];
    
    if (self.triggerData && self.triggerData[@"pic"] && ![self.triggerData[@"pic"] isBlank])
        picString = self.triggerData[@"pic"];
    
    if (picString && ![picString isBlank]) {
        UIImageView *cardInfos = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING_SIDE, height, PPScreenWidth() - 2 * PADDING_SIDE, 150)];
        [cardInfos setContentMode:UIViewContentModeScaleAspectFit];
        [cardInfos sd_setImageWithURL:[NSURL URLWithString:picString]];
        
        [_contentView addSubview:cardInfos];
        
        height = CGRectGetMaxY(cardInfos.frame) + PADDING_SIDE;
    }
    
    for (NSDictionary *dic in documents) {
        NSString *title = dic[@"title"];
        NSString *key = dic[@"key"];
        [self createDocumentsButtonWithKey:key andValue:title];
    }
    
    NSString *infoString = [Flooz sharedInstance].currentTexts.menu[@"documents"][@"info"];
    
    if (self.triggerData && self.triggerData[@"info"] && ![self.triggerData[@"info"] isBlank])
        infoString = self.triggerData[@"info"];
    
    if (infoString && ![infoString isBlank]) {
        UILabel *infos = [[UILabel alloc] initWithText:infoString textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentCenter numberOfLines:0];
        [infos setLineBreakMode:NSLineBreakByWordWrapping];
        
        CGRectSetWidth(infos.frame, CGRectGetWidth(_contentView.frame) - PADDING_SIDE * 2);
        [infos sizeToFit];
        CGRectSetXY(infos.frame, CGRectGetWidth(_contentView.frame) / 2 - CGRectGetWidth(infos.frame) / 2, height + PADDING_SIDE);
        
        [_contentView addSubview:infos];
        
        height = CGRectGetMaxY(infos.frame) + PADDING_SIDE;
    }
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), height);
    
    [self addTapGestureForDismissKeyboard];
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)initWithInfo {
    
    documents = [Flooz sharedInstance].currentTexts.menu[@"documents"][@"items"];
    
    if (self.triggerData != nil && self.triggerData[@"items"] && [self.triggerData[@"items"] count])
        documents = self.triggerData[@"items"];
}

- (void)createDocumentsButtonWithKey:(NSString *)key andValue:(NSString *)value {
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, height, PPScreenWidth() - PADDING_SIDE * 2.0f, 45)];
    [_contentView addSubview:view];
    height = CGRectGetMaxY(view.frame);
    
    [buttons addObject:view];
    
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDocumentButtonClick:)]];
    
    view.backgroundColor = [UIColor customBackgroundHeader];
    view.titleLabel.font = [UIFont customTitleExtraLight:16];
    view.titleLabel.textColor = [UIColor whiteColor];
    
    [view setTitle:value forState:UIControlStateNormal];
    view.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [view setTitleEdgeInsets:UIEdgeInsetsMake(0, 10.0f, 0, 0)];
    
    {
        UIImageView *imageView = [UIImageView new];
        if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:key] intValue] == 0){
            imageView = [UIImageView imageNamed:@"document-refused"];
        } else if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:key] intValue] == 1 || [[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:key] intValue] == 2) {
            imageView = [UIImageView imageNamed:@"friends-field-in"];
        } else if ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:key] intValue] == 3 || [[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:key] intValue] == 4){
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

- (void)didDocumentButtonClick:(UITapGestureRecognizer *)gestureRecognizer {
    UIView *sender = gestureRecognizer.view;
    
    NSInteger pos = [buttons indexOfObject:sender];
    
    if (pos != NSNotFound) {
        currentDocumentKey = documents[pos][@"key"];
        [self showImagePicker];
    }
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
    
    NSString *message = nil;
    
    if ([currentDocumentKey isEqualToString:@"card"]) {
        message = @"Les 6 premiers et 4 derniers chiffres ainsi que le nom doivent être visibles";
    }
    
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleActionSheet];
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
                if ([dic[@"key"] isEqualToString:currentDocumentKey]) {
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
