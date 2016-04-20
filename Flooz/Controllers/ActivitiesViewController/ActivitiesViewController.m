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

    NSArray *activities;
}

@end

@implementation ActivitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_ACTIVITIES", nil);
    
    _tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStylePlain];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setSeparatorColor:[UIColor customBackground]];
    [_tableView setTableFooterView:[UIView new]];
    
    [_mainBody addSubview:_tableView];
    
    refreshControl = [UIRefreshControl new];
    [refreshControl setTintColor:[UIColor customBlueLight]];
    [refreshControl addTarget:self action:@selector(didReloadData) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    
    _tableView.backgroundColor = [UIColor customBackgroundHeader];
    
    [self didReloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self didReloadData];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return activities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (activities && activities.count)
        return [ActivityCell getHeightForActivity:[activities objectAtIndex:indexPath.row]];
    
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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

}

- (void)didReloadData {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] activitiesWithSuccess:^(id result) {
        [refreshControl endRefreshing];
        activities = result;

        [_tableView reloadData];
    } failure:nil];
}

@end
