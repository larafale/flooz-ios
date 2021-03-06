//
//  TimelineViewController.m
//  Flooz
//
//  Created by Olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "TimelineViewController.h"

#import "TransactionCell.h"

#import "TransactionViewController.h"
#import "NotificationsViewController.h"
#import "AppDelegate.h"
#import "FLBadgeView.h"
#import "UICKeyChainStore.h"
#import "FLPopupInformation.h"
#import "SearchViewController.h"
#import "UIButton+LongTapShare.h"
#import "FLSocialPopup.h"
#import "TUSafariActivity.h"
#import "ARChromeActivity.h"
#import "FLCopyLinkActivity.h"
#import "FLScope.h"
#import "ABMediaView.h"

@implementation TimelineViewController {
    UIBarButtonItem *amountItem;
    UIBarButtonItem *searchItem;
    UIBarButtonItem *scopeItem;
    
    NSTimer *_timer;
    NSTimer *_backTimer;
    
    NSArray<FLScope *> *availableScopes;
    FLScope *currentScope;
    
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
    
    NSString *filterData = [UICKeyChainStore stringForKey:kFilterData];
    
    if ([Flooz sharedInstance].currentTexts && [Flooz sharedInstance].currentTexts.defaultScope) {
        currentScope = [Flooz sharedInstance].currentTexts.defaultScope;
        [UICKeyChainStore setString:currentScope.keyString forKey:kFilterData];
    } else if (filterData && ![filterData isBlank]) {
        currentScope = [FLScope scopeFromObject:filterData];
    } else if ([Flooz sharedInstance].currentTexts && [Flooz sharedInstance].currentTexts.homeScopes && [Flooz sharedInstance].currentTexts.homeScopes.count) {
        currentScope = [FLScope defaultScope:FLScopeAll];
        currentScope = [[Flooz sharedInstance].currentTexts.homeScopes objectAtIndex:0];
        [UICKeyChainStore setString:currentScope.keyString forKey:kFilterData];
    } else {
        currentScope = [[FLScope defaultScopeList] objectAtIndex:0];
        [UICKeyChainStore setString:currentScope.keyString forKey:kFilterData];
    }
    
    [self checkScopeAvailability];

    [self registerNotification:@selector(reloadCurrentTimeline) name:kNotificationReloadTimeline object:nil];
    [self registerNotification:@selector(reloadBalanceItem) name:kNotificationReloadCurrentUser object:nil];
    [self registerNotification:@selector(checkScopeAvailability) name:kNotificationReloadTexts object:nil];
    [self registerNotification:@selector(didReceiveNotificationConnectionError) name:kNotificationConnectionError object:nil];
    [self registerNotification:@selector(statusBarHit) name:kNotificationTouchStatusBarClick object:nil];
}

- (void)checkScopeAvailability {
    FLTexts *currentTexts = [[Flooz sharedInstance] currentTexts];
    
    if (currentTexts.homeScopes && currentTexts.homeScopes.count) {
        availableScopes = currentTexts.homeScopes;
    } else {
        availableScopes = [FLScope defaultScopeList];
    }
    
    Boolean currentScopeAvailable = NO;
    
    for (FLScope *scope in availableScopes) {
        if (currentScope.key == scope.key) {
            currentScopeAvailable = YES;
            break;
        }
    }
    
    if (!currentScopeAvailable) {
        currentScope = [availableScopes firstObject];
        [self reloadTableView];
    }
    
    if (availableScopes.count < 2)
        self.navigationItem.leftBarButtonItem = nil;
    else
        self.navigationItem.leftBarButtonItem = scopeItem;
    
    [self updateScopeIndicator];
    [UICKeyChainStore setString:currentScope.keyString forKey:kFilterData];
}

- (void)updateScopeIndicator {
    [scopeItem setImage:[FLHelper imageWithImage:currentScope.image scaledToSize:CGSizeMake(25, 25)]];
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
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"coin" ofType:@"caf"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    
    SystemSoundID audioEffect;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
    AudioServicesAddSystemSoundCompletion(audioEffect, nil, nil, completionCallback, (__bridge_retained void *)self);
    AudioServicesPlaySystemSound(audioEffect);
}

