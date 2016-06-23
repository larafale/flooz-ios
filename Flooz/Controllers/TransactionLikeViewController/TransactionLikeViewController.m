//
//  TransactionLikeViewController.m
//  Flooz
//
//  Created by Olive on 21/06/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "TransactionLikeViewController.h"


@interface TransactionLikeViewController () {
    FLTransaction *_transaction;
    FLUser *currentUser;
}

@end

@implementation TransactionLikeViewController

@synthesize tableView;

- (id)initWithTransaction:(FLTransaction *)transaction{
    self = [super init];
    if (self) {
        _transaction = transaction;
    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        if (data && data[@"_id"]) {
            [[Flooz sharedInstance] transactionWithId:data[@"_id"] success:^(id result) {
                _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
                [tableView reloadData];
            }];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank]) {
        if (_transaction) {
            self.title = [NSString stringWithFormat:@"%@ J'AIME", [FLHelper castNumber:_transaction.social.likesCount]];
        } else {
            self.title = @"J'AIME";
        }
    }
    
    self.tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    [_mainBody addSubview:self.tableView];
}

#pragma marks - tableview delegate / datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_transaction.social.likes.count ? _transaction.social.likes.count : 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_transaction)
        return [LoadingCell getHeight];
    
    return [FriendCell getHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_transaction)
        return [LoadingCell new];
    
    static NSString *cellIdentifier = @"FriendSearchCell";
    FriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    
    FLUser *friend = [_transaction.social.likes objectAtIndex:indexPath.row];
    [cell setFriend:friend];
    [cell showAddButton];
    return cell;

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_transaction) {
        FLUser *friend = [_transaction.social.likes objectAtIndex:indexPath.row];

        [appDelegate showUser:friend inController:self];
    }
}

- (void)didReloadData {
    [[Flooz sharedInstance] transactionWithId:_transaction.transactionId success:^(id result) {
        _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
        [tableView reloadData];
    }];
}

- (void)acceptFriendSuggestion:(FLUser *)friend cell:(UITableViewCell *)cell {
    currentUser = friend;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    FLUser *tmp = [FLUser new];
    if (indexPath.section == 0) {
        [tmp setSelectedCanal:SearchCanal];
    }
    else if (indexPath.section == 1) {
        [tmp setSelectedCanal:SuggestionCanal];
    }
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendAdd:friend.userId success:^{
        currentUser.isFriend = YES;
        [self.tableView reloadData];
    } failure:nil];
}

- (void)removeFriend:(FLUser *)friend {
    currentUser = friend;
    [self showUnfriendMenu];
}

- (void)showUnfriendMenu {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
        [self createUnfriendActionSheet];
    else
        [self createUnfriendAlertController];
}

- (void)createUnfriendAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:currentUser.fullname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UNFRIEND", nil) style:UIAlertActionStyleDestructive handler: ^(UIAlertAction *action) {
        [[Flooz sharedInstance] friendRemove:currentUser.userId success:^{
            currentUser.isFriend = NO;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createUnfriendActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:currentUser.fullname delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"UNFRIEND", nil)];
    [actionSheet setDestructiveButtonIndex:index];
    
    index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:2];
    
    [actionSheet showInView:appDelegate.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 2 && buttonIndex == 0) {
        [[Flooz sharedInstance] friendRemove:currentUser.userId success:^{
            currentUser.isFriend = NO;
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            
        }];
    }
}

@end
