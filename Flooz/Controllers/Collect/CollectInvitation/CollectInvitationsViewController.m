//
//  CollectInvitationsViewController.m
//  Flooz
//
//  Created by Olive on 22/06/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CollectInvitationsViewController.h"
#import "ShareLinkViewController.h"

@interface CollectInvitationsViewController () {
    NSArray *transactionLikes;
    FLTransaction *_transaction;
    FLUser *currentUser;
}

@end

@implementation CollectInvitationsViewController

@synthesize tableView;

- (id)initWithTransaction:(FLTransaction *)transaction {
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
                
                [self didReloadData];
            }];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank]) {
        self.title = @"Invités";
    }
    
    if (_transaction)
        [self didReloadData];
    
    self.tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    if ([[Flooz sharedInstance].currentUser.userId isEqualToString:_transaction.creator.userId] && _transaction.status != TransactionStatusPending) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[[UIImage imageNamed:@"share_inside"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 25, 25);
        [btn setTintColor:[UIColor customBlue]];
        [btn addTarget:self action:@selector(openInviteMenu) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        self.navigationItem.rightBarButtonItem = inviteButton;
    }
    
    [_mainBody addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self didReloadData];
}

- (void)openInviteMenu {
    [[Flooz sharedInstance] showLoadView];
    
    [self presentViewController:[[FLNavigationController alloc] initWithRootViewController:[[ShareLinkViewController alloc] initWithCollectId:_transaction.transactionId]] animated:YES completion:^{
        [[Flooz sharedInstance] hideLoadView];
    }];
}

#pragma marks - tableview delegate / datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (transactionLikes)
        return transactionLikes.count;
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!transactionLikes)
        return [LoadingCell getHeight];
    
    return [FriendCell getHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!transactionLikes)
        return [LoadingCell new];
    
    static NSString *cellIdentifier = @"FriendSearchCell";
    FriendCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    
    FLUser *friend = [transactionLikes objectAtIndex:indexPath.row];
    [cell setFriend:friend];
    [cell showAddButton];
    return cell;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (transactionLikes) {
        FLUser *friend = [transactionLikes objectAtIndex:indexPath.row];
        
        [appDelegate showUser:friend inController:self];
    }
}

- (void)didReloadData {
    [[Flooz sharedInstance] collectInvitations:_transaction.transactionId success:^(id result) {
        transactionLikes = result;
        [tableView reloadData];
    } failure:^(NSError *error) {
        
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
