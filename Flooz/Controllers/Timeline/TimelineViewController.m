//
//  TimelineViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "TimelineViewController.h"

#import "TransactionCell.h"

#import "MenuNewTransactionViewController.h"
#import "TransactionViewController.h"
#import "EventViewController.h"

@implementation TimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_TIMELINE", nil);
        transactions = [NSMutableArray new];
        rowsWithPaymentField = [NSMutableSet new];
        nextPageIsLoading = NO;
        
        transactionsCache = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    UIImageView *shadow = [UIImageView imageNamed:@"tableview-shadow"];
    CGRectSetY(shadow.frame, self.view.frame.size.height - shadow.frame.size.height);
    [self.view addSubview:shadow];
    
    UIImage *buttonImage = [UIImage imageNamed:@"menu-new-transaction"];
    crossButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonImage.size.width) / 2., self.view.frame.size.height - buttonImage.size.height - 20, buttonImage.size.width, buttonImage.size.height)];
    [crossButton setImage:buttonImage forState:UIControlStateNormal];
    [self.view addSubview:crossButton];
    
    [crossButton addTarget:self action:@selector(presentMenuTransactionController) forControlEvents:UIControlEventTouchUpInside];
    
    
    {
        [_filterView addFilter:@"scope-public-large" target:self action:@selector(didFilterPublicTouch)];
        [_filterView addFilter:@"scope-friend-large" target:self action:@selector(didFilterFriendTouch)];
        [_filterView addFilter:@"scope-private-large" target:self action:@selector(didFilterPersoTouch)];
    }
    
//    if([[[Flooz sharedInstance] currentUser] haveStatsPending]){
//        [self didFilterPersoTouch:@1];
//    }
//    else{
        [self didFilterPublicTouch];
//    }
    
    refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    
    {
        scrollViewIndicator = [FLScrollViewIndicator new];
        scrollViewIndicator.hidden = YES;
        [self.view addSubview:scrollViewIndicator];
    }
    
    // Padding pour que le dernier element au dessus du +
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMakeSize(SCREEN_WIDTH, 70)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefresh) name:@"reloadTimeline" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    crossButton.frame = CGRectMake((self.view.frame.size.width - crossButton.imageView.image.size.width) / 2., self.view.frame.size.height - crossButton.imageView.image.size.height - 20, crossButton.imageView.image.size.width, crossButton.imageView.image.size.height);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    crossButton.hidden = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    NSLog(@"TimelineController unload");
}

- (void)dealloc
{
    NSLog(@"TimelineController dealloc");
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [transactions count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    for(NSIndexPath *currentIndexPath in rowsWithPaymentField){
        if([currentIndexPath isEqual:indexPath]){
            return 122;
        }
    }
    
    FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
    return [TransactionCell getHeightForTransaction:transaction];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TransactionCell";
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    
    FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
    
    BOOL havePaymentField = NO;
    for(NSIndexPath *currentIndexPath in rowsWithPaymentField){
        if([currentIndexPath isEqual:indexPath]){
            havePaymentField = YES;
            break;
        }
    }
    
    [cell setTransaction:transaction];
    if(havePaymentField){
        [cell showPaymentField];
    }
    
    if(_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [transactions count] - 1){
        [self loadNextPage];
    }
    
    return cell;
}

#pragma mark - 

- (void)presentMenuTransactionController
{
    crossButton.hidden = YES;
 
    UIViewController *controller = [MenuNewTransactionViewController new];
    self.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self presentViewController:controller animated:YES completion:^{
        self.parentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }];
}

#pragma mark - Filters

- (void)handleRefresh
{
    [refreshControl beginRefreshing];

    [[Flooz sharedInstance] timeline:currentFilter success:^(id result, NSString *nextPageUrl) {
        transactions = [result mutableCopy];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [self didFilterChange];
    } failure:NULL];
}

- (void)didFilterPublicTouch
{
    currentFilter = @"public";

    if(transactionsCache[currentFilter]){
        transactions = [transactionsCache[currentFilter] mutableCopy];
        _nextPageUrl = nil;
        [self didFilterChange];
    }
    
    [[Flooz sharedInstance] timeline:currentFilter success:^(id result, NSString *nextPageUrl) {
        if(![currentFilter isEqualToString:@"public"]){
            return;
        }
        
        transactions = [result mutableCopy];
        transactionsCache[currentFilter] = result;
        
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [self didFilterChange];
    } failure:NULL];
}

