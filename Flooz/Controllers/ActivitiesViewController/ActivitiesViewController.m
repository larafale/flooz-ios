//
//  ActivitiesViewController.m
//  Flooz
//
//  Created by Olive on 4/20/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ActivityCell.h"
#import "ActivitiesViewController.h"

@interface ActivitiesViewController() {
    FLTableView *_tableView;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
    NSMutableArray *activities;
}

@end

@implementation ActivitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_ACTIVITIES", nil);
    
    activities = [NSMutableArray new];
    
    _tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setScrollsToTop:YES];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setSeparatorColor:[UIColor customBackground]];
    [_tableView setTableFooterView:[UIView new]];
    
    [_mainBody addSubview:_tableView];
    
    refreshControl = [UIRefreshControl new];
    [refreshControl setTintColor:[UIColor customBlueLight]];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    
    _tableView.backgroundColor = [UIColor customBackgroundHeader];
    
    [self reloadTableView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:kNotificationRefreshActivities object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_nextPageUrl && ![_nextPageUrl isBlank]) {
        return [activities count] + 1;
    }
    
    return [activities count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= [activities count]) {
        return [LoadingCell getHeight];
    }
    
    return [ActivityCell getHeightForActivity:[activities objectAtIndex:indexPath.row]];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [activities count]) {
        static LoadingCell *footerView;
        if (!footerView) {
            footerView = [LoadingCell new];
        }
        footerView.hidden = refreshControl.isRefreshing;
        return footerView;
    }
    
    if (_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [activities count] - 1) {
        [self loadNextPage];
    }
    
    static NSString *cellIdentifier = @"ActivityCell";
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[ActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLActivity *activity = [activities objectAtIndex:indexPath.row];
    
    [cell setActivity:activity];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLActivity *activity = [activities objectAtIndex:indexPath.row];
    
    [[FLTriggerManager sharedInstance] executeTriggerList:activity.triggers];
}

- (void)loadNextPage {
    if (!_nextPageUrl || [_nextPageUrl isBlank]) {
        return;
    }
    
    nextPageIsLoading = YES;
    
    [[Flooz sharedInstance] activitiesNextPage:_nextPageUrl success:^(id result, NSString *nextPageUrl) {
        [activities addObjectsFromArray:result];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [_tableView reloadData];
    }];
}

- (void)handleRefresh {
    [refreshControl beginRefreshing];
    [self reloadTableView];
}

- (void)reloadTableView {
    if (![activities count]) {
        [_tableView setContentOffset:CGPointMake(0.0f, -60.0f) animated:YES];
        [refreshControl beginRefreshing];
    }
    
    [[Flooz sharedInstance] activitiesWithSuccess:^(id result, NSString *next) {
        [refreshControl endRefreshing];
        activities = result;
        _nextPageUrl = next;
        
        [_tableView reloadData];
    } failure:^(NSError *error) {
        [refreshControl endRefreshing];
    }];
}

@end
