//
//  EditProfileViewController.m
//  Flooz
//
//  Created by Epitech on 10/1/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "EditProfileViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EditProfileViewController () {
    UITableView *tableView;
    
    FLTextView *textView;
    UIImageView *coverPreview;
    UIImageView *avatarPreview;
    
    NSMutableDictionary *data;
    
    UIBarButtonItem *saveItem;
    
    NSString *currentDocId;
}

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    data = [NSMutableDictionary new];
    
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
    
    textView = [[FLTextView alloc] initWithPlaceholder:NSLocalizedString(@"EDIT_BIO", nil) for:data key:@"bio" frame:CGRectMake(10, 10, PPScreenWidth() - 20, 85)];
    textView.layer.masksToBounds = YES;
    textView.layer.cornerRadius = 3;
    [textView addTextChangeTarget:self action:@selector(textChange)];
    [textView setText:[Flooz sharedInstance].currentUser.bio];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [tableView setDataSource:self];
    [tableView setDelegate:self];
    [tableView setBackgroundColor:[UIColor customBackgroundHeader]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setBounces:NO];
    
    [_mainBody addSubview:tableView];
}

- (void)textChange {
    if ([data[@"bio"] isEqualToString:[Flooz sharedInstance].currentUser.bio])
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < 2)
        return 60;
    else if (indexPath.row == 0)
        return 110;
    else
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
    else
        return [self generateBioCell];
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
        [textView becomeFirstResponder];
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
        
        [cell addSubview:textView];
    }
    
    [textView setText:[Flooz sharedInstance].currentUser.bio];
    
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

@end
