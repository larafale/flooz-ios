//
//  FriendsViewController.m
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendsViewController.h"

#import "FriendRequestCell.h"
#import "FriendCell.h"

@interface FriendsViewController (){
    NSArray *friendsRequest;
    NSArray *friends;
}

@end

@implementation FriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        friendsRequest = @[];
        friends = @[];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    if(!animated){
        [[Flooz sharedInstance] updateCurrentUserWithSuccess:^() {
            friendsRequest = [[[Flooz sharedInstance] currentUser] friendsRequest];
            friends = [[[Flooz sharedInstance] currentUser] friends];
            
            [_tableView reloadData];
            [_tableView setContentOffset:CGPointZero animated:YES];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // WARNING Hack contraintes ne fonctionnent pas
    _tableView.frame = CGRectMakeWithSize(self.view.frame.size);
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return NSLocalizedString(@"FRIENDS_FRIEND_REQUESTS", nil);
    }
    
    return NSLocalizedString(@"FRIENDS_FRIENDS", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), [self tableView:tableView heightForHeaderInSection:section])];
    
    if(section == 0){
        view.backgroundColor = [UIColor customBackgroundHeader];
    }
    else{
        view.backgroundColor = [UIColor customBackground];
    }
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 0, CGRectGetHeight(view.frame))];
        
        label.textColor = [UIColor customBlueLight];
        
        label.font = [UIFont customContentRegular:10];
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        [label setWidthToFit];
        
        [view addSubview:label];
    }
    
    {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame), CGRectGetWidth(view.frame), 1)];
        
        separator.backgroundColor = [UIColor customSeparator];
        
        [view addSubview:separator];
    }
    
    return view;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return [friendsRequest count];
    }
    
    return [friends count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return [FriendRequestCell getHeight];
    }
    
    return [FriendCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        static NSString *cellIdentifier = @"FriendRequestCell";
        FriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[FriendRequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.delegate = self;
        }
        
        FLFriendRequest *friendRequest = [friendsRequest objectAtIndex:indexPath.row];
        [cell setFriendRequest:friendRequest];
        
        return cell;
    }
    else{
        static NSString *cellIdentifier = @"FriendCell";
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        FLUser *friend = [friends objectAtIndex:indexPath.row];
        [cell setFriend:friend];
        
        return cell;
    }
}

- (void)didReloadData{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateCurrentUserWithSuccess:^() {
        friendsRequest = [[[Flooz sharedInstance] currentUser] friendsRequest];
        friends = [[[Flooz sharedInstance] currentUser] friends];
        
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointZero animated:YES];
    }];
}

@end
