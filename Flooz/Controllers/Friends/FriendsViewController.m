//
//  FriendsViewController.m
//  Flooz
//
//  Created by olivier on 2/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FriendsViewController.h"

#import "FriendRequestCell.h"
#import "FriendCell.h"
#import "AppDelegate.h"
#import "ShareAppViewController.h"

@interface FriendsViewController () {
	UIView *_backgroundView;
	FriendAddSearchBar *_searchBar;
	FLTableView *_tableView;

	NSArray *friendsSearch;
	NSArray *friendsRequest;
	NSArray *friendsSuggestion;
	NSArray *friends;

	BOOL isSearching;
	FLFriendRequest *currentFriendR;
    
    BOOL isReloading;
    UIView *_avatarSelected;
}

@end

@implementation FriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		friendsSearch = @[];
		friendsRequest = @[];
		friendsSuggestion = @[];
		friends = @[];

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

    _backgroundView = [UIView newWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [_backgroundView setBackgroundColor:[UIColor customBackgroundHeader]];
    
    CGFloat margin = 20;
    if (IS_IPHONE_4)
        margin = 10;
    
    UILabel *floozLabel = [[UILabel alloc] initWithText:[Flooz sharedInstance].currentTexts.json[@"friend"] textColor:[UIColor whiteColor] font:[UIFont customContentRegular:15] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    [floozLabel setLineBreakMode:NSLineBreakByWordWrapping];
    
    CGRectSetWidth(floozLabel.frame, CGRectGetWidth(_backgroundView.frame) - 2 * margin);
    CGRectSetX(floozLabel.frame, margin);
    
    [floozLabel setHeightToFit];
    
    FLActionButton *shareButton = [[FLActionButton alloc] initWithFrame:CGRectMake(30.0f, CGRectGetHeight(_backgroundView.frame) - 40 - FLActionButtonDefaultHeight, PPScreenWidth() - 60.0f, FLActionButtonDefaultHeight) title:NSLocalizedString(@"FRIENDS_BUTTON_INVITE", nil)];
    [shareButton addTarget:self action:@selector(showShareView) forControlEvents:UIControlEventTouchUpInside];
    
    CGRectSetY(floozLabel.frame, CGRectGetHeight(_backgroundView.frame) / 2 - (CGRectGetHeight(floozLabel.frame) + margin + FLActionButtonDefaultHeight) / 2);
    CGRectSetY(shareButton.frame, CGRectGetMaxY(floozLabel.frame) + margin);
    
    [_backgroundView addSubview:floozLabel];
    [_backgroundView addSubview:shareButton];
    
	_tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStylePlain];
	[_tableView setDelegate:self];
	[_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setSeparatorColor:[UIColor customBackground]];

    [_mainBody addSubview:_tableView];
    [_mainBody addSubview:_backgroundView];

	refreshControl = [UIRefreshControl new];
    [refreshControl setTintColor:[UIColor customBlueLight]];
	[refreshControl addTarget:self action:@selector(didReloadData) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview:refreshControl];

	_tableView.backgroundColor = [UIColor customBackgroundHeader];
	_backgroundView.hidden = YES;

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
}

