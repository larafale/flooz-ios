//
//  EditProfileViewController.m
//  Flooz
//
//  Created by Epitech on 10/1/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "EditProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FLTextFieldSignup.h"
#import "FLSwitch.h"

@interface EditProfileViewController () {
    UITableView *tableView;
    
    FLTextFieldSignup *locationView;
    FLTextView *bioView;
    FLTextFieldSignup *websiteView;
    UIImageView *coverPreview;
    UIImageView *avatarPreview;
    FLSwitch *facebookSwitch;

    
    NSMutableDictionary *data;
    
    UIBarButtonItem *saveItem;
    
    NSString *currentDocId;
}

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    data = [NSMutableDictionary new];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"PROFILE", nil);
    
    saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveData)];
    [saveItem setEnabled:NO];
    [saveItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont customContentRegular:16], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = saveItem;
    
    avatarPreview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    avatarPreview.layer.masksToBounds = YES;
    avatarPreview.layer.cornerRadius = 5;
    avatarPreview.contentMode = UIViewContentModeScaleAspectFill;
    avatarPreview.tag = 1;

    coverPreview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    coverPreview.layer.masksToBounds = YES;
    coverPreview.layer.cornerRadius = 5;
    coverPreview.contentMode = UIViewContentModeScaleAspectFill;
    coverPreview.tag = 1;
    
    bioView = [[FLTextView alloc] initWithPlaceholder:NSLocalizedString(@"EDIT_BIO", nil) for:data key:@"bio" frame:CGRectMake(10, 10, PPScreenWidth() - 20, 90)];
    bioView.layer.masksToBounds = YES;
    bioView.layer.cornerRadius = 3;
    [bioView addTextChangeTarget:self action:@selector(textChange)];
    [bioView setText:[Flooz sharedInstance].currentUser.bio];

    locationView = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"HINT_LOCATION", nil) for:data key:@"location" frame:CGRectMake(10, 4, PPScreenWidth() - 20, 30)];
    locationView.layer.masksToBounds = YES;
    locationView.layer.cornerRadius = 1;
    locationView.bottomBar.hidden = YES;
    [locationView addForTextChangeTarget:self action:@selector(textChange)];
    [locationView setTextOfTextField:[Flooz sharedInstance].currentUser.location];

    websiteView = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"HINT_WEBSITE", nil) for:data key:@"website" frame:CGRectMake(10, 4, PPScreenWidth() - 20, 30)];
    websiteView.layer.masksToBounds = YES;
    websiteView.layer.cornerRadius = 1;
    websiteView.bottomBar.hidden = YES;
    websiteView.textfield.keyboardType = UIKeyboardTypeURL;
    [websiteView addForTextChangeTarget:self action:@selector(textChange)];
    [websiteView setTextOfTextField:[Flooz sharedInstance].currentUser.website];

    facebookSwitch = [FLSwitch new];
    [facebookSwitch addTarget:self action:@selector(didSwitchChange) forControlEvents:UIControlEventValueChanged];

    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView setBackgroundColor:[UIColor customBackgroundHeader]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBounces:NO];
    
    [_mainBody addSubview:tableView];
    
    [self refreshFBStatus];
    
    [self registerNotification:@selector(refreshFBStatus) name:kNotificationFbConnect object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)refreshFBStatus {
    if ([[Flooz sharedInstance] facebook_token]) {
        facebookSwitch.on = YES;
    }
    else {
        facebookSwitch.on = NO;
    }
}

- (void)didSwitchChange {
    if (!facebookSwitch.on)
        [[Flooz sharedInstance] disconnectFacebook];
    else {
        [[Flooz sharedInstance] connectFacebook];
    }
}

- (void)textChange {
    if ([data[@"bio"] isEqualToString:[Flooz sharedInstance].currentUser.bio]
        && [data[@"location"] isEqualToString:[Flooz sharedInstance].currentUser.location]
        && [data[@"website"] isEqualToString:[Flooz sharedInstance].currentUser.website])
        [saveItem setEnabled:NO];
    else
        [saveItem setEnabled:YES];
}

