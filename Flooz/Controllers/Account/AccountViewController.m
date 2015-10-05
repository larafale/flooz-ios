//
//  AccountViewController.m
//  Flooz
//
//  Created by olivier on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "AccountViewController.h"
#import "FLAccountUserView.h"

#import "NotificationsViewController.h"
#import "ShareAppViewController.h"
#import "CashOutViewController.h"
#import "ScannerViewController.h"
#import "CreditCardViewController.h"
#import "SettingsBankViewController.h"
#import "SettingsCoordsViewController.h"
#import "SettingsDocumentsViewController.h"
#import "SettingsPreferencesViewController.h"
#import "SettingsSecurityViewController.h"
#import "WebViewController.h"
#import "FriendsViewController.h"
#import "DiscountCodeViewController.h"
#import "FriendRequestViewController.h"

#import "AccountCell.h"

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
        [self reloadData];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), PPScreenHeight() - PPTabBarHeight() - NAVBAR_HEIGHT - PPStatusBarHeight()) style:UITableViewStyleGrouped];
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
    
    [self registerNotification:@selector(reloadCurrentUser) name:kNotificationReloadCurrentUser object:nil];
    [self registerNotification:@selector(editAvatarWith:) name:@"editAvatar" object:nil];
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
    
    [[Flooz sharedInstance] updateCurrentUserWithSuccess:^{
        [self reloadData];
    }];
    
    if (_tableView.contentOffset.y < userView.frame.size.height)
        [(FLNavigationController*)self.navigationController hideShadow];
}

- (void)reloadData {
    
    int cardNotifs = 0;
    int bankNotifs = 0;
    int coordsNotifs = 0;
    int friendsNotifs = 0;
    int docNotifs = 0;
    
    FLUser *currentUser = [Flooz sharedInstance].currentUser;
    
    NSArray *missingFields = currentUser.json[@"missingFields"];
    
    if (!currentUser.creditCard)
        cardNotifs = 1;
    
    if ([missingFields containsObject:@"sepa"])
        bankNotifs = 1;
    
    if ([missingFields containsObject:@"cniRecto"])
        docNotifs++;
    
    if ([missingFields containsObject:@"cniVerso"])
        docNotifs++;
    
    if ([missingFields containsObject:@"address"])
        coordsNotifs++;
    
    if ([missingFields containsObject:@"justificatory"])
        docNotifs++;
    
    friendsNotifs = [currentUser.metrics[@"pendingFriend"] intValue];
    
    NSString *shareTitle = [Flooz sharedInstance].currentTexts.menu[@"promo"][@"title"];
    
    if (shareTitle == nil)
        shareTitle = @"";
    
    if (friendsNotifs) {
        _menuDic = @[
                     @{@"title":NSLocalizedString(@"MENU_ACCOUNT", @""),
                       @"items":@[
                               @{@"title":NSLocalizedString(@"PROFILE", @""), @"action":@"profile"},
                               @{@"title":NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil), @"action":@"cashout"},
                               @{@"title":NSLocalizedString(@"FRIEND_REQUEST_TITLE", @""), @"action":@"friendsRequest", @"notif":@(friendsNotifs)},
                               @{@"title":NSLocalizedString(@"SETTINGS_COORDS", @""), @"action":@"coords", @"notif":@(coordsNotifs)},
                               @{@"title":NSLocalizedString(@"SETTINGS_DOCUMENTS", @""), @"action":@"documents", @"notif":@(docNotifs)},
                               @{@"title":[Flooz sharedInstance].currentTexts.menu[@"promo"][@"title"], @"action":@"sponsor"}
                               ]
                       },
                     @{@"title":NSLocalizedString(@"MENU_SETTINGS", @""),
                       @"items":@[
                               @{@"title":NSLocalizedString(@"SETTINGS_CARD", @""), @"action":@"card", @"notif":@(cardNotifs)},
                               @{@"title":NSLocalizedString(@"SETTINGS_BANK", @""), @"action":@"bank", @"notif":@(bankNotifs)},
                               @{@"title":NSLocalizedString(@"SETTINGS_PREFERENCES", @""), @"action":@"preferences"},
                               @{@"title":NSLocalizedString(@"SETTINGS_SECURITY", @""), @"action":@"security"}
                               ]
                       },
                     @{@"title":NSLocalizedString(@"MENU_OTHER", @""),
                       @"items":@[
                               @{@"title":NSLocalizedString(@"INFORMATIONS_RATE", @""), @"action":@"rate", @"page":@"rate"},
                               @{@"title":NSLocalizedString(@"INFORMATIONS_FAQ", @""), @"action":@"faq", @"page":@"faq"},
                               @{@"title":NSLocalizedString(@"INFORMATIONS_TERMS", @""), @"action":@"terms", @"page":@"cgu"},
                               @{@"title":NSLocalizedString(@"INFORMATIONS_CONTACT", @""), @"action":@"contact", @"page":@"contact"},
                               @{@"title":NSLocalizedString(@"SETTINGS_IDEAS_CRITICS", @""), @"action":@"critics"},
                               @{@"title":NSLocalizedString(@"SETTINGS_LOGOUT", @""), @"action":@"logout"}
                               ]
                       }
                     ];
    } else {
        _menuDic = @[
                     @{@"title":NSLocalizedString(@"MENU_ACCOUNT", @""),
                       @"items":@[
                               @{@"title":NSLocalizedString(@"PROFILE", @""), @"action":@"profile"},
                               @{@"title":NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil), @"action":@"cashout"},
                               @{@"title":NSLocalizedString(@"SETTINGS_COORDS", @""), @"action":@"coords", @"notif":@(coordsNotifs)},
                               @{@"title":NSLocalizedString(@"SETTINGS_DOCUMENTS", @""), @"action":@"documents", @"notif":@(docNotifs)},
                               @{@"title":[Flooz sharedInstance].currentTexts.menu[@"promo"][@"title"], @"action":@"sponsor"}
                               ]
                       },
                     @{@"title":NSLocalizedString(@"MENU_SETTINGS", @""),
                       @"items":@[
                               @{@"title":NSLocalizedString(@"SETTINGS_CARD", @""), @"action":@"card", @"notif":@(cardNotifs)},
                               @{@"title":NSLocalizedString(@"SETTINGS_BANK", @""), @"action":@"bank", @"notif":@(bankNotifs)},
                               @{@"title":NSLocalizedString(@"SETTINGS_PREFERENCES", @""), @"action":@"preferences"},
                               @{@"title":NSLocalizedString(@"SETTINGS_SECURITY", @""), @"action":@"security"}
                               ]
                       },
                     @{@"title":NSLocalizedString(@"MENU_OTHER", @""),
                       @"items":@[
                               @{@"title":NSLocalizedString(@"INFORMATIONS_RATE", @""), @"action":@"rate", @"page":@"rate"},
                               @{@"title":NSLocalizedString(@"INFORMATIONS_FAQ", @""), @"action":@"faq", @"page":@"faq"},
                               @{@"title":NSLocalizedString(@"INFORMATIONS_TERMS", @""), @"action":@"terms", @"page":@"cgu"},
                               @{@"title":NSLocalizedString(@"INFORMATIONS_CONTACT", @""), @"action":@"contact", @"page":@"contact"},
                               @{@"title":NSLocalizedString(@"SETTINGS_IDEAS_CRITICS", @""), @"action":@"critics"},
                               @{@"title":NSLocalizedString(@"SETTINGS_LOGOUT", @""), @"action":@"logout"}
                               ]
                       }
                     ];
    }
    
    [_tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
}