#pragma mark - TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"FRIENDS_FRIENDS_SEARCH", nil), (unsigned long)friendsSearch.count];
    }
    else if(section == 1){
        return NSLocalizedString(@"FRIENDS_FRIENDS_SUGGESTION", nil);
    }
    else if(section == 2){
        return [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"FRIENDS_FRIENDS_REQUEST", nil), (unsigned long)friendsRequest.count];
    }
    
    return [NSString stringWithFormat:@"%@ (%lu)", NSLocalizedString(@"FRIENDS_FRIENDS", nil), (unsigned long)friends.count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(isSearching){
        return 1;
    }
    
    return 4;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0 && isSearching) {
		return [friendsSearch count];
	}
	else if (section == 1) {
		return [friendsSuggestion count];
	}
	else if (section == 2) {
		return [friendsRequest count];
	}
	else if (section == 3) {
		return [friends count];
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
	if (section == 2 && [friendsRequest count] == 0) {
		return 0;
	}
	else if (section == 3 && [friends count] == 0) {
		return 0;
	}

	return 35;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {
		return [FriendRequestCell getHeight];
	}

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
	else if (indexPath.section == 1) {
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
	else if (indexPath.section == 2) {
		static NSString *cellIdentifier = @"FriendRequestCell";
		FriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if (!cell) {
			cell = [[FriendRequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			cell.delegate = self;
		}

		FLFriendRequest *friendRequest = [friendsRequest objectAtIndex:indexPath.row];
		[cell setFriendRequest:friendRequest];
        [cell hideAddButton];
		return cell;
	}
	else {
		static NSString *cellIdentifier = @"FriendCell";
		FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if (!cell) {
			cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			cell.delegate = self;
		}

		FLUser *friend = [friends objectAtIndex:indexPath.row];
		[cell setFriend:friend];
		[cell hideAddButton];
		return cell;
	}
}

- (void)dismiss {
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        FriendRequestCell *cell = (FriendRequestCell *)[tableView cellForRowAtIndexPath:indexPath];
        _avatarSelected = cell.avatarView;
		FLFriendRequest *friendRequest = [friendsRequest objectAtIndex:indexPath.row];
		[self showMenuForFriendRequest:friendRequest];
		return;
	}

	FLUser *friend;

	if (indexPath.section == 0) {
		friend = friendsSearch[indexPath.row];
        [friend setSelectedCanal:SearchCanal];
	}
	else if (indexPath.section == 1) {
		friend = [friendsSuggestion objectAtIndex:indexPath.row];
        [friend setSelectedCanal:SuggestionCanal];
    }
	else if (indexPath.section == 3) {
		friend = [friends objectAtIndex:indexPath.row];
        [friend setSelectedCanal:FriendsCanal];
    }

	if (friend) {
		[appDelegate showUser:friend inController:nil];
	}
}

- (void)showMenuForFriendRequest:(FLFriendRequest *)friendR {
	if (!friendR || ![friendR requestId]) {
		return;
	}

	currentFriendR = friendR;
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        [self createActionSheetWithFriendRequest:friendR];
    }
    else {
        [self createAlertController];
    }
}

- (void)createActionSheetWithFriendRequest:(FLFriendRequest *)friendR {
    UIActionSheet *actionSheet = actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"FRIEND_REQUEST_ACCEPT", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"FRIEND_REQUEST_REFUSE", nil)];
    
    if ([friendR.user avatarURL]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"MENU_AVATAR", nil)];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet showInView:self.view.window];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"FRIEND_REQUEST_ACCEPT", nil)]) {
        //Accepter
        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": [currentFriendR requestId], @"action": @"accept" } success: ^{
            [self didReloadData];
        }];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"FRIEND_REQUEST_REFUSE", nil)]) {
        //Refuser
        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": [currentFriendR requestId], @"action": @"decline" } success: ^{
            [self didReloadData];
        }];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"MENU_AVATAR", nil)]) {
        [appDelegate showAvatarView:_avatarSelected withUrl:[NSURL URLWithString:[currentFriendR.user avatarURL]]];
    }
}

- (void)createAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"FRIEND_REQUEST_ACCEPT", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": [currentFriendR requestId], @"action": @"accept" } success: ^{
            [self didReloadData];
        }];
    }]];
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"FRIEND_REQUEST_REFUSE", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": [currentFriendR requestId], @"action": @"decline" } success: ^{
            [self didReloadData];
        }];
    }]];
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_AVATAR", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        if ([currentFriendR.user avatarURL]) {
            [appDelegate showAvatarView:_avatarSelected withUrl:[NSURL URLWithString:[currentFriendR.user avatarURL]]];
        }
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
    
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
    friendsRequest = [[[[Flooz sharedInstance] currentUser] friendsRequest] copy];
    friends = [[[[Flooz sharedInstance] currentUser] friends] copy];
    
    _backgroundView.hidden = [friendsRequest count] > 0 || [friends count] > 0 || [friendsSuggestion count] > 0;
    
    [_tableView reloadData];

    if ([refreshControl isRefreshing])
        [refreshControl endRefreshing];
    
    isReloading = NO;
}

- (void)displayBackOrNot {
    if (friendsSearch.count == 0 && friends.count == 0 && friendsRequest.count == 0 && friendsSuggestion.count == 0) {
        [_backgroundView setHidden:NO];
    }
    else {
        [_backgroundView setHidden:YES];
    }
}

- (void)didFilterChange:(NSString *)text {
	if ([text isBlank]) {
		isSearching = NO;
        friendsSearch = @[];
        [self displayBackOrNot];
		[_tableView reloadData];
		[_tableView setContentOffset:CGPointZero animated:YES];
		return;
	}

	isSearching = YES;

	[[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendSearch:text forNewFlooz:NO withPhones:@[] success: ^(id result) {
	    friendsSearch = result;
        [self displayBackOrNot];
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
    else if (indexPath.section == 3) {
        [tmp setSelectedCanal:FriendsCanal];
    }

	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] friendFollow:friendSuggestionId success:^{
	    [self didReloadData];
	} failure:nil];
}

- (void)removeFriend:(NSString *)friendId {
	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] friendRemove:friendId success: ^{
	    [self didReloadData];
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
