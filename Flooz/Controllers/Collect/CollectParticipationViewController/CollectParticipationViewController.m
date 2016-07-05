//
//  CollectParticipationViewController.m
//  Flooz
//
//  Created by Olive on 3/20/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CollectParticipationViewController.h"
#import "TransactionCell.h"
#import "TUSafariActivity.h"
#import "ARChromeActivity.h"
#import "FLCopyLinkActivity.h"

@interface CollectParticipationViewController () {
    NSMutableArray *transactions;
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
    
    UIRefreshControl *refreshControl;
    NSString *collectId;
    NSString *userId;
}

@end

@implementation CollectParticipationViewController

- (id)initWithCollectId:(NSString *)collect andUserId:(NSString *)user {
    self = [super init];
    if (self) {
        collectId = collect;
        userId = user;
        
        transactions = [NSMutableArray new];
        nextPageIsLoading = NO;
    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        if (data && data[@"_id"]) {
            collectId = data[@"_id"];
        }

        if (data && data[@"userId"]) {
            userId = data[@"userId"];
        }
        
        transactions = [NSMutableArray new];
        nextPageIsLoading = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = @"Participations";
    
    _tableView = [FLTableView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setScrollsToTop:YES];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_mainBody addSubview:_tableView];
    
    // Padding pour que le dernier element au dessus du +
    _tableView.tableFooterView = [UIView new];
    
    refreshControl = [UIRefreshControl new];
    [refreshControl setTintColor:[UIColor customBlueLight]];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadTableView];
}

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
    
    id item = [transactions objectAtIndex:indexPath.row];
    
    if ([item isKindOfClass:[FLTransaction class]]) {
        FLTransaction *transaction = item;
        return [TransactionCell getHeightForTransaction:transaction andWidth:CGRectGetWidth(tableView.frame) hideTitle:YES];
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
            cell.hideTitle = YES;
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
    
    [shareController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
    }];
    
    [shareController setExcludedActivityTypes:@[UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeAirDrop]];
    
    [self.navigationController presentViewController:shareController animated:YES completion:^{
        
    }];
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

- (void)loadNextPage {
    if (!_nextPageUrl || [_nextPageUrl isBlank]) {
        return;
    }
    
    nextPageIsLoading = YES;
    
    [[Flooz sharedInstance] collectTimelineNextPage:_nextPageUrl collectId:collectId withUser:userId success:^(id result, NSString *nextPageUrl) {
        [transactions addObjectsFromArray:result];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [_tableView reloadData];
    }];
}

- (void)reloadTableView {
    if (![transactions count]) {
        [refreshControl beginRefreshing];
    }
    
    [[Flooz sharedInstance] collectTimeline:collectId withUser:userId success:^(id result, NSString *nextPageUrl) {
        transactions = [result mutableCopy];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [_tableView reloadData];
        [refreshControl endRefreshing];
    } failure:^(NSError *error) {
        [refreshControl endRefreshing];
    }];
}

@end
