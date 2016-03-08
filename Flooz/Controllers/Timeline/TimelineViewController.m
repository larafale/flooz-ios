//
//  TimelineViewController.m
//  Flooz
//
//  Created by olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "TimelineViewController.h"

#import "TransactionCell.h"
#import "TimelineDealCell.h"

#import "NewTransactionViewController.h"
#import "TransactionViewController.h"
#import "NotificationsViewController.h"
#import "AppDelegate.h"
#import "FLBadgeView.h"
#import "TransitionDelegate.h"
#import "UICKeyChainStore.h"
#import "FLPopupInformation.h"
#import "FLFilterSegmentedControl.h"
#import "SearchViewController.h"
#import "UIButton+LongTapShare.h"
#import "FLSocialPopup.h"
#import "TUSafariActivity.h"
#import "ARChromeActivity.h"
#import "FLCopyLinkActivity.h"

@implementation TimelineViewController {
    UIBarButtonItem *amountItem;
    UIBarButtonItem *searchItem;
    UIBarButtonItem *scopeItem;
    
    NSTimer *_timer;
    NSTimer *_backTimer;
    
    FLFilterSegmentedControl *filterControl;
    
    TransactionScope currentScope;
    
    NSMutableArray *transactions;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
    
    UIRefreshControl *refreshControl;
    
    NSMutableArray *transactionsLoaded;
    
    NSMutableSet *rowsWithPaymentField;
    NSMutableArray *cells;
    
    UIView *scopeChangeHelper;
    UILabel *scopeChangeHelperLabel;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"TAB_BAR_HOME", nil);
        
        transactions = [NSMutableArray new];
        rowsWithPaymentField = [NSMutableSet new];
        nextPageIsLoading = NO;
        
        transactionsLoaded = [NSMutableArray new];
        cells = [NSMutableArray new];
        
        NSString *filterData = [UICKeyChainStore stringForKey:kFilterData];
        
        if (filterData && ![filterData isBlank])
            currentScope = [FLTransaction transactionParamsToScope:filterData];
        else {
            currentScope = TransactionScopeAll;
            [UICKeyChainStore setString:[FLTransaction transactionScopeToParams:currentScope] forKey:kFilterData];
        }
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
    
    amountItem = [[UIBarButtonItem alloc] initWithTitle:[FLHelper formatedAmount:[[Flooz sharedInstance] currentUser].amount withSymbol:NO] style:UIBarButtonItemStylePlain target:self action:@selector(showWalletMessage)];
    [amountItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    searchItem = [[UIBarButtonItem alloc] initWithImage:[FLHelper imageWithImage:[UIImage imageNamed:@"search"] scaledToSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(showSearch)];
    [searchItem setTintColor:[UIColor customBlue]];
    
    scopeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage new] style:UIBarButtonItemStylePlain target:self action:@selector(changeScope)];
    [scopeItem setTintColor:[UIColor customBlue]];
    [self updateScopeIndicator];
    
    CGFloat height = PPScreenHeight() - PPTabBarHeight() - NAVBAR_HEIGHT - PPStatusBarHeight();
    
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
    
    scopeChangeHelper = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 0, 20)];
    scopeChangeHelper.layer.masksToBounds = YES;
    scopeChangeHelper.layer.cornerRadius = 4;
    scopeChangeHelper.backgroundColor = [UIColor customBlue];
    scopeChangeHelper.userInteractionEnabled = NO;
    
    scopeChangeHelperLabel = [UILabel newWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentLight:15] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    
    [scopeChangeHelper addSubview:scopeChangeHelperLabel];
    
    [self.view addSubview:scopeChangeHelper];
    
    UIButton *logo = [[UIButton alloc] initWithFrame:CGRectMake(0, 10, 40, 40)];
    [logo setTintColor:[UIColor customBlue]];
    [logo setImage:[FLHelper imageWithImage:[UIImage imageNamed:@"home-title"] scaledToSize:CGSizeMake(80, 30)] forState:UIControlStateNormal];
    [logo setContentMode:UIViewContentModeCenter];
    [logo addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didShareFloozClick)]];
    [logo setUserInteractionEnabled:YES];
    
    self.navigationItem.titleView = logo;
    
    [self registerNotification:@selector(reloadCurrentTimeline) name:kNotificationReloadTimeline object:nil];
    [self registerNotification:@selector(reloadBalanceItem) name:kNotificationReloadCurrentUser object:nil];
    [self registerNotification:@selector(didReceiveNotificationConnectionError) name:kNotificationConnectionError object:nil];
    [self registerNotification:@selector(statusBarHit) name:kNotificationTouchStatusBarClick object:nil];
}

