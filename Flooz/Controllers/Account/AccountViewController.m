//
//  AccountViewController.m
//  Flooz
//
//  Created by olivier on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "AccountViewController.h"
#import "FLAccountUserView.h"

#import "AccountProfilViewController.h"
#import "NotificationsViewController.h"
#import "ShareAppViewController.h"
#import "CashOutViewController.h"
#import "SettingsViewController.h"
#import "ScannerViewController.h"

#import "AppDelegate.h"
#import "FLBadgeView.h"

@interface AccountViewController () {
    FLAccountUserView *userView;
    UITableView *_tableView;
    NSArray *_menuDic;
    FLBadgeView *_badge;
    UIImageView *navBarHairlineImageView;
}

@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self prepareTitleViews];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor customBackground]];
    
    {
        userView = [[FLAccountUserView alloc] initWithShadow:[(FLNavigationController*)self.navigationController shadowImage]];
        [userView addEditTarget:self action:@selector(showMenuAvatar)];
    }
    
    {
       
        _menuDic = @[
                     @{@"title":@"Compte",
                       @"items":@[
                             @{@"title":NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil)},
                             @{@"title":NSLocalizedString(@"SETTINGS_CARD", @"")},
                             @{@"title":NSLocalizedString(@"SETTINGS_BANK", @"")},
                             @{@"title":NSLocalizedString(@"SETTINGS_IDENTITY", @"")},
                             @{@"title":NSLocalizedString(@"SETTINGS_COORDS", @"")}
                             ]
                       },
                     @{@"title":@"Reglages",
                       @"items":@[
                             @{@"title":NSLocalizedString(@"SETTINGS_PREFERENCES", @"")},
                             @{@"title":NSLocalizedString(@"SETTINGS_SECURITY", @"")}
                             ]
                       },
                     @{@"title":@"Divers",
                       @"items":@[
                             @{@"title":NSLocalizedString(@"INFORMATIONS_RATE", @"")},
                             @{@"title":NSLocalizedString(@"INFORMATIONS_FAQ", @"")},
                             @{@"title":NSLocalizedString(@"INFORMATIONS_TERMS", @"")},
                             @{@"title":NSLocalizedString(@"INFORMATIONS_CONTACT", @"")},
                             @{@"title":NSLocalizedString(@"SETTINGS_IDEAS_CRITICS", @"")},
                             ]
                       }
                     ];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), PPScreenHeight() - PPTabBarHeight() * 2) style:UITableViewStyleGrouped];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_tableView setSeparatorColor:[UIColor customBackground]];
        [_tableView setBounces:NO];
        [self.view addSubview:_tableView];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    
    [[Flooz sharedInstance] updateCurrentUserWithSuccess: ^{
        [self reloadCurrentUser];
    }];
}

- (void)prepareTitleViews {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(-5.0f, 0.0f, PPScreenWidth(), NAVBAR_HEIGHT)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 22)];
    
    label.font = [UIFont customTitleNav];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor customBlue];
    label.text = [Flooz sharedInstance].currentUser.fullname;
    
    [titleView addSubview:label];

    UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(label.frame) , PPScreenWidth(), 20)];
    
    username.font = [UIFont customTitleExtraLight:15];
    username.textAlignment = NSTextAlignmentCenter;
    username.textColor = [UIColor whiteColor];
    username.text = [NSString stringWithFormat:@"@%@", [Flooz sharedInstance].currentUser.username];
    
    CGFloat fullnameSize = [label.text widthOfString:label.font];
    CGFloat usernameSize = [username.text widthOfString:username.font];
    
    CGFloat viewSize = MAX(fullnameSize, usernameSize);
    
    CGRectSetWidth(titleView.frame, viewSize);
    CGRectSetWidth(label.frame, viewSize);
    CGRectSetWidth(username.frame, viewSize);
    
    [titleView addSubview:username];
    self.navigationItem.titleView = titleView;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (_tableView.contentOffset.y < userView.frame.size.height)
        [(FLNavigationController*)self.navigationController hideShadow];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerNotification:@selector(reloadCurrentUser) name:kNotificationReloadCurrentUser object:nil];
    [self registerNotification:@selector(editAvatarWith:) name:@"editAvatar" object:nil];
}

