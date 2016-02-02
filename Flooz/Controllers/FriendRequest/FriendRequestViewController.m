//
//  FriendRequestViewController.m
//  Flooz
//
//  Created by Epitech on 10/5/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FriendCell.h"
#import "FriendRequestViewController.h"

@interface FriendRequestViewController () {
    FLTableView *_tableView;
    
    NSArray *friendsRequest;
    
    FLUser *currentUser;
}

@end

@implementation FriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"FRIEND_REQUEST_TITLE", nil);
    
    _tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setSeparatorColor:[UIColor customBackground]];
    
    [_mainBody addSubview:_tableView];
    
    refreshControl = [UIRefreshControl new];
    [refreshControl setTintColor:[UIColor customBlueLight]];
    [refreshControl addTarget:self action:@selector(didReloadData) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    
    _tableView.backgroundColor = [UIColor customBackgroundHeader];
    
    [self didReloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self didReloadData];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return friendsRequest.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FriendCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FriendRequestCell";
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLUser *friend = [friendsRequest objectAtIndex:indexPath.row];
    [cell setFriend:friend];
    [cell hideAddButton];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    currentUser = [friendsRequest objectAtIndex:indexPath.row];
    
    if (currentUser)
        [appDelegate showUser:currentUser inController:self];
}

- (void)didReloadData {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendsRequest:^(id result) {
        [refreshControl endRefreshing];
        friendsRequest = result;
        if (friendsRequest.count)
            [_tableView reloadData];
        else
            [self dismissViewController];
        [[Flooz sharedInstance] readFriendActivity:nil];
    }];
}

//- (void)showRequestMenu {
//    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
//        [self createRequestActionSheet];
//    else
//        [self createRequestAlertController];
//}
//
//- (void)createRequestAlertController {
//    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:currentUser.fullname message:NSLocalizedString(@"FRIENDS_FRIENDS_REQUEST_MESSAGE", nil) preferredStyle:UIAlertControllerStyleActionSheet];
//    
//    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"FRIEND_REQUEST_ACCEPT", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
//        [[Flooz sharedInstance] showLoadView];
//        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": currentUser.userId, @"action": @"accept" } success:^{
//            [self didReloadData];
//        } failure:^(NSError *error) {
//            [self didReloadData];
//        }];
//    }]];
//    
//    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"FRIEND_REQUEST_REFUSE", nil) style:UIAlertActionStyleDestructive handler: ^(UIAlertAction *action) {
//        [[Flooz sharedInstance] showLoadView];
//        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": currentUser.userId, @"action": @"decline" } success:^{
//            [self didReloadData];
//        } failure:^(NSError *error) {
//            [self didReloadData];
//        }];
//    }]];
//    
//    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
//    
//    [self presentViewController:newAlert animated:YES completion:nil];
//}
//
//- (void)createRequestActionSheet {
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:currentUser.fullname delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    
//    [actionSheet addButtonWithTitle:NSLocalizedString(@"FRIEND_REQUEST_ACCEPT", nil)];
//    
//    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"FRIEND_REQUEST_REFUSE", nil)];
//    
//    [actionSheet setDestructiveButtonIndex:index];
//    
//    index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
//    [actionSheet setCancelButtonIndex:index];
//    
//    [actionSheet showInView:appDelegate.window];
//}
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (buttonIndex == 0) {
//        [[Flooz sharedInstance] showLoadView];
//        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": currentUser.userId, @"action": @"accept" } success:^{
//            [self didReloadData];
//        } failure:^(NSError *error) {
//            [self didReloadData];
//        }];
//    } else if (buttonIndex == 1) {
//        [[Flooz sharedInstance] showLoadView];
//        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": currentUser.userId, @"action": @"decline" } success:^{
//            [self didReloadData];
//        } failure:^(NSError *error) {
//            [self didReloadData];
//        }];
//    }
//}

@end