- (void)updateScopeIndicator {
    switch (currentScope) {
        case TransactionScopeAll:
            [scopeItem setImage:[FLHelper imageWithImage:[UIImage imageNamed:@"transaction-scope-public"] scaledToSize:CGSizeMake(25, 25)]];
            break;
        case TransactionScopeFriend:
            [scopeItem setImage:[FLHelper imageWithImage:[UIImage imageNamed:@"transaction-scope-friend"] scaledToSize:CGSizeMake(25, 25)]];
            break;
        default:
            [self changeScope];
            break;
    }
}

- (void)showSearch {
    [self.navigationController pushViewController:[SearchViewController new] animated:YES];
}

- (void)showWalletMessage {
    UIImage *cbImage = [UIImage imageNamed:@"picto-cb"];
    CGSize newImgSize = CGSizeMake(20, 14);
    
    UIGraphicsBeginImageContextWithOptions(newImgSize, NO, 0.0);
    [cbImage drawInRect:CGRectMake(0, 0, newImgSize.width, newImgSize.height)];
    cbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = cbImage;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_1", nil)];
    [string appendAttributedString:attachmentString];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_2", nil)]];
    
    [[[FLPopupInformation alloc] initWithTitle:NSLocalizedString(@"WALLET_INFOS_TITLE", nil) andMessage:string ok:nil] show];
}

- (void)reloadBalanceItem {
    [amountItem setTitle:[FLHelper formatedAmount:[[Flooz sharedInstance] currentUser].amount withSymbol:NO]];
}

- (void)reloadCurrentTimeline {
    [self cancelTimer];
    [self reloadTableView];
}

- (UIColor*)colorOfShareView {
    return [UIColor customBlue];
}

- (void)didShareFloozClick {
    [[[FLSocialPopup alloc] initWithTitle:NSLocalizedString(@"SOCIAL_SHARE_TITLE", nil) fb:^{
        NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/1462571777306570"];
        if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
            [[UIApplication sharedApplication] openURL:facebookURL];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.facebook.com/floozme"]];
        }
    } twitter:^{
        NSURL *twitterURL = [NSURL URLWithString:@"twitter:///user?screen_name=floozme"];
        if ([[UIApplication sharedApplication] canOpenURL:twitterURL]) {
            [[UIApplication sharedApplication] openURL:twitterURL];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/floozme"]];
        }
    } app:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8&id=940393916"]];
    }] show];
}

- (void)displayContentController:(UIViewController *)content {
}

- (void)hideContentController:(UIViewController *)content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [amountItem setTitle:[FLHelper formatedAmount:[[Flooz sharedInstance] currentUser].amount withSymbol:NO]];
    
    self.navigationItem.rightBarButtonItem = searchItem;
    self.navigationItem.leftBarButtonItem = scopeItem;
    
    switch (currentScope) {
        case TransactionScopeAll:
            [filterControl setSelectedSegmentIndex:0];
            break;
        case TransactionScopeFriend:
            [filterControl setSelectedSegmentIndex:1];
            break;
        case TransactionScopePrivate:
            [filterControl setSelectedSegmentIndex:2];
            break;
        default:
            break;
    }
    
    [self cancelTimer];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate handlePendingData];
    
    if (transactions.count == 0)
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(reloadCurrentTimeline) userInfo:nil repeats:NO];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelTimer];
}

- (void)cancelTimer {
    [_timer invalidate];
    _timer = nil;
    [_backTimer invalidate];
    _backTimer = nil;
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
    
    id item = [transactions objectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[FLTransaction class]]) {
        FLTransaction *transaction = item;
        return [TransactionCell getHeightForTransaction:transaction andWidth:CGRectGetWidth(tableView.frame)];
    } else if ([item isKindOfClass:[FLTimelineDeal class]]) {
        FLTimelineDeal *deal = item;
        return [TimelineDealCell getHeightForDeal:deal];
        
    }
    return 0;
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
    
    if (_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [transactions count] - 1) {
        [self loadNextPage];
    }
    
    id item = [transactions objectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[FLTransaction class]]) {
        static NSString *cellIdentifier = @"TransactionCell";
        TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andDelegate:self];
            [cells addObject:cell];
        }
        FLTransaction *transaction = item;
        
        [cell setTransaction:transaction];
        [cell setIndexPath:indexPath];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (transactions.count > indexPath.row) {
        id item = [transactions objectAtIndex:indexPath.row];
        
        if ([item isKindOfClass:[FLTransaction class]]) {
            FLTransaction *transaction = item;
            if (transaction.isCollect) {
                
            } else {
                [appDelegate showTransaction:transaction inController:self withIndexPath:indexPath focusOnComment:NO];
            }
        }
    }
}

- (void)handleRefresh {
    [refreshControl beginRefreshing];
    [self reloadTableView];
}

