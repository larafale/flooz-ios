//
//  FLTimelineTableViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-09-24.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTimelineTableViewController.h"
#import "AppDelegate.h"

@interface FLTimelineTableViewController () {
	NSMutableArray *transactions;

	NSMutableSet *rowsWithPaymentField;

	NSString *_nextPageUrl;
	BOOL nextPageIsLoading;

	NSString *currentFilter;
	UIRefreshControl *refreshControl;

	FLScrollViewIndicator *scrollViewIndicator;

	NSMutableArray *transactionsLoaded;

	NSMutableArray *cells;
	CGRect frameTable;
    
    BOOL isReloading;
}

@end

@implementation FLTimelineTableViewController

- (id)initWithFrame:(CGRect)frame andFilter:(NSString *)filter {
	self = [super init];
	if (self) {
		NSString *titleController = @"";
		if ([filter isEqualToString:@"friend"]) {
			titleController = @"Fil d’actualité";
		}
		else if ([filter isEqualToString:@"public"]) {
			titleController = @"Public";
		}
		else {
			titleController = @"Moi";
		}
//        titleController = [[[filter substringToIndex:1] uppercaseString] stringByAppendingString:[filter substringFromIndex:1]];

		self.title = titleController;

		transactions = [NSMutableArray new];
		rowsWithPaymentField = [NSMutableSet new];
		nextPageIsLoading = NO;

		transactionsLoaded = [NSMutableArray new];
		cells = [NSMutableArray new];

		frameTable = frame;
		currentFilter = filter;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	_tableView = [FLTableView newWithFrame:frameTable];
	[_tableView setDelegate:self];
	[_tableView setDataSource:self];
	[_tableView setScrollsToTop:YES];
	[self.view addSubview:_tableView];

	// Padding pour que le dernier element au dessus du +
	_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMakeSize(PPScreenWidth(), 70)];

	refreshControl = [UIRefreshControl new];
    [refreshControl setTintColor:[UIColor customBlueLight]];
	[refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview:refreshControl];

	{
		scrollViewIndicator = [FLScrollViewIndicator new];
		scrollViewIndicator.hidden = YES;
		[self.view addSubview:scrollViewIndicator];
	}
    
	[self registerNotification:@selector(didReceiveNotificationConnectionError) name:kNotificationConnectionError object:nil];
	[self registerNotification:@selector(statusBarHit) name:kNotificationTouchStatusBarClick object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
//	[self reloadTableView];
}

- (void)statusBarHit {
	[_tableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Table view data source
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

	for (NSIndexPath *currentIndexPath in rowsWithPaymentField) {
		if ([currentIndexPath isEqual:indexPath]) {
			return 122;
		}
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
	[cell setIndexPath:indexPath];

	if (_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [transactions count] - 1) {
		[self loadNextPage];
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
    [appDelegate showTransaction:transaction inController:self withIndexPath:indexPath focusOnComment:NO];
}

#pragma mark - Filters

- (void)reloadTableView {
    
    [self.tableView setScrollEnabled:NO];
    [self.tableView setScrollEnabled:YES];
    
    if (isReloading) {
        return;
    }
    isReloading = YES;
    
    if (![transactions count]) {
        [UIView animateWithDuration:0.0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            self.tableView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
        } completion:^(BOOL finished) {
            [refreshControl beginRefreshing];
        }];
    }
	[[Flooz sharedInstance] timeline:currentFilter success: ^(id result, NSString *nextPageUrl) {
        transactions = [result mutableCopy];
        
	    _nextPageUrl = nextPageUrl;
	    nextPageIsLoading = NO;
	    [self didFilterChange];
        isReloading = NO;
	} failure:^(NSError *error) {
        isReloading = NO;
        [_tableView setContentOffset:CGPointZero animated:YES];
        [refreshControl endRefreshing];
    }];
}

- (void)handleRefresh {
	[refreshControl beginRefreshing];
	[self reloadTableView];
}

- (void)didFilterChange {
	rowsWithPaymentField = [NSMutableSet new];
	[_tableView reloadData];
	[_tableView setContentOffset:CGPointZero animated:YES];
	[refreshControl endRefreshing];
}

#pragma mark - TransactionCellDelegate

- (void)didTransactionTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
}

- (void)updateTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
	[rowsWithPaymentField removeObject:indexPath];
	[transactions replaceObjectAtIndex:indexPath.row withObject:transaction];

	[_tableView beginUpdates];
	[_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	[_tableView endUpdates];
}

- (void)commentTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    [appDelegate showTransaction:transaction inController:self withIndexPath:indexPath focusOnComment:YES];
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

@end
