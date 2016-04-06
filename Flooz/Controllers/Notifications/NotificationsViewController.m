//
//  NotificationsViewController.m
//  Flooz
//
//  Created by olivier on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "NotificationsViewController.h"

#import "ActivityCell.h"

#import "TransactionViewController.h"
#import "FriendsViewController.h"

#import "AppDelegate.h"

@interface NotificationsViewController () {
    NSMutableArray *notificationsArray;
    
    UIRefreshControl *refreshControl;
    BOOL isLoaded;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
}

@end

@implementation NotificationsViewController

- (id)init {
    self = [super init];
    if (self) {
        notificationsArray = [NSMutableArray new];
        isLoaded = NO;
        nextPageIsLoading = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"ACCOUNT_BUTTON_NOTIFICATION", @"");

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), PPScreenHeight() - PPTabBarHeight() - NAVBAR_HEIGHT - PPStatusBarHeight()) style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setBackgroundColor:[UIColor customBackgroundHeader]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [_mainBody addSubview:_tableView];
    
    refreshControl = [UIRefreshControl new];
    [refreshControl setTintColor:[UIColor customBlueLight]];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    
    [self loadCachedActivities];
    [self handleRefresh];
    
    [self registerNotification:@selector(handleRefresh) name:@"newNotifications" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self handleRefresh];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[Flooz sharedInstance] readTransactionsSuccess:NULL];
}

- (void)loadCachedActivities {
    notificationsArray = [[[Flooz sharedInstance] activitiesCached] mutableCopy];
    
    [_tableView reloadData];
}

- (void)handleRefresh {
    [refreshControl beginRefreshing];
    
    [[Flooz sharedInstance] activitiesWithSuccess: ^(id result, NSString *nextPageUrl) {
        notificationsArray = [result mutableCopy];
        _nextPageUrl = nextPageUrl;
        [refreshControl endRefreshing];
        
        [_tableView reloadData];
    } failure:NULL];
}

- (void)loadNextPage {
    if (!_nextPageUrl || [_nextPageUrl isBlank]) {
        return;
    }
    nextPageIsLoading = YES;
    
    [[Flooz sharedInstance] activitiesNextPage:_nextPageUrl success: ^(id result, NSString *nextPageUrl) {
        [notificationsArray addObjectsFromArray:result];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [_tableView reloadData];
    }];
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_nextPageUrl && ![_nextPageUrl isBlank]) {
        return [notificationsArray count] + 1;
    }
    
    return [notificationsArray count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [notificationsArray count]) {
        return [LoadingCell getHeight];
    }
    
    FLActivity *activity = [notificationsArray objectAtIndex:indexPath.row];
    return [ActivityCell getHeightForActivity:activity forWidth:PPScreenWidth()];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [notificationsArray count]) {
        static LoadingCell *footerView;
        if (!footerView) {
            footerView = [LoadingCell new];
        }
        footerView.hidden = refreshControl.isRefreshing;
        return footerView;
    }
    
    static NSString *cellIdentifier = @"ActivityCell";
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[ActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLActivity *activity = [notificationsArray objectAtIndex:indexPath.row];
    [cell setActivity:activity];
    
    if (_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [notificationsArray count] - 1) {
        [self loadNextPage];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLActivity *activity = [notificationsArray objectAtIndex:indexPath.row];
    
    [activity setIsRead:YES];
    
    [[FLTriggerManager sharedInstance] executeTriggerList:activity.triggers];
    
    if (activity.isForCompleteProfil)
        [[Flooz sharedInstance] readTransactionWithId:@"profile" success:nil];
    
    if (activity.isFriend) {
        [[Flooz sharedInstance] readFriendActivity:nil];
    }
    
    [tableView reloadData];
}

#pragma mark - image picker

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
