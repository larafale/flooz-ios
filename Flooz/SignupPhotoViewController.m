//
//  SignupPhotoViewController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SignupInfosViewController.h"
#import "SignupPhotoViewController.h"

@interface SignupPhotoViewController () {
    FLUserView *_avatarView;
    FLActionButton *_avatarButton;
    FLActionButton *_registerFacebook;
    
    FLActionButton *_nextButton;
}

@end

@implementation SignupPhotoViewController

- (id)init {
    self = [super init];
    if (self) {
        self.userDic = [NSMutableDictionary new];
        self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Photo", @"");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _avatarButton = [[FLActionButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 100.0f)];
    [_avatarButton setBackgroundColor:[UIColor customBackgroundHeader]];
    [_avatarButton addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
    {
        CGFloat size = CGRectGetHeight(_avatarButton.frame) - 10.0f;
        _avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(((CGRectGetWidth(_avatarButton.frame) - size) / 2.0) - 5.0f, ((CGRectGetHeight(_avatarButton.frame) - size) / 2.0), size, size)];
        _avatarView.contentMode = UIViewContentModeScaleAspectFit;
        [_avatarButton addSubview:_avatarView];
    }
    [_mainBody addSubview:_avatarButton];
    
    UILabel *firstTimeText;
    {
        firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, CGRectGetMaxY(_avatarButton.frame), PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, 80)];
        firstTimeText.textColor = [UIColor whiteColor];
        firstTimeText.font = [UIFont customTitleExtraLight:14];
        firstTimeText.numberOfLines = 0;
        firstTimeText.textAlignment = NSTextAlignmentCenter;
        firstTimeText.text = NSLocalizedString(@"SIGNUP_PHOTO_EXPLICATION", nil);
        [_mainBody addSubview:firstTimeText];
    }
    
    {
        [self createFacebookButton];
        [_mainBody addSubview:_registerFacebook];
        CGRectSetY(_registerFacebook.frame, CGRectGetMaxY(firstTimeText.frame) + 5.0f);
    }
    
    FLActionButton *captureButton;
    {
        captureButton = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, CGRectGetMaxY(_registerFacebook.frame) + 7.0f, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight)];
        
        [captureButton setTitle:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil) forState:UIControlStateNormal];
        [captureButton.titleLabel setFont:[UIFont customTitleExtraLight:15]];
        [captureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [captureButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
        [captureButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];
        [captureButton setImage:[UIImage imageNamed:@"bar-camera"] size:CGSizeMake(20.0f, 20.0f)];
        
        [captureButton addTarget:self action:@selector(presentPhoto) forControlEvents:UIControlEventTouchUpInside];
        [captureButton setBackgroundColor:[UIColor customBackground] forState:UIControlStateNormal];
        [captureButton setBackgroundColor:[UIColor customBackground:0.5] forState:UIControlStateDisabled];
        [captureButton setBackgroundColor:[UIColor customBackground:0.5] forState:UIControlStateHighlighted];
        [_mainBody addSubview:captureButton];
    }
    
    FLActionButton *albumButton;
    {
        albumButton = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, CGRectGetMaxY(captureButton.frame) + 7.0f, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight)];
        
        [albumButton setTitle:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil) forState:UIControlStateNormal];
        [albumButton.titleLabel setFont:[UIFont customTitleExtraLight:15]];
        [albumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [albumButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
        [albumButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];
        [albumButton setImage:[UIImage imageNamed:@"camera-album"] size:CGSizeMake(20.0f, 18.0f)];
        
        [albumButton addTarget:self action:@selector(presentLibrary) forControlEvents:UIControlEventTouchUpInside];
        [albumButton setBackgroundColor:[UIColor customBackground] forState:UIControlStateNormal];
        [albumButton setBackgroundColor:[UIColor customBackground:0.5] forState:UIControlStateDisabled];
        [albumButton setBackgroundColor:[UIColor customBackground:0.5] forState:UIControlStateHighlighted];
        [_mainBody addSubview:albumButton];
    }
    
    {
        _nextButton = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, 0, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil)];
        [_nextButton setEnabled:YES];
        [_nextButton addTarget:self action:@selector(checkImage) forControlEvents:UIControlEventTouchUpInside];
        CGRectSetY(_nextButton.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(_nextButton.frame) - 20.0f);
        [_nextButton setBackgroundColor:[UIColor customBackground] forState:UIControlStateNormal];
        [_nextButton setBackgroundColor:[UIColor customBackground:0.5] forState:UIControlStateDisabled];
        [_nextButton setBackgroundColor:[UIColor customBackground:0.5] forState:UIControlStateHighlighted];
        
        [_mainBody addSubview:_nextButton];
    }
    
}

- (void)checkImage {
    NSMutableDictionary *dic = [self.userDic mutableCopy];
    if (self.userDic[@"picId"]) {
        [dic setValue:@YES forKey:@"hasImage"];
    }
    else {
        [dic setValue:@NO forKey:@"hasImage"];
    }
    [dic removeObjectForKey:@"picId"];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] signupPassStep:@"image" user:dic success:^(id result) {
        [self.navigationController pushViewController:[SignupInfosViewController new] animated:YES];
    } failure:^(NSError *error) {
        
    }];
}

- (void)createFacebookButton {
    _registerFacebook = [[FLActionButton alloc] initWithFrame:CGRectMake(SIGNUP_PADDING_SIDE, 0, PPScreenWidth() - SIGNUP_PADDING_SIDE * 2, FLActionButtonDefaultHeight)];
    [_registerFacebook setTitle:NSLocalizedString(@"LOGIN_FACEBOOK", nil) forState:UIControlStateNormal];
    _registerFacebook.titleLabel.font = [UIFont customTitleExtraLight:15];
    [_registerFacebook setBackgroundColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.6] forState:UIControlStateNormal];
    [_registerFacebook setBackgroundColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.3]  forState:UIControlStateDisabled];
    [_registerFacebook setBackgroundColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.3]  forState:UIControlStateHighlighted];
    [_registerFacebook setImage:[UIImage imageNamed:@"facebook"] size:CGSizeMake(16.0f, 16.0f)];
    
    [_registerFacebook addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didFacebookTouch {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] getInfoFromFacebook];
}

#pragma mark - imagePicker

- (void)showImagePicker {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        [self createActionSheet];
    }
    else {
        [self createAlertController];
    }
}

- (void)displayChanges {
    if (self.userDic[@"picId"] && ![self.userDic[@"picId"] isEqual:[NSData new]]) {
        [_avatarView setImageFromData:self.userDic[@"picId"]];
        
    } else if (self.userDic[@"avatarURL"] && ![self.userDic[@"avatarURL"] isBlank]) {
        [_avatarView setImageFromURL:self.userDic[@"avatarURL"]];
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

- (void)presentPhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)presentLibrary {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (UIImage *)resizeImage:(UIImage *)image {
    CGRect rect = CGRectMake(0.0, 0.0, 640.0, 640.0); // 240.0 rather then 120.0 for retina
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage;
    
    if (editedImage)
        resizedImage = [editedImage resize:CGSizeMake(640, 0)];
    else
        resizedImage = [originalImage resize:CGSizeMake(640, 0)];
    
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);
    
    [_avatarView setImageFromData:imageData];
    
    [self.userDic setValue:imageData forKey:@"picId"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