- (void)didFilterFriendTouch
{
    currentFilter = @"friend";

    if(transactionsCache[currentFilter]){
        transactions = [transactionsCache[currentFilter] mutableCopy];
        _nextPageUrl = nil;
        [self didFilterChange];
    }
    
    [[Flooz sharedInstance] timeline:currentFilter success:^(id result, NSString *nextPageUrl) {
        if(![currentFilter isEqualToString:@"friend"]){
            return;
        }
        
        transactions = [result mutableCopy];
        transactionsCache[currentFilter] = result;
        
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [self didFilterChange];
    } failure:NULL];
}

- (void)didFilterPersoTouch
{
    currentFilter = @"private";
    
    if(transactionsCache[currentFilter]){
        transactions = [transactionsCache[currentFilter] mutableCopy];
        _nextPageUrl = nil;
        [self didFilterChange];
    }
    
    [[Flooz sharedInstance] timeline:currentFilter state:@"" success:^(id result, NSString *nextPageUrl) {
        if(![currentFilter isEqualToString:@"private"]){
            return;
        }
        
        transactions = [result mutableCopy];
        transactionsCache[currentFilter] = result;
        
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [self didFilterChange];
    } failure:NULL];
}

- (void)didFilterChange
{
    rowsWithPaymentField = [NSMutableSet new];
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointZero animated:YES];
    [refreshControl endRefreshing];
}

#pragma mark - TransactionCellDelegate

- (void)didTransactionTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction
{
    if([transaction eventId]){
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] eventWithId:[transaction eventId] success:^(id result) {
            FLEvent *event = [[FLEvent alloc] initWithJSON:[result objectForKey:@"item"]];
            EventViewController *controller = [[EventViewController alloc] initWithEvent:event indexPath:indexPath];
            
            self.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            
            [self presentViewController:controller animated:NO completion:^{
                self.parentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            }];
        }];
    }
    else{
        TransactionViewController *controller = [[TransactionViewController alloc] initWithTransaction:transaction indexPath:indexPath];
        controller.delegateController = self;
        
        self.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        
        [self presentViewController:controller animated:NO completion:^{
            self.parentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        }];
    }
}

- (void)updateTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction
{
    [rowsWithPaymentField removeObject:indexPath];
    [transactions replaceObjectAtIndex:indexPath.row withObject:transaction];
    
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (void)showPayementFieldAtIndex:(NSIndexPath *)indexPath
{
    NSMutableSet *rowsToReload = [rowsWithPaymentField mutableCopy];
    
    [rowsWithPaymentField removeAllObjects];
    [rowsWithPaymentField addObject:indexPath];
    [rowsToReload addObject:indexPath];
    
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:[rowsToReload allObjects] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (void)loadNextPage
{
    if(!_nextPageUrl || [_nextPageUrl isBlank]){
        return;
    }

    nextPageIsLoading = YES;
    
    [[Flooz sharedInstance] timelineNextPage:_nextPageUrl success:^(id result, NSString *nextPageUrl) {
        [transactions addObjectsFromArray:result];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [_tableView reloadData];
    }];
}

#pragma mark - ScrollViewIndicator

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Fin du scroll
    [self hideScrollViewIndicator];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // Lache d un coup
    [self hideScrollViewIndicator];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(_tableView.contentOffset.y > 0){
        [self refreshScrollViewIndicator];
    }
}

- (void)refreshScrollViewIndicator
{
    if([transactions count] == 0){
        scrollViewIndicator.hidden = YES;
        return;
    }
    
    [scrollViewIndicator.layer removeAllAnimations];
    scrollViewIndicator.hidden = NO;
    scrollViewIndicator.layer.opacity = 1;
    
    CGFloat y = _tableView.frame.origin.y + (_tableView.contentOffset.y / _tableView.contentSize.height) * CGRectGetHeight(_tableView.frame);
    
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:CGPointMake(_tableView.contentOffset.x, _tableView.contentOffset.y + y - _tableView.frame.origin.y + CGRectGetHeight(scrollViewIndicator.frame) / 2.)];
    
    if(!indexPath){
        [self hideScrollViewIndicator];
        return;
    }
    
    FLTransaction *transaction = transactions[indexPath.row];
    
    CGRectSetY(scrollViewIndicator.frame, y);
    [scrollViewIndicator setText:[transaction when]];
}

- (void)hideScrollViewIndicator
{
    [UIView animateWithDuration:.3 animations:^{
        scrollViewIndicator.layer.opacity = 0;
    } completion:^(BOOL finished) {
        if(finished){
            scrollViewIndicator.hidden = YES;
        }
        scrollViewIndicator.layer.opacity = 1;
    }];
}

@end
