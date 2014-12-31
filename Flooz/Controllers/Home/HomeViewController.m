//
//  HomeViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "HomeViewController.h"

#import "AppDelegate.h"
#import "TransactionViewController.h"

@interface HomeViewController () {
	UITableView *_tableView;

	UIView *_headerView;
	UIView *_mainView;
	UIView *_footerView;

	NSMutableArray *transactions;

	NSString *_nextPageUrl;
	BOOL nextPageIsLoading;

	UIImageView *logo;

	UIRefreshControl *refreshControl;
	NSMutableDictionary *transactionsCache;
	NSMutableSet *rowsWithPaymentField;
	NSMutableArray *transactionsLoaded;
}

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		transactions = [NSMutableArray new];
		rowsWithPaymentField = [NSMutableSet new];
		nextPageIsLoading = NO;

		transactionsCache = [NSMutableDictionary new];
		transactionsLoaded = [NSMutableArray new];
		cells = [NSMutableArray new];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor customBackground];

//	{
//		_headerView = [UIView newWithFrame:CGRectMake(0, 0, PPScreenWidth(), 55.0f + PPStatusBarHeight())];
//		[_headerView setBackgroundColor:[UIColor customBackground]];
//		[self.view addSubview:_headerView];
//	}

//	{
//		logo = [UIImageView imageNamed:@"home-title"];
//		CGRectSetXY(logo.frame, (CGRectGetWidth(_headerView.frame) - logo.frame.size.width) / 2. + 5, PPStatusBarHeight());
//		[_headerView addSubview:logo];
//	}


	{
		_mainView = [UIView newWithFrame:CGRectMake(0, STATUSBAR_HEIGHT, PPScreenWidth(), PPScreenHeight() - 85.0f - STATUSBAR_HEIGHT)];
		[self.view addSubview:_mainView];
	}

	[self createTableContact];

	{
		_footerView = [UIView newWithFrame:CGRectMake(0, CGRectGetMaxY(_mainView.frame), PPScreenWidth(), PPScreenHeight() - CGRectGetMaxY(_mainView.frame))];
		[self.view addSubview:_footerView];
	}

	[self createButtonSend];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES];
    
    if (![transactions count]) {
        [[Flooz sharedInstance] showLoadView];
    }
    [[Flooz sharedInstance] getPublicTimelineSuccess: ^(id result, NSString *nextPageUrl) {
        transactions = [result mutableCopy];
        [_tableView reloadData];
    } failure:NULL];
}

- (void)createTableContact {
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainView.frame), CGRectGetHeight(_mainView.frame)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor customBackground]];
	[_tableView setSeparatorInset:UIEdgeInsetsZero];
	[_tableView setSeparatorColor:[UIColor customSeparator]];

	[_mainView addSubview:_tableView];

	[_tableView setDataSource:self];
	[_tableView setDelegate:self];

	{
		scrollViewIndicator = [FLScrollViewIndicator new];
		scrollViewIndicator.hidden = YES;
		[_mainView addSubview:scrollViewIndicator];
	}
}

- (void)createButtonSend {
    
    CGFloat height = 0;
    
    UIView *loginButton = [[UIView alloc] initWithFrame:CGRectMake(5, 5, CGRectGetWidth(_footerView.frame) - 10, CGRectGetHeight(_footerView.frame) - 10)];
    loginButton.layer.masksToBounds = YES;
    loginButton.layer.cornerRadius = 3;
    loginButton.backgroundColor = [UIColor customBlue];
    
    UILabel *loginText = [[UILabel alloc] initWithText:[NSLocalizedString(@"Login", nil) uppercaseString] textColor:[UIColor customWhite] font:[UIFont customTitleLight:18] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    CGRectSetXY(loginText.frame, CGRectGetWidth(loginButton.frame) / 2 - CGRectGetWidth(loginText.frame) / 2, height);
    [loginButton addSubview:loginText];
    
    height += CGRectGetHeight(loginText.frame) + 5.0f;
    
    UIImageView *loginImage = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"home-title"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [loginImage setContentMode:UIViewContentModeScaleAspectFit];
    [loginImage setTintColor:[UIColor whiteColor]];
    CGRectSetHeight(loginImage.frame, CGRectGetHeight(loginButton.frame) / 2 - 10);
    CGRectSetXY(loginImage.frame, CGRectGetWidth(loginButton.frame) / 2 - CGRectGetWidth(loginImage.frame) / 2, height);
    [loginButton addSubview:loginImage];
    
    height += CGRectGetHeight(loginImage.frame);
    
    CGRectSetY(loginText.frame, CGRectGetHeight(loginButton.frame) / 2 - height / 2);
    CGRectSetY(loginImage.frame, CGRectGetHeight(loginButton.frame) / 2 - height / 2 + CGRectGetHeight(loginText.frame) + 5.0f);
    
    [loginButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(connect)]];
    
	[_footerView addSubview:loginButton];
}