#pragma mark - tableView delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else if (section == _menuDic.count + 1)
        return 1;
    else
        return [[[_menuDic objectAtIndex:section - 1] objectForKey:@"items"] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _menuDic.count + 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return CGRectGetHeight(userView.frame);
    else if (section == _menuDic.count + 1)
        return CGFLOAT_MIN;
    else
        return 40;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return userView;
    else if (section == _menuDic.count + 1) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), [self tableView:tableView heightForHeaderInSection:section])];
        return headerView;
    } else {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), [self tableView:tableView heightForHeaderInSection:section])];
        
        UILabel *headerTitle = [[UILabel alloc] initWithText:[[[_menuDic objectAtIndex:section - 1] objectForKey:@"title"] uppercaseString] textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
        
        [headerView addSubview:headerTitle];
        
        CGRectSetX(headerTitle.frame, 14);
        CGRectSetY(headerTitle.frame, CGRectGetHeight(headerView.frame) / 2 - CGRectGetHeight(headerTitle.frame) / 2 + 1);
        
        return headerView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AccountCell";
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    } else if (indexPath.section == _menuDic.count + 1) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LastCell"];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [cell setBackgroundColor:[UIColor customBackground]];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor customPlaceholder];
        cell.textLabel.font = [UIFont customContentRegular:14];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = [NSString stringWithFormat:@"Flooz %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        
        return cell;
    }
    
    AccountCell *accountCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!accountCell) {
        accountCell = [[AccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [accountCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    NSDictionary *rowDic = [[[_menuDic objectAtIndex:indexPath.section - 1] objectForKey:@"items"] objectAtIndex:indexPath.row];
    [accountCell setMenu:rowDic];
    
    return accountCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 0;
    else if (indexPath.section == _menuDic.count + 1)
        return 45;
    else
        return [AccountCell getHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != _menuDic.count + 1) {
        NSDictionary *rowDic = [[[_menuDic objectAtIndex:indexPath.section - 1] objectForKey:@"items"] objectAtIndex:indexPath.row];
        NSString *action = rowDic[@"action"];
        
        if ([action isEqualToString:@"cashout"]) {
            [[self navigationController] pushViewController:[CashOutViewController new] animated:YES];
        } else if ([action isEqualToString:@"card"]) {
            [[self navigationController] pushViewController:[CreditCardViewController new] animated:YES];
        } else if ([action isEqualToString:@"friends"]) {
            [[self navigationController] pushViewController:[FriendsViewController new] animated:YES];
        } else if ([action isEqualToString:@"bank"]) {
            [[self navigationController] pushViewController:[SettingsBankViewController new] animated:YES];
        } else if ([action isEqualToString:@"documents"]) {
            [[self navigationController] pushViewController:[SettingsDocumentsViewController new] animated:YES];
        } else if ([action isEqualToString:@"coords"]) {
            [[self navigationController] pushViewController:[SettingsCoordsViewController new] animated:YES];
        } else if ([action isEqualToString:@"security"]) {
            [[self navigationController] pushViewController:[SettingsSecurityViewController new] animated:YES];
        } else if ([action isEqualToString:@"rate"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8&id=940393916"]];
        } else if ([action isEqualToString:@"faq"]) {
            [self goToWebView:rowDic];
        } else if ([action isEqualToString:@"terms"]) {
            [self goToWebView:rowDic];
        } else if ([action isEqualToString:@"contact"]) {
            [self goToWebView:rowDic];
        } else if ([action isEqualToString:@"critics"]) {
            [self presentIdeaCritics];
        } else if ([action isEqualToString:@"preferences"]) {
            [[self navigationController] pushViewController:[SettingsPreferencesViewController new] animated:YES];
        } else if ([action isEqualToString:@"logout"]) {
            FLPopup *popup = [[FLPopup alloc] initWithMessage:NSLocalizedString(@"LOGOUT_INFO", nil) accept: ^{
                [[Flooz sharedInstance] logout];
            } refuse:NULL];
            [popup show];
        } else if ([action isEqualToString:@"sponsor"]) {
            [[self navigationController] pushViewController:[DiscountCodeViewController new] animated:YES];
        } else if ([action isEqualToString:@"profile"]) {
            [appDelegate showUser:[Flooz sharedInstance].currentUser inController:self];
        } else if ([action isEqualToString:@"friendsRequest"]) {
            [[self navigationController] pushViewController:[FriendRequestViewController new] animated:YES];
        }
    }
}

- (void) goToWebView:(NSDictionary *)dic {
    NSString *url = [NSString stringWithFormat:@"%@?layout=webview", dic[@"page"]];
    NSString *link = dic[@"action"];
    NSString *title = NSLocalizedString([@"INFORMATIONS_" stringByAppendingString:[link uppercaseString]], nil);
    
    WebViewController *controller = [WebViewController new];
    [controller setUrl:[@"https://www.flooz.me/" stringByAppendingString : url]];
    controller.title = title;
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)presentIdeaCritics {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor] }];
        [mailComposer setNavigationBarHidden:NO animated:YES];
        
        [mailComposer setToRecipients:@[NSLocalizedString(@"IDEA_RECIPIENTS", nil)]];
        [mailComposer setMessageBody:NSLocalizedString(@"IDEA_MESSAGE", nil) isHTML:NO];
        [mailComposer setSubject:NSLocalizedString(@"IDEA_OBJECT", nil)];
        
        [[Flooz sharedInstance] showLoadView];
        [self presentViewController:mailComposer animated:YES completion: ^{
            [[Flooz sharedInstance] hideLoadView];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
    else {
        [appDelegate displayMessage:NSLocalizedString(@"ALERT_NO_MAIL_TITLE", nil) content:NSLocalizedString(@"ALERT_NO_MAIL_MESSAGE1", nil) style:FLAlertViewStyleInfo time:nil delay:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        if (result == MFMailComposeResultSent) {
            [appDelegate displayMessage:NSLocalizedString(@"IDEA_THX_TITLE", nil) content:NSLocalizedString(@"IDEA_THX_CONTENT", nil) style:FLAlertViewStyleSuccess time:nil delay:nil];
        }
        else if (result == MFMailComposeResultFailed) {
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_tableView.contentOffset.y < userView.frame.size.height)
        [(FLNavigationController*)self.navigationController hideShadow];
    else
        [(FLNavigationController*)self.navigationController showShadow];
}

#pragma mark - SEGUE

- (void)reloadCurrentUser {
    [userView reloadData];
    [self reloadData];
}

#pragma mark - avatar

- (void)showMenuAvatar {
    if ([[Flooz sharedInstance].currentUser.avatarURL isBlank]) {
        if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
            [self createActionSheet];
        }
        else {
            [self createAlertController];
        }
    } else
        [appDelegate showUser:[Flooz sharedInstance].currentUser inController:self];
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
//            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?&width=134&height=134", result[@"id"]]]];
//            [self sendData:imageData];
//        }
//    }];
//}

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
