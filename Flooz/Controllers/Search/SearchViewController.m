//
//  SearchViewController.m
//  Flooz
//
//  Created by Epitech on 10/2/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController (){
    FriendAddSearchBar *_searchBar;
    FLTableView *_tableView;
    
    NSArray *friendsSearch;
    NSArray *friendsSuggestion;
    
    BOOL isSearching;
    BOOL isReloading;
    
    NSString *searchString;
}

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        friendsSearch = @[];
        friendsSuggestion = @[];
        searchString = @"";
        isSearching = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat searchMargin;
    
    if (IS_IPHONE_4)
        searchMargin = 150;
    else if (IS_IPHONE_5)
        searchMargin = 120;
    else if (IS_IPHONE_6)
        searchMargin = 100;
    else
        searchMargin = 90;
    
    _searchBar = [[FriendAddSearchBar alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth() - searchMargin, 40)];
    [_searchBar setDelegate:self];
    [_searchBar sizeToFit];
    
    self.navigationItem.titleView = _searchBar;
    
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
    [self reloadFriendsList];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
    [self registerNotification:@selector(scrollViewDidScroll:) name:kNotificationCloseKeyboard object:nil];
    [self registerNotification:@selector(didReloadData) name:kNotificationRemoveFriend object:nil];
    [self registerNotification:@selector(reloadFriendsList) name:kNotificationReloadCurrentUser object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
}

- (void)showShareView {
    [self.tabBarController setSelectedIndex:3];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_searchBar becomeFirstResponder];
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"FRIENDS_FRIENDS_SEARCH", nil), (unsigned long)friendsSearch.count];
    }
    else {
        return NSLocalizedString(@"FRIENDS_FRIENDS_SUGGESTION", nil);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(isSearching){
        return 1;
    }
    
    return 2;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && isSearching) {
        return [friendsSearch count];
    }
    else if (section == 1) {
        return [friendsSuggestion count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) { // && [friendsSearch count] == 0){
        return 0;
    }
    else if (section == 1 && [friendsSuggestion count] == 0) {
        return 0;
    }
    
    return 35;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FriendCell getHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), [self tableView:tableView heightForHeaderInSection:section])];
    headerView.backgroundColor = [UIColor customBackground];
    
    UILabel *headerTitle = [[UILabel alloc] initWithText:[self tableView:tableView titleForHeaderInSection:section] textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    
    [headerView addSubview:headerTitle];
    
    CGRectSetX(headerTitle.frame, 14);
    CGRectSetY(headerTitle.frame, CGRectGetHeight(headerView.frame) / 2 - CGRectGetHeight(headerTitle.frame) / 2 + 1);
    
    return headerView;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"FriendSearchCell";
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.delegate = self;
        }
        
        FLUser *friend = [friendsSearch objectAtIndex:indexPath.row];
        [cell setFriend:friend];
        [cell showAddButton];
        return cell;
    }
    else {
        static NSString *cellIdentifier = @"FriendSuggestionCell";
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.delegate = self;
        }
        
        FLUser *friend = [friendsSuggestion objectAtIndex:indexPath.row];
        [cell setFriend:friend];
        [cell showAddButton];
        return cell;
    }
}

- (void)dismiss {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLUser *friend;
    
    if (indexPath.section == 0) {
        friend = friendsSearch[indexPath.row];
        [friend setSelectedCanal:SearchCanal];
    }
    else if (indexPath.section == 1) {
        friend = [friendsSuggestion objectAtIndex:indexPath.row];
        [friend setSelectedCanal:SuggestionCanal];
    }
    
    if (friend) {
        [appDelegate showUser:friend inController:nil];
    }
}


- (void)scrollViewDidScroll:(id)scrollView {
    [_searchBar close];
}

- (void)didReloadData {
    if (isReloading) {
        return;
    }
    isReloading = YES;
    
    [[Flooz sharedInstance] updateCurrentUserWithSuccess: ^() {
        [[Flooz sharedInstance] friendsSuggestion: ^(id result) {
            [refreshControl endRefreshing];
            friendsSuggestion = result;
            [self reloadFriendsList];
        }];
        [[Flooz sharedInstance] readFriendActivity:nil];
    }];
}

- (void)reloadFriendsList {
    [_tableView reloadData];
    
    if ([refreshControl isRefreshing])
        [refreshControl endRefreshing];
    
    isReloading = NO;
}

- (void)didFilterChange:(NSString *)text {
    searchString = text;
    
    if ([searchString isBlank]) {
        isSearching = NO;
        friendsSearch = @[];
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointZero animated:YES];
        return;
    }
    
    isSearching = YES;
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendSearch:searchString forNewFlooz:NO withPhones:@[] success: ^(id result) {
        friendsSearch = result;
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointZero animated:YES];
    }];
}

- (void)acceptFriendSuggestion:(NSString *)friendSuggestionId cell:(UITableViewCell *)cell {
    
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    
    FLUser *tmp = [FLUser new];
    if (indexPath.section == 0) {
        [tmp setSelectedCanal:SearchCanal];
    }
    else if (indexPath.section == 1) {
        [tmp setSelectedCanal:SuggestionCanal];
    }
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendAdd:friendSuggestionId success:^{
        isReloading = YES;
        [[Flooz sharedInstance] friendsSuggestion: ^(id result) {
            [refreshControl endRefreshing];
            friendsSuggestion = result;
            [self reloadFriendsList];
        }];
        
        if (![searchString isBlank]) {
            [[Flooz sharedInstance] friendSearch:searchString forNewFlooz:NO withPhones:@[] success: ^(id result) {
                friendsSearch = result;
                [self reloadFriendsList];
            }];
        }
    } failure:nil];
}

- (void)removeFriend:(NSString *)friendId {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendRemove:friendId success: ^{
        isReloading = YES;
        [[Flooz sharedInstance] friendsSuggestion: ^(id result) {
            [refreshControl endRefreshing];
            friendsSuggestion = result;
            [self reloadFriendsList];
        }];
        
        if (![searchString isBlank]) {
            [[Flooz sharedInstance] friendSearch:searchString forNewFlooz:NO withPhones:@[] success: ^(id result) {
                friendsSearch = result;
                [self reloadFriendsList];
            }];
        }
        } failure:nil];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear {
    _tableView.contentInset = UIEdgeInsetsZero;
}

@end
