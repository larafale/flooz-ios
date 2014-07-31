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
#import "AppDelegate.h"

@interface FriendsViewController (){
    NSArray *friendsSearch;
    NSArray *friendsRequest;
    NSArray *friendsSuggestion;
    NSArray *friends;
    
    BOOL isSearching;
}

@end

@implementation FriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_FRIENDS", nil);
        
        friendsSearch = @[];
        friendsRequest = @[];
        friendsSuggestion = @[];
        friends = @[];
        
        isSearching = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createSearchButtonWithTarget:self action:@selector(presentFriendAddController)];
    
    refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(didReloadData) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    
    self.view.backgroundColor = _tableView.backgroundColor;
    _tableView.backgroundColor = [UIColor clearColor];
    _backgroundView.image = [UIImage imageNamed:@"background-friends"];
    _backgroundView.hidden = YES;
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self registerForKeyboardNotifications];
        
    [self registerNotification:@selector(scrollViewDidScroll:) name:kNotificationCloseKeyboard object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self didReloadData];
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return NSLocalizedString(@"FRIENDS_FRIENDS_SEARCH", nil);
    }
    else if(section == 1){
        return NSLocalizedString(@"FRIENDS_FRIENDS_REQUEST", nil);
    }
    else if(section == 2){
        return NSLocalizedString(@"FRIENDS_FRIENDS_SUGGESTION", nil);
    }
    
    return NSLocalizedString(@"FRIENDS_FRIENDS", nil);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(isSearching){
        return 1;
    }
    
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0 && [friendsSearch count] == 0){
        return 0;
    }
    if(section == 1 && [friendsRequest count] == 0){
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
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), heigth)];
    
//    if(section == 1){
        view.backgroundColor = [UIColor customBackgroundHeader];
//    }
//    else{
//        view.backgroundColor = [UIColor customBackground];
//    }
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), CGRectGetHeight(view.frame))]; // x = 24
        
        label.textColor = [UIColor customBlueLight];
        
        label.font = [UIFont customContentRegular:10];
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        label.textAlignment = NSTextAlignmentCenter;
//        [label setWidthToFit];
        
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
        return [friendsSearch count];
    }
    else if(section == 1){
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
    if(indexPath.section == 0){
        return [FriendAddCell getHeight];
    }
    else if(indexPath.section == 1){
        return [FriendRequestCell getHeight];
    }
    else if(indexPath.section == 2){
        return [FriendSuggestionCell getHeight];
    }
    
    return [FriendCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        static NSString *cellIdentifier = @"FriendAddCell";
        FriendAddCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(!cell){
            cell = [[FriendAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        FLUser *user = [friendsSearch objectAtIndex:indexPath.row];
        [cell setUser:user];
        
        return cell;
    }
    else if(indexPath.section == 1){
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLUser *user;
    
    if(indexPath.section == 0){
        user = [friendsSearch objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == 1){
//        user = [friendsRequest objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == 2){
        user = [friendsSuggestion objectAtIndex:indexPath.row];
    }
    else if(indexPath.section == 3){
        user = [friends objectAtIndex:indexPath.row];
    }
    
    if(user){
        [appDelegate showMenuForUser:user imageView:nil canRemoveFriend:YES];
    }
}

- (void)scrollViewDidScroll:(id)scrollView
{
    [_searchBar close];
}

- (void)didReloadData
{
    [refreshControl beginRefreshing];
    
    // bug au rechargement
//    friendsRequest = @[];
//    friends = @[];
//    friendsSuggestion = @[];
//    [_tableView reloadData];

    [[Flooz sharedInstance] updateCurrentUserWithSuccess:^() {
        [[Flooz sharedInstance] friendsSuggestion:^(id result) {
            [refreshControl endRefreshing];
            
            friendsRequest = [[[[Flooz sharedInstance] currentUser] friendsRequest] copy];
            friends = [[[[Flooz sharedInstance] currentUser] friends] copy];
            friendsSuggestion = result;
            
            _backgroundView.hidden = [friendsRequest count] > 0 || [friends count] > 0 || [friendsSuggestion count] > 0;
            
            [_tableView reloadData];
            [_tableView setContentOffset:CGPointZero animated:YES];
        }];
    }];
}

- (void)didFilterChange:(NSString *)text
{
    if([text isBlank]){
        isSearching = NO;
        friendsSearch = @[];
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointZero animated:YES];
        return;
    }
    
    isSearching = YES;
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendSearch:text success:^(id result) {
        friendsSearch = result;
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointZero animated:YES];
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
    if([self navigationController]){
        [[self navigationController] pushViewController:[FriendAddViewController new] animated:YES];
    }
    else{
        [self presentViewController:[FriendAddViewController new] animated:YES completion:NULL];
    }
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications
{
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear
{
    _tableView.contentInset = UIEdgeInsetsZero;
}

@end