#pragma mark - tableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        return [[[_menuDic objectAtIndex:section - 1] objectForKey:@"items"] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _menuDic.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return CGRectGetHeight(userView.frame);
    else
        return 30;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return userView;
    else {
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), [self tableView:tableView heightForHeaderInSection:section])];
        
        UILabel *headerTitle = [[UILabel alloc] initWithText:[[[_menuDic objectAtIndex:section - 1] objectForKey:@"title"] uppercaseString] textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
        
        [headerView addSubview:headerTitle];
        
        CGRectSetX(headerTitle.frame, 14);
        CGRectSetY(headerTitle.frame, CGRectGetHeight(headerView.frame) / 2 - CGRectGetHeight(headerTitle.frame) / 2);
        
        return headerView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    if (indexPath.section > 0) {
        NSDictionary *rowDic = [[[_menuDic objectAtIndex:indexPath.section - 1] objectForKey:@"items"] objectAtIndex:indexPath.row];
        
        [cell setBackgroundColor:[UIColor customBackgroundHeader]];
        [cell.textLabel setText:rowDic[@"title"]];
        [cell.textLabel setTextColor:[UIColor customPlaceholder]];
        [cell.textLabel setFont:[UIFont customContentLight:15]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell.textLabel setText:@""];
    }

    //    [cell setMenu:menuDic];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 0;
    else
        return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_tableView.contentOffset.y < userView.frame.size.height)
        [(FLNavigationController*)self.navigationController hideShadow];
    else
        [(FLNavigationController*)self.navigationController showShadow];
}

#pragma mark - SEGUE

//- (void)profilSettings {
//    [[Flooz sharedInstance] updateCurrentUser];
//    //    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[AccountProfilViewController new]];
//    //    [self presentViewController:controller animated:YES completion:NULL];
//    
//    [self.navigationController pushViewController:[AccountProfilViewController new] animated:YES];
//}
//
//- (void)notifications {
//    //    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[NotificationsViewController new]];
//    //    [self presentViewController:controller animated:YES completion:NULL];
//    
//    [self.navigationController pushViewController:[NotificationsViewController new] animated:YES];
//}
//
//- (void)inviteFriends {
//    //    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[ShareAppViewController new]];
//    //    [self presentViewController:controller animated:YES completion:NULL];
//    
//    [self.navigationController pushViewController:[ShareAppViewController new] animated:YES];
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (alertView.tag == 125 && buttonIndex == 1)
//    {
//        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
//    }
//}
//
//- (void)scanCode {
//    //    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[ScannerViewController new]];
//    //    [self presentViewController:controller animated:YES completion:NULL];
//    
//    [self.navigationController pushViewController:[ScannerViewController new] animated:YES];
//}
//
//- (void)cashOut {
//    [[Flooz sharedInstance] showLoadView];
//    [[Flooz sharedInstance] cashoutValidate: ^(id result) {
//        //        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[CashOutViewController new]];
//        //        [self presentViewController:controller animated:YES completion:NULL];
//        
//        [self.navigationController pushViewController:[CashOutViewController new] animated:YES];
//    } failure: ^(NSError *error) {
//        //[self presentEditAccountController];
//    }];
//}
//
//- (void)settings {
//    //    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[SettingsViewController new]];
//    //    [self presentViewController:controller animated:YES completion:NULL];
//    
//    [self.navigationController pushViewController:[SettingsViewController new] animated:YES];
//}

- (void)reloadCurrentUser {
    [userView reloadData];
    [_tableView reloadData];
}

#pragma mark - avatar

- (void)showMenuAvatar {
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
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        [self getPhotoFromFacebook];
    }]];
    
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
    [menus addObject:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil)];
    
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
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil)]) {
        [self getPhotoFromFacebook];
    }
}

- (void)editAvatarWith:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[NSData class]]) {
        NSData *imageData = (NSData *)notification.object;
        [userView reloadAvatarWithImageData:imageData];
    }
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
        UIAlertView* curr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CAMERA_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CAMERA_CONTENT", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
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

- (void)getPhotoFromFacebook {
    [[Flooz sharedInstance] getFacebookPhoto: ^(id result) {
        if (result[@"id"]) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?&width=134&height=134", result[@"id"]]]];
            [self sendData:imageData];
        }
    }];
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
    
    [self sendData:imageData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendData:(NSData *)imageData {
    [[Flooz sharedInstance] uploadDocument:imageData field:@"picId" success:NULL failure:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"editAvatar" object:imageData];
}

@end