static void completionCallback (SystemSoundID  mySSID, void *myself) {
    AudioServicesRemoveSystemSoundCompletion (mySSID);
    AudioServicesDisposeSystemSoundID(mySSID);
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
                [appDelegate showPot:transaction inController:self withIndexPath:indexPath focusOnComment:NO];
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

    [shareController setExcludedActivityTypes:@[UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeAirDrop]];
    
    [self.navigationController presentViewController:shareController animated:YES completion:nil];
}

- (void)didTransactionTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
}

- (void)didTransactionUserTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    [appDelegate showUser:transaction.starter inController:self];
}

- (void)updateTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"transactionId == %@", transaction.transactionId ];
    NSArray *filtered  = [transactions filteredArrayUsingPredicate:predicate];
    
    NSMutableArray *indexPaths = [NSMutableArray new];
    
    if (filtered && filtered.count) {
        for (FLTransaction *tmp in filtered) {
            NSUInteger index = [transactions indexOfObject:tmp];
            
            if (index != NSNotFound) {
                [transactions replaceObjectAtIndex:index withObject:transaction];
                
                [indexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
            }
        }
        
        if (indexPaths.count) {
            [_tableView beginUpdates];
            [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            [_tableView endUpdates];
        }
    }
}

- (void)commentTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    if (transaction.isCollect) {
        [appDelegate showPot:transaction inController:self withIndexPath:indexPath focusOnComment:YES];
    } else {
        [appDelegate showTransaction:transaction inController:self withIndexPath:indexPath focusOnComment:YES];
    }
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
    
    [[Flooz sharedInstance] timelineNextPage:_nextPageUrl success: ^(id result, NSString *nextPageUrl, FLScope *scope) {
        if (scope.key == currentScope.key) {
            [transactions addObjectsFromArray:result];
            _nextPageUrl = nextPageUrl;
            nextPageIsLoading = NO;
            [_tableView reloadData];
        }
    }];
}

- (void)showEmptyBack {
    NSString *imageName;
    
    if (currentScope.key == FLScopePrivate)
        imageName = @"empty-timeline-private";
    else if (currentScope.key == FLScopeFriend)
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
    
    [[Flooz sharedInstance] timeline:currentScope success: ^(id result, NSString *nextPageUrl, FLScope *scope) {
        if (scope.key == currentScope.key) {
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
    
    NSString *text = currentScope.desc;
    
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
    if (availableScopes.count == 1) {
        [self checkScopeAvailability];
        [self showScopeHelper];
        return;
    }
    
    for (int i = 0; i < availableScopes.count; i++) {
        FLScope *scope = [availableScopes objectAtIndex:i];
        
        if (currentScope.key == scope.key) {
            int nextIndex = i + 1;
            
            if (nextIndex == availableScopes.count)
                nextIndex = 0;
            
            currentScope = [availableScopes objectAtIndex:nextIndex];
            break;
        }
    }

    [self checkScopeAvailability];
    [self showScopeHelper];
    [self reloadTableView];
}

#pragma mark - TransitionCoordinator

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Executes before and after rotation, that way any ABMediaViews can adjust their frames for the new size. Is especially helpful when users are watching landscape videos and rotate their devices between portrait and landscape.
    
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        
        // Notifies the ABMediaView that the device is about to rotate
        [[NSNotificationCenter defaultCenter] postNotificationName:ABMediaViewWillRotateNotification object:nil];
        
    } completion:^(id  _Nonnull context) {
        
        // Change origin rect because the screen has rotated
        //        self.mediaView.originRect = self.mediaView.frame;
        
        // Notifies the ABMediaView that the device just finished rotating
        [[NSNotificationCenter defaultCenter] postNotificationName:ABMediaViewDidRotateNotification object:nil];
    }];
}

@end
