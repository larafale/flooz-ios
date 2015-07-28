//
//  TimelineViewController.m
//  Flooz
//
//  Created by olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "TimelineViewController.h"

#import "TransactionCell.h"

#import "NewTransactionViewController.h"
#import "TransactionViewController.h"
#import "NotificationsViewController.h"
#import "FriendPickerViewController.h"
#import "AppDelegate.h"
#import "FLBadgeView.h"
#import "TransitionDelegate.h"

@implementation TimelineViewController {
    UIBarButtonItem *amountItem;
    UIBarButtonItem *filterItem;
    
    NSTimer *_timer;
        
    WYPopoverController *popoverController;
    FLFilterPopoverViewController *filterListController;
    TransactionScope currentScope;
    
    NSMutableArray *transactions;
    
    NSMutableSet *rowsWithPaymentField;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
    
    UIRefreshControl *refreshControl;
    
    FLScrollViewIndicator *scrollViewIndicator;
    
    NSMutableArray *transactionsLoaded;
    
    NSMutableArray *cells;
    
    BOOL isReloading;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Accueil";
        
        transactions = [NSMutableArray new];
        rowsWithPaymentField = [NSMutableSet new];
        nextPageIsLoading = NO;
        
        transactionsLoaded = [NSMutableArray new];
        cells = [NSMutableArray new];
        
        currentScope = TransactionScopeAll;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor customBackgroundHeader]];

    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor customBlue],
                                 NSFontAttributeName: [UIFont customContentLight:15]
                                 };
    
    amountItem = [[UIBarButtonItem alloc] initWithTitle:[FLHelper formatedAmount:[[Flooz sharedInstance] currentUser].amount withSymbol:NO] style:UIBarButtonItemStylePlain target:self action:@selector(amountInfos)];
    [amountItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    filterItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter"] style:UIBarButtonItemStylePlain target:self action:@selector(changeFilter)];

    CGFloat height = PPScreenHeight() - PPTabBarHeight() - NAVBAR_HEIGHT - PPStatusBarHeight();
    
    filterListController = [FLFilterPopoverViewController new];
    filterListController.delegate = self;
    filterListController.currentScope = currentScope;
    
    _tableView = [FLTableView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), height)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setScrollsToTop:YES];
    [_tableView setBackgroundColor:[UIColor clearColor]];
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
    
    [self registerNotification:@selector(reloadCurrentTimeline) name:kNotificationReloadTimeline object:nil];
    [self registerNotification:@selector(reloadBalanceItem) name:kNotificationReloadCurrentUser object:nil];
    [self registerNotification:@selector(didReceiveNotificationConnectionError) name:kNotificationConnectionError object:nil];
    [self registerNotification:@selector(statusBarHit) name:kNotificationTouchStatusBarClick object:nil];
}

- (void)reloadBalanceItem {
    [amountItem setTitle:[FLHelper formatedAmount:[[Flooz sharedInstance] currentUser].amount withSymbol:NO]];
}

- (void)reloadCurrentTimeline {
    [self cancelTimer];
    [self reloadTableView];
}

- (void)displayContentController:(UIViewController *)content {
}

- (void)hideContentController:(UIViewController *)content {
    [content willMoveToParentViewController:nil];  // 1
    [content.view removeFromSuperview];            // 2
    [content removeFromParentViewController];      // 3
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [amountItem setTitle:[FLHelper formatedAmount:[[Flooz sharedInstance] currentUser].amount withSymbol:NO]];
    self.navigationItem.rightBarButtonItem = amountItem;
    
    [self cancelTimer];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelTimer];
    popoverController = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate handlePendingData];
    
    BOOL reloadTimeline = NO;
    
    NSArray *visibleIndexes;
    
    visibleIndexes = [_tableView indexPathsForVisibleRows];
    if ([[visibleIndexes lastObject] row] <= [[Flooz sharedInstance] timelinePageSize])
        reloadTimeline = YES;
    
    if (reloadTimeline)
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(reloadCurrentTimeline) userInfo:nil repeats:NO];

    self.navigationItem.leftBarButtonItem = filterItem;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelTimer];
}

- (void)cancelTimer {
    [_timer invalidate];
    _timer = nil;
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
    if (transactions.count > indexPath.row) {
        FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
        [appDelegate showTransaction:transaction inController:self withIndexPath:indexPath focusOnComment:NO];
    }
}

- (void)handleRefresh {
    [refreshControl beginRefreshing];
    [self reloadTableView];
}

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

- (void)reloadTableView {
    
    if (isReloading) {
        return;
    }
    
    if (![transactions count]) {
        isReloading = YES;
        self.tableView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
        [refreshControl beginRefreshing];
    }
    
    [[Flooz sharedInstance] timeline:[FLTransaction transactionScopeToParams:currentScope] success: ^(id result, NSString *nextPageUrl) {
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

- (void)didFilterChange {
    if ([refreshControl isRefreshing] || isReloading) {
        [_tableView setContentOffset:CGPointZero animated:YES];
        [refreshControl endRefreshing];
    }
    rowsWithPaymentField = [NSMutableSet new];
    [_tableView reloadData];
}

#pragma mark -


- (void)didReceiveNotificationConnectionError {
    [refreshControl endRefreshing];
}

- (void)statusBarHit {
    [_tableView setContentOffset:CGPointZero animated:YES];
}

- (void)amountInfos {
    [appDelegate.tabBarController setSelectedIndex:4];
}

- (void)changeFilter {
    popoverController = [[WYPopoverController alloc] initWithContentViewController:filterListController];
    popoverController.delegate = self;
    
    [popoverController presentPopoverFromBarButtonItem:filterItem permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:nil];    
}

- (void)scopeChange:(TransactionScope)scope {
    if (scope != currentScope) {
        currentScope = scope;
        transactions = [NSMutableArray new];
        [_tableView reloadData];
        [self reloadTableView];
    }
    
    [popoverController dismissPopoverAnimated:YES];
}

@end
