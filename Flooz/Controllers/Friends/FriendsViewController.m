//
//  FriendsViewController.m
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendsViewController.h"

#import "FriendAddViewController.h"

#import "FriendRequestCell.h"
#import "FriendCell.h"
#import "FriendSuggestionCell.h"

@interface FriendsViewController (){
    NSArray *friendsRequest;
    NSArray *friendsSuggestion;
    NSArray *friends;
}

@end

@implementation FriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        friendsRequest = @[];
        friendsSuggestion = @[];
        friends = @[];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    if(!animated){
        [[Flooz sharedInstance] updateCurrentUserWithSuccess:^() {
            [[Flooz sharedInstance] friendsSuggestion:^(id result) {
                friendsRequest = [[[Flooz sharedInstance] currentUser] friendsRequest];
                friends = [[[Flooz sharedInstance] currentUser] friends];
                friendsSuggestion = result;
                
                [_tableView reloadData];
                [_tableView setContentOffset:CGPointZero animated:YES];
            }];
        }];
    }
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 1){
        return NSLocalizedString(@"FRIENDS_FRIENDS_REQUEST", nil);
    }
    else if(section == 2){
        return NSLocalizedString(@"FRIENDS_FRIENDS_SUGGESTION", nil);
    }
    
    return NSLocalizedString(@"FRIENDS_FRIENDS", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 45;
    }
    else if(section == 1 && [friendsRequest count] == 0){
        return 0;
    }
    else if(section == 2 && [friendsSuggestion count] == 0){
        return 0;
    }
    else if(section == 3 && [friends count] == 0){
        return 0;
    }
    
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat heigth = [self tableView:tableView heightForHeaderInSection:section];
    
    if(section == 0){
        FriendSearchButton *view = [[FriendSearchButton alloc] initWithFrame:CGRectMakeSize(SCREEN_WIDTH, heigth)];
        view.delegate = self;
        return view;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), heigth)];
    
    if(section == 1){
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
    if(section == 1){
        return [friendsRequest count];
    }
    else if(section == 2){
        return [friendsSuggestion count];
    }
    else if(section == 3){
        return [friends count];
    }
    
    return 0;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        return [FriendRequestCell getHeight];
    }
    
    return [FriendCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
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
    else if(indexPath.section == 2){
        static NSString *cellIdentifier = @"FriendSuggestionCell";
        FriendSuggestionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[FriendSuggestionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.delegate = self;
        }
        
        FLUser *friend = [friendsSuggestion objectAtIndex:indexPath.row];
        [cell setFriend:friend];
        
        return cell;
    }
    else{
        static NSString *cellIdentifier = @"FriendCell";
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.delegate = self;
        }
        
        FLUser *friend = [friends objectAtIndex:indexPath.row];
        [cell setFriend:friend];
        
        return cell;
    }
}

- (void)didReloadData{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateCurrentUserWithSuccess:^() {
        [[Flooz sharedInstance] friendsSuggestion:^(id result) {
            friendsRequest = [[[Flooz sharedInstance] currentUser] friendsRequest];
            friends = [[[Flooz sharedInstance] currentUser] friends];
            friendsSuggestion = result;
            
            [_tableView reloadData];
            [_tableView setContentOffset:CGPointZero animated:YES];
        }];
    }];
}

- (void)acceptFriendSuggestion:(NSString *)friendSuggestionId
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendAcceptSuggestion:friendSuggestionId success:^{
        [self didReloadData];
    }];
}

- (void)removeFriend:(NSString *)friendId
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendRemove:friendId success:^{
        [self didReloadData];
    }];
}

- (void)presentFriendAddController{
    [self presentViewController:[FriendAddViewController new] animated:YES completion:NULL];
}

@end
