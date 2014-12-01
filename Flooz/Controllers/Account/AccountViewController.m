//
//  AccountViewController.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "AccountViewController.h"
#import "FLAccountUserView.h"
#import "FLAccountButton.h"

#import "AccountProfilViewController.h"
#import "NotificationsViewController.h"
#import "ShareAppViewController.h"
#import "CashOutViewController.h"
#import "SettingsViewController.h"

#import "FLWaveAnimation.h"
#import "AppDelegate.h"
#import "FLBadgeView.h"

@interface AccountViewController () {
	FLAccountUserView *userView;
	UITableView *_tableView;
	NSArray *_menuArray;
	FLBadgeView *_badge;
}

@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = NSLocalizedString(@"NAV_ACCOUNT", nil);
	}
	return self;
}

- (void)loadView {
	[super loadView];

	self.view.backgroundColor = [UIColor customBackgroundHeader];

	{
		userView = [[FLAccountUserView alloc] initWithWidth:PPScreenWidth() - PADDING_NAV];
		[userView addEditTarget:self action:@selector(showMenuAvatar)];
	}

	{
		_menuArray = @[
		        @{ @"image":@"account-button-profil",
		           @"title":NSLocalizedString(@"ACCOUNT_BUTTON_PROFIL", @"") },
		        @{ @"image":@"account-button-notification",
		           @"title":NSLocalizedString(@"ACCOUNT_BUTTON_NOTIFICATION", @"") },
		        @{ @"image":@"account-button-share",
		           @"title":NSLocalizedString(@"ACCOUNT_BUTTON_INVITE", @"") },
		        @{ @"image":@"account-button-bank",
		           @"title":NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil) },
		        @{ @"image":@"account-button-divers",
		           @"title":NSLocalizedString(@"ACCOUNT_BUTTON_DIVERS", nil) }
		    ];

		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, PPStatusBarHeight(), PPScreenWidth(), PPScreenHeight() - PPStatusBarHeight()) style:UITableViewStyleGrouped];
		[_tableView setBackgroundColor:[UIColor customBackgroundHeader]];
		[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[_tableView setBounces:NO];
		[self.view addSubview:_tableView];
		[_tableView setDelegate:self];
		[_tableView setDataSource:self];
	}

	{
		CGFloat sizeBadge = 22.0f;
		if (IS_IPHONE4) {
			sizeBadge = 17.0f;
		}
		CGRect frame = CGRectMake(0.0f, 0.0f, sizeBadge, sizeBadge);
		_badge = [[FLBadgeView alloc] initWithFrame:frame];
		[self reloadBadge];
	}

	[[Flooz sharedInstance] updateCurrentUserWithSuccess: ^{
	    [self reloadCurrentUser];
	}];
}

- (void)reloadBadge {
	NSNumber *numberNotif = [[Flooz sharedInstance] notificationsCount];
	[_badge setNumber:numberNotif];
	if ([numberNotif intValue] == 0) {
		[_badge setHidden:YES];
	}
	else {
		[_badge setHidden:NO];
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self registerNotification:@selector(reloadCurrentUser) name:kNotificationReloadCurrentUser object:nil];
	[self registerNotification:@selector(reloadBadge) name:@"newNotifications" object:nil];
	[self registerNotification:@selector(editAvatarWith:) name:@"editAvatar" object:nil];
}

#pragma mark - tableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _menuArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return CGRectGetHeight(userView.frame);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return userView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"MenuCell";
	MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	NSDictionary *menuDic = _menuArray[indexPath.row];
	if (!cell) {
		cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

		NSString *title = menuDic[@"title"];
		if ([title isEqualToString:NSLocalizedString(@"ACCOUNT_BUTTON_NOTIFICATION", @"")]) {
			CGRectSetX(_badge.frame, CGRectGetMaxX(cell.imageMenu.frame) - CGRectGetWidth(_badge.frame) + 5.0f);
			[cell addSubview:_badge];
		}
	}

	[cell setMenu:menuDic];

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [MenuCell getHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		[self profilSettings];
	}
	else if (indexPath.row == 1) {
		[self notifications];
	}
    else if (indexPath.row == 2) {
		[self inviteFriends];
	}
	else if (indexPath.row == 3) {
		[self cashOut];
	}
	else if (indexPath.row == 4) {
		[self settings];
	}
}

#pragma mark - SEGUE

- (void)profilSettings {
	[[Flooz sharedInstance] updateCurrentUser];
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[AccountProfilViewController new]];
	[self presentViewController:controller animated:YES completion:NULL];
}

- (void)notifications {
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[NotificationsViewController new]];
	[self presentViewController:controller animated:YES completion:NULL];
}

- (void)inviteFriends {
    
    BOOL alreadyReask = [[NSUserDefaults standardUserDefaults] boolForKey:kKeyAccessContacts];

	[[Flooz sharedInstance] grantedAccessToContacts: ^(BOOL granted) {
	    if (granted) {
	        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[ShareAppViewController new]];
	        [self presentViewController:controller animated:YES completion:NULL];
		}
	    else {
            if (alreadyReask == YES)
            {
                if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
                {
                    UIAlertView* curr1=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CONTACT_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CONTACT_CONTENT", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
                            [curr1 setTag:125];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [curr1 show];
                    });
                }
                else
                {
                    UIAlertView* curr2=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CONTACT_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CONTACT_CONTENT", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [curr2 show];
                    });
                }
            }
		}
	}];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 125 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)cashOut {
	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] cashoutValidate: ^(id result) {
	    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[CashOutViewController new]];
	    [self presentViewController:controller animated:YES completion:NULL];
	} failure: ^(NSError *error) {
	    //[self presentEditAccountController];
	}];
}

- (void)settings {
	UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[SettingsViewController new]];
	[self presentViewController:controller animated:YES completion:NULL];
}

- (void)reloadCurrentUser {
	[userView reloadData];
	[_tableView reloadData];
	[self reloadBadge];
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
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.delegate = self;
    cameraUI.allowsEditing = YES;
    [self presentViewController:cameraUI animated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
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