#pragma mark - button action

- (void)connect {
	[appDelegate displaySignin];
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_nextPageUrl && ![_nextPageUrl isBlank]) {
		return [transactions count] + 1;
	}

	return [transactions count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row >= [transactions count]) {
		return [LoadingCell getHeight];
	}

	FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
	return [TransactionCell getHeightForTransaction:transaction andWidth:CGRectGetWidth(tableView.frame)];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == [transactions count]) {
		static LoadingCell *footerView;
		if (!footerView) {
			footerView = [LoadingCell new];
		}
		footerView.hidden = refreshControl.isRefreshing;
		return footerView;
	}

	static NSString *cellIdentifier = @"TransactionCell";
	TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andDelegate:self];
		[cells addObject:cell];
	}

	FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
	[cell setTransaction:transaction];

	if (_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [transactions count] - 1) {
		[self loadNextPage];
	}
	[cell block];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self connect];
}

#pragma mark - TransactionCellDelegate

- (void)didTransactionTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
	[self connect];
}

- (void)updateTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
	[rowsWithPaymentField removeObject:indexPath];
	[transactions replaceObjectAtIndex:indexPath.row withObject:transaction];

	[_tableView beginUpdates];
	[_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	[_tableView endUpdates];
}

- (void)commentTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
	[self connect];
}

- (void)showPayementFieldAtIndex:(NSIndexPath *)indexPath {
	NSMutableSet *rowsToReload = [rowsWithPaymentField mutableCopy];

	[rowsWithPaymentField removeAllObjects];
	[rowsWithPaymentField addObject:indexPath];
	[rowsToReload addObject:indexPath];

	[_tableView beginUpdates];
	[_tableView reloadRowsAtIndexPaths:[rowsToReload allObjects] withRowAnimation:UITableViewRowAnimationNone];
	[_tableView endUpdates];
}

- (BOOL)transactionAlreadyLoaded:(FLTransaction *)transaction {
	if ([transactionsLoaded containsObject:[transaction transactionId]]) {
		return YES;
	}

	[transactionsLoaded addObject:[transaction transactionId]];

	return NO;
}

- (void)resetTransactionsLoaded {
	[transactionsLoaded removeAllObjects];
}

- (void)loadNextPage {
	if (!_nextPageUrl || [_nextPageUrl isBlank]) {
		return;
	}

	nextPageIsLoading = YES;

	[[Flooz sharedInstance] timelineNextPage:_nextPageUrl success: ^(id result, NSString *nextPageUrl) {
	    [transactions addObjectsFromArray:result];
	    _nextPageUrl = nextPageUrl;
	    nextPageIsLoading = NO;
	    [_tableView reloadData];
	}];
}

#pragma mark - ScrollViewIndicator

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	// Fin du scroll
	[self hideScrollViewIndicator];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	// Lache d un coup
	[self hideScrollViewIndicator];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (_tableView.contentOffset.y > 0) {
		[self refreshScrollViewIndicator];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[self hideScrollViewIndicator];
}

- (void)refreshScrollViewIndicator {
	if ([transactions count] == 0) {
		scrollViewIndicator.hidden = YES;
		return;
	}

	[scrollViewIndicator.layer removeAllAnimations];
	scrollViewIndicator.hidden = NO;
	scrollViewIndicator.layer.opacity = 1;

	CGFloat y = _tableView.frame.origin.y + (_tableView.contentOffset.y / _tableView.contentSize.height) * CGRectGetHeight(_tableView.frame);

	NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:CGPointMake(_tableView.contentOffset.x, _tableView.contentOffset.y + y - _tableView.frame.origin.y + CGRectGetHeight(scrollViewIndicator.frame) / 2.)];

	// Loading view
	if (indexPath.row >= [transactions count]) {
		return;
	}

	if (!indexPath) {
		[self hideScrollViewIndicator];
		return;
	}

	FLTransaction *transaction = transactions[indexPath.row];

	[scrollViewIndicator setTransaction:transaction];

	CGRectSetY(scrollViewIndicator.frame, y);
}

- (void)hideScrollViewIndicator {
	[UIView animateWithDuration:.3 animations: ^{
	    scrollViewIndicator.layer.opacity = 0;
	} completion: ^(BOOL finished) {
	    if (finished) {
	        scrollViewIndicator.hidden = YES;
		}
	    scrollViewIndicator.layer.opacity = 1;
	}];
}

- (void)didReceiveNotificationConnectionError {
	[refreshControl endRefreshing];
}

- (FLTableView *)tableView {
	return nil;
}

@end