- (void)saveData {
    [self.view endEditing:YES];
    [saveItem setEnabled:NO];
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateUser:data success:nil failure:^(NSError *error) {
        [saveItem setEnabled:YES];
    }];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 2)
        return 60;
    else if (indexPath.section == 2)
        return 110;
    else if (indexPath.section > 2 && indexPath.section <= 5)
        return 50;
    return CGFLOAT_MIN;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 1)];
    [back setBackgroundColor:[UIColor customBackground]];
    
    return back;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return [self generateAvatarCell];
    else if (indexPath.section == 1)
        return [self generateCoverCell];
    else if (indexPath.section == 2)
        return [self generateBioCell];
    else if (indexPath.section == 3)
        return [self generateLocationCell];
    else if (indexPath.section == 4)
        return [self generateWebsiteCell];
    else
        return [self generateFbCell];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        currentDocId = @"picId";
        [self showMenuPhoto];
    }
    if (indexPath.section == 1) {
        currentDocId = @"coverId";
        [self showMenuPhoto];
    }
    if (indexPath.section == 2) {
        [bioView becomeFirstResponder];
    }
}

- (UITableViewCell *)generateAvatarCell {
    static NSString *cellIdentifier = @"AvatarCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
        UILabel *avatarLabel = [[UILabel alloc] initWithText:NSLocalizedString(@"EDIT_AVATAR", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:17] textAlignment:NSTextAlignmentLeft numberOfLines:1];
        avatarLabel.tag = 2;
        CGRectSetX(avatarLabel.frame, CGRectGetMaxX(avatarPreview.frame) + 15);
        CGRectSetY(avatarLabel.frame, 30 - CGRectGetHeight(avatarLabel.frame) / 2);
        
        [cell addSubview:avatarPreview];
        [cell addSubview:avatarLabel];
    }
    
    [(UIImageView *)[cell viewWithTag:1] sd_setImageWithURL:[NSURL URLWithString:[Flooz sharedInstance].currentUser.avatarURL] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    
    return cell;
}

- (UITableViewCell *)generateCoverCell {
    static NSString *cellIdentifier = @"CoverCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UILabel *coverLabel = [[UILabel alloc] initWithText:NSLocalizedString(@"EDIT_COVER", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:17] textAlignment:NSTextAlignmentLeft numberOfLines:1];
        coverLabel.tag = 2;
        CGRectSetX(coverLabel.frame, CGRectGetMaxX(coverPreview.frame) + 15);
        CGRectSetY(coverLabel.frame, 30 - CGRectGetHeight(coverLabel.frame) / 2);
        
        [cell addSubview:coverPreview];
        [cell addSubview:coverLabel];
    }
    
    [(UIImageView *)[cell viewWithTag:1] sd_setImageWithURL:[NSURL URLWithString:[Flooz sharedInstance].currentUser.coverURL] placeholderImage:[UIImage imageNamed:@"back-secure"]];
    
    return cell;
}

- (UITableViewCell *)generateBioCell {
    static NSString *cellIdentifier = @"BioCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        [cell addSubview:bioView];
    }
    
    return cell;
}

- (UITableViewCell *)generateLocationCell {
    static NSString *cellIdentifier = @"LocationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UILabel *title = [UILabel newWithText:NSLocalizedString(@"EDIT_LOCATION", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:16] textAlignment:NSTextAlignmentLeft numberOfLines:1];
        [title setWidthToFit];
        
        CGRectSetPosition(title.frame, 10, 25 - CGRectGetHeight(title.frame) / 2);
        CGRectSetX(locationView.frame, CGRectGetMaxX(title.frame) + 10);
        CGRectSetWidth(locationView.frame, PPScreenWidth() - CGRectGetMinX(locationView.frame) - 20);
        
        [cell addSubview:title];
        [cell addSubview:locationView];
    }
    
    return cell;
}

