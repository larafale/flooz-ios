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
		self.title = NSLocalizedString(@"NAV_FRIENDS", nil);

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
	self.view.backgroundColor = [UIColor customBackgroundHeader];
    
	_searchBar = [[FriendAddSearchBar alloc] initWithStartX:PADDING_NAV + 10.0f];
	CGRectSetY(_searchBar.frame, PPStatusBarHeight());
	[_searchBar setDelegate:self];
	[self.view addSubview:_searchBar];

    _backgroundView = [UIView newWithFrame:CGRectMake(PADDING_NAV, CGRectGetMaxY(_searchBar.frame), PPScreenWidth() - PADDING_NAV, PPScreenHeight() - CGRectGetMaxY(_searchBar.frame))];
    
    UIImageView *backgroudImage = [UIImageView newWithImage:[UIImage imageNamed:@"background-friends"]];
    backgroudImage.contentMode = UIViewContentModeScaleAspectFit;
    CGFloat newWidth = PPScreenWidth() - PADDING_NAV;
    
    if (IS_IPHONE4)
        newWidth -= 25;
    
    CGFloat newHeight = newWidth * CGRectGetHeight(backgroudImage.frame) / CGRectGetWidth(backgroudImage.frame);

    CGRectSetWidthHeight(backgroudImage.frame, newWidth, newHeight);
    CGRectSetPosition(backgroudImage.frame, CGRectGetWidth(_backgroundView.frame) / 2 - newWidth / 2, 0);

    CGFloat margin = 20;
    if (IS_IPHONE4)
        margin = 10;
    
    FLActionButton *shareButton = [[FLActionButton alloc] initWithFrame:CGRectMake(30.0f, CGRectGetHeight(backgroudImage.frame) + margin, PPScreenWidth() - PADDING_NAV - 60.0f, FLActionButtonDefaultHeight) title:NSLocalizedString(@"FRIENDS_BUTTON_INVITE", nil)];
    [shareButton addTarget:self action:@selector(showShareView) forControlEvents:UIControlEventTouchUpInside];
    
    [_backgroundView addSubview:backgroudImage];
    [_backgroundView addSubview:shareButton];
    
	_tableView = [[FLTableView alloc] initWithFrame:CGRectMake(PADDING_NAV, CGRectGetMaxY(_searchBar.frame), PPScreenWidth() - PADDING_NAV, PPScreenHeight() - CGRectGetMaxY(_searchBar.frame)) style:UITableViewStylePlain];
	[_tableView setDelegate:self];
	[_tableView setDataSource:self];
	[self.view addSubview:_tableView];
    [self.view addSubview:_backgroundView];

	refreshControl = [UIRefreshControl new];
    [refreshControl setTintColor:[UIColor customBlueLight]];
	[refreshControl addTarget:self action:@selector(didReloadData) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview:refreshControl];

	_tableView.backgroundColor = [UIColor clearColor];
	_backgroundView.hidden = YES;

	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	[self didReloadData];
    [self reloadFriendsList];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    
	[self registerForKeyboardNotifications];
	[self registerNotification:@selector(scrollViewDidScroll:) name:kNotificationCloseKeyboard object:nil];
	[self registerNotification:@selector(didReloadData) name:kNotificationRemoveFriend object:nil];
    [self registerNotification:@selector(reloadFriendsList) name:kNotificationReloadCurrentUser object:nil];
}

- (void)showShareView {
    ShareAppViewController *controller = [ShareAppViewController new];
    [[appDelegate currentController] presentViewController:controller animated:YES completion:NULL];
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

	return 26;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2) {
		return [FriendRequestCell getHeight];
	}

	return [FriendCell getHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGFloat heigth = [self tableView:tableView heightForHeaderInSection:section];

	UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), heigth)];
	view.backgroundColor = [UIColor customBackground];

	{
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, CGRectGetWidth(view.frame) - 10.0f, CGRectGetHeight(view.frame))]; // x = 24
		label.textColor = [UIColor customBlue];
		label.font = [UIFont customContentRegular:14];
		label.text = [self tableView:tableView titleForHeaderInSection:section];
		[view addSubview:label];
	}

	return view;
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
        FriendCell *cell = (FriendCell *)[tableView cellForRowAtIndexPath:indexPath];
		[appDelegate showMenuForUser:friend imageView:cell.avatarView canRemoveFriend:YES inWindow:self.view.window];
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
	[[Flooz sharedInstance] friendSearch:text forNewFlooz:NO success: ^(id result) {
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
	[[Flooz sharedInstance] friendAcceptSuggestion:friendSuggestionId  canal:tmp.selectedFrom success: ^{
	    [self didReloadData];
	}];
}

- (void)removeFriend:(NSString *)friendId {
	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] friendRemove:friendId success: ^{
	    [self didReloadData];
	}];
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