- (void)didTransactionShareTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.flooz.me/flooz/%@", transaction.transactionId]];
    
    ARChromeActivity *chromeActivity = [ARChromeActivity new];
    TUSafariActivity *safariActivity = [TUSafariActivity new];
    FLCopyLinkActivity *copyActivity = [FLCopyLinkActivity new];
    
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:@[chromeActivity, safariActivity, copyActivity]];
    
    [shareController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
    }];
    
    [shareController setExcludedActivityTypes:@[UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact]];
    
    [self.navigationController presentViewController:shareController animated:YES completion:^{
        
    }];
}

- (void)didTransactionTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
}

- (void)didTransactionUserTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    [appDelegate showUser:transaction.starter inController:self];
}

- (void)updateTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    if (transactions.count - 1 >= indexPath.row) {
        [rowsWithPaymentField removeObject:indexPath];
        [transactions replaceObjectAtIndex:indexPath.row withObject:transaction];
        
        [_tableView beginUpdates];
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [_tableView endUpdates];
    }
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
    
    [[Flooz sharedInstance] timelineNextPage:_nextPageUrl success: ^(id result, NSString *nextPageUrl, TransactionScope scope) {
        if (scope == currentScope) {
            [transactions addObjectsFromArray:result];
            _nextPageUrl = nextPageUrl;
            nextPageIsLoading = NO;
            [_tableView reloadData];
        }
    }];
}

- (void)showEmptyBack {
    NSString *imageName;
    
    if (currentScope == TransactionScopePrivate)
        imageName = @"empty-timeline-private";
    else if (currentScope == TransactionScopeFriend)
        imageName = @"empty-timeline-friend";
    
    if (imageName) {
        UIImageView *imgBackView = [[UIImageView alloc] initWithFrame:_tableView.frame];
        CGRectSetXY(imgBackView.frame, 0, 0);
        [imgBackView setContentMode:UIViewContentModeScaleAspectFill];
        [imgBackView setImage:[UIImage imageNamed:imageName]];
        _tableView.backgroundView = imgBackView;
    }
}

- (void)reloadTableView {
    [_backTimer invalidate];
    _backTimer = nil;
    
    if (![transactions count]) {
        self.tableView.contentOffset = CGPointMake(0, -refreshControl.frame.size.height);
        [refreshControl beginRefreshing];
    }
    
    [[Flooz sharedInstance] timeline:[FLTransaction transactionScopeToParams:currentScope] success: ^(id result, NSString *nextPageUrl, TransactionScope scope) {
        if (scope == currentScope) {
            transactions = [result mutableCopy];
            
            _nextPageUrl = nextPageUrl;
            
            if (transactions.count == 0) {
                if (_backTimer) {
                    [_backTimer invalidate];
                    _backTimer = nil;
                }
                _backTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showEmptyBack) userInfo:nil repeats:NO];
            } else
                _tableView.backgroundView = nil;
            
            nextPageIsLoading = NO;
            
            [self didFilterChange];
        }
    } failure:^(NSError *error) {
        [refreshControl endRefreshing];
    }];
}

- (void)didFilterChange {
    if ([refreshControl isRefreshing]) {
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

- (void)showScopeHelper {
    
    NSString *text;
    
    switch (currentScope) {
        case TransactionScopeAll:
            text = NSLocalizedString(@"TIMELINE_SCOPE_HELPER_ALL", nil);
            break;
        case TransactionScopeFriend:
            text = NSLocalizedString(@"TIMELINE_SCOPE_HELPER_FRIENDS", nil);
            break;
        default:
            break;
    }
    
    scopeChangeHelperLabel.text = text;
    [scopeChangeHelperLabel sizeToFit];
    
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        scopeChangeHelper.alpha = 0.0f;
        CGRectSetSize(scopeChangeHelper.frame, CGSizeMake(CGRectGetWidth(scopeChangeHelperLabel.frame) + 10, CGRectGetHeight(scopeChangeHelperLabel.frame) + 10));
        CGRectSetXY(scopeChangeHelperLabel.frame, 5, 5);
        CGRectSetXY(scopeChangeHelper.frame, PPScreenWidth() / 2 - CGRectGetWidth(scopeChangeHelper.frame) / 2, 15);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.05 options:UIViewAnimationOptionCurveEaseIn animations:^{
            scopeChangeHelper.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.3 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    scopeChangeHelper.alpha = 0.0f;
                } completion:^(BOOL finished) {
                }];
            }
        }];
    }];
    
}

- (void)changeScope {
    switch (currentScope) {
        case TransactionScopeAll:
            currentScope = TransactionScopeFriend;
            [self showScopeHelper];
            break;
        case TransactionScopeFriend:
            currentScope = TransactionScopeAll;
            [self showScopeHelper];
        default:
            currentScope = TransactionScopeAll;
            break;
    }
    
    [self updateScopeIndicator];
    [UICKeyChainStore setString:[FLTransaction transactionScopeToParams:currentScope] forKey:kFilterData];
    [self reloadTableView];
}

@end