- (UITableViewCell *)generateWebsiteCell {
    static NSString *cellIdentifier = @"WebsiteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UILabel *title = [UILabel newWithText:NSLocalizedString(@"EDIT_WEBSITE", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:16] textAlignment:NSTextAlignmentLeft numberOfLines:1];
        [title setWidthToFit];
        
        CGRectSetPosition(title.frame, 10, 25 - CGRectGetHeight(title.frame) / 2);
        CGRectSetX(websiteView.frame, CGRectGetMaxX(title.frame) + 10);
        CGRectSetWidth(websiteView.frame, PPScreenWidth() - CGRectGetMinX(websiteView.frame) - 20);
        
        [cell addSubview:title];

        [cell addSubview:websiteView];
    }
    
    return cell;
}

- (UITableViewCell *)generateFbCell {
    static NSString *cellIdentifier = @"FBCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        UILabel *title = [UILabel newWithText:NSLocalizedString(@"SETTINGS_FACEBOOK", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:16] textAlignment:NSTextAlignmentLeft numberOfLines:1];
        [title setWidthToFit];
        
        CGRectSetPosition(title.frame, 10, 25 - CGRectGetHeight(title.frame) / 2);
        
        [cell addSubview:title];
        
        [cell setAccessoryView:facebookSwitch];
    }
    
    return cell;
  
}

#pragma mark - avatar

- (void)showMenuPhoto {
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
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self presentPhoto];
        }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self presentLibrary];
        }]];
    }
//    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
//        [self getPhotoFromFacebook];
//    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [menus addObject:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [menus addObject:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil)];
    }
//    [menus addObject:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil)];
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil)]) {
        [self presentPhoto];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil)]) {
        [self presentLibrary];
    }
//    else if ([buttonTitle isEqualToString:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil)]) {
//        [self getPhotoFromFacebook];
//    }
}

- (void)presentPhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        UIImagePickerController *cameraUI = [UIImagePickerController new];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.delegate = self;
        cameraUI.allowsEditing = YES;
        [self presentViewController:cameraUI animated:YES completion: ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    } else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted){
                UIImagePickerController *cameraUI = [UIImagePickerController new];
                cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
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
}

- (void)presentLibrary {
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cameraUI.delegate = self;
    cameraUI.allowsEditing = YES;
    [self presentViewController:cameraUI animated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

//- (void)getPhotoFromFacebook {
//    [[Flooz sharedInstance] getFacebookPhoto: ^(id result) {
//        if (result[@"id"]) {
//            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?&width=9999&height=9999", result[@"id"]]]];
//            [self sendData:imageData];
//        }
//    }];
//}

//- (UIImage *)resizeImage:(UIImage *)image {
//    CGRect rect = CGRectMake(0.0, 0.0, 640.0, 640.0);
//    UIGraphicsBeginImageContext(rect.size);
//    [image drawInRect:rect];
//    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return img;
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage;
    
    if (editedImage)
        resizedImage = editedImage;
        //        resizedImage = [editedImage resize:CGSizeMake(640, 0)];
    else
        resizedImage = originalImage;
//        resizedImage = [originalImage resize:CGSizeMake(640, 0)];
    
//    NSData *imageData = UIImagePNGRepresentation(resizedImage);
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1);
    
//    NSLog(@"UIImagePNGRepresentation: image size is---->: %lu kb",[imageData length]/1024);
    
    [self sendData:imageData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendData:(NSData *)imageData {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] uploadDocument:imageData field:currentDocId success:^{
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        
        if ([currentDocId isEqualToString:@"picId"]) {
            [avatarPreview setImage:image];
        } else if ([currentDocId isEqualToString:@"coverId"])
            [coverPreview setImage:image];

        [[Flooz sharedInstance] updateCurrentUser];
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
    
    tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear {
    tableView.contentInset = UIEdgeInsetsZero;
}

@end
