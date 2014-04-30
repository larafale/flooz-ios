//
//  AcitvitiesViewController.m
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "AcitvitiesViewController.h"

#import "ActivityCell.h"

#import "TransactionViewController.h"
#import "EventViewController.h"
#import "FriendsViewController.h"

@interface AcitvitiesViewController ()

@end

@implementation AcitvitiesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        activities = [NSMutableArray new];
        isLoaded = NO;
        nextPageIsLoading = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor customBackgroundHeader:0.8];
    
    [self createTableHeaderView];
    CGRectSetX(tableHeaderView.frame, _tableView.frame.origin.x);
    [self.view addSubview:tableHeaderView];
    
    {
        tableViewShadow = [UIView new];
        [self.view insertSubview:tableViewShadow belowSubview:_tableView];
        
        tableViewShadow.backgroundColor = _tableView.backgroundColor;
        
        tableViewShadow.layer.borderWidth = 1.;
        tableViewShadow.layer.borderColor = [UIColor customSeparator].CGColor;
        
        tableViewShadow.clipsToBounds = NO;
        tableViewShadow.layer.shadowColor = [UIColor blackColor].CGColor;
        tableViewShadow.layer.shadowOffset = CGSizeMake(0, 0);
        tableViewShadow.layer.shadowRadius = 5.;
        tableViewShadow.layer.shadowOpacity = 0.5;
    }
    
    refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self refreshTableHeaderView];
    
    if(!isLoaded){
        isLoaded = YES;
        
        _tableView.hidden = YES;
        tableHeaderView.hidden = YES;
        
        [self showTableView];
        
        [[Flooz sharedInstance] activitiesWithSuccess:^(id result, NSString *nextPageUrl) {
            activities = [result mutableCopy];;
            _nextPageUrl = nextPageUrl;
            [refreshControl endRefreshing];
            
            [self refreshTableHeaderView];
            [_tableView reloadData];
            [_tableView setContentOffset:CGPointZero animated:NO];
        } failure:NULL];
        
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_nextPageUrl && ![_nextPageUrl isBlank]){
        return [activities count] + 1;
    }
    
    return [activities count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row >= [activities count]){
        return [LoadingCell getHeight];
    }
    
    FLActivity *activity = [activities objectAtIndex:indexPath.row];
    return [ActivityCell getHeightForActivity:activity];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == [activities count]){
        static LoadingCell *footerView;
        if(!footerView){
            footerView = [LoadingCell new];
        }
        footerView.hidden = refreshControl.isRefreshing;
        return footerView;
    }
    
    static NSString *cellIdentifier = @"ActivityCell";
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[ActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLActivity *activity = [activities objectAtIndex:indexPath.row];
    [cell setActivity:activity];
    
    if(_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [activities count] - 1){
        [self loadNextPage];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLActivity *activity = [activities objectAtIndex:indexPath.row];

    activity.isRead = YES;
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    
    if([activity transactionId]){
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] transactionWithId:[activity transactionId] success:^(id result) {
            FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            TransactionViewController *controller = [[TransactionViewController alloc] initWithTransaction:transaction indexPath:indexPath];
            
            self.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            
            [self presentViewController:controller animated:NO completion:^{
                self.parentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            }];
        }];
    }
    else if([activity eventId]){
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] eventWithId:[activity eventId] success:^(id result) {
            FLEvent *event = [[FLEvent alloc] initWithJSON:[result objectForKey:@"item"]];
            EventViewController *controller = [[EventViewController alloc] initWithEvent:event indexPath:indexPath];
            
            self.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
            
            [self presentViewController:controller animated:NO completion:^{
                self.parentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            }];
        }];
    }
    else if([activity isFriend]){
        FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[FriendsViewController new]];
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)handleRefresh
{
    [refreshControl beginRefreshing];
    
    [[Flooz sharedInstance] activitiesWithSuccess:^(id result, NSString *nextPageUrl) {
        activities = [result mutableCopy];;
        _nextPageUrl = nextPageUrl;
        [refreshControl endRefreshing];
        
        [self refreshTableHeaderView];
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointZero animated:YES];
    } failure:NULL];
}

- (void)dismiss
{
    [[Flooz sharedInstance] socketSendCloseActivities];
    
    [UIView animateWithDuration:.4 animations:^{
        CGRectSetY(_tableView.frame, - CGRectGetHeight(_tableView.frame));
        tableViewShadow.frame = _tableView.frame;
        CGRectSetY(tableHeaderView.frame, _tableView.frame.origin.y - CGRectGetHeight(tableHeaderView.frame));
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.view];
    
    return !CGRectContainsPoint(_tableView.frame, location);
}

- (UIView *)createTableHeaderView
{
    tableHeaderView = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(_tableView.frame), 40)];
    
    tableHeaderView.textAlignment = NSTextAlignmentCenter;
    tableHeaderView.backgroundColor = [UIColor customBlue];
    tableHeaderView.textColor = [UIColor whiteColor];
    tableHeaderView.font = [UIFont customTitleBook:14];
    
    {
        UIImageView *image = [UIImageView imageNamed:@"close-activities"];
        CGRectSetXY(image.frame, CGRectGetWidth(tableHeaderView.frame) - 30, 10);
        [tableHeaderView addSubview:image];
        
        UITapGestureRecognizer *close = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [image addGestureRecognizer:close];
        image.userInteractionEnabled = YES;
        tableHeaderView.userInteractionEnabled = YES;
    }
    
    return tableHeaderView;
}

- (void)refreshTableHeaderView
{
    if([[[Flooz sharedInstance] notificationsCount] intValue] == 0){
        tableHeaderView.text = NSLocalizedString(@"ACTIVITIES_NOTIFICATIONS", nil);
    }
    else{
        tableHeaderView.text = [NSString stringWithFormat:@"%.2d %@", [[[Flooz sharedInstance] notificationsCount] intValue], NSLocalizedString(@"ACTIVITIES_NEW_NOTIFICATIONS", nil)];
    }
}

- (void)loadNextPage{
    if(!_nextPageUrl || [_nextPageUrl isBlank]){
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

- (void)showTableView
{
    CGFloat tableViewY = _tableView.frame.origin.y;
    CGRectSetY(_tableView.frame, - CGRectGetWidth(_tableView.frame));
    CGRectSetY(tableHeaderView.frame, _tableView.frame.origin.y - CGRectGetHeight(tableHeaderView.frame));
    _tableView.hidden = NO;
    tableHeaderView.hidden = NO;
    
    tableViewShadow.frame = _tableView.frame;
    
    [UIView animateWithDuration:.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRectSetY(_tableView.frame, tableViewY + 25);
                         tableViewShadow.frame = _tableView.frame;
                         CGRectSetY(tableHeaderView.frame, _tableView.frame.origin.y - CGRectGetHeight(tableHeaderView.frame));
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:.3
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              
                                              CGRectSetY(_tableView.frame, tableViewY);
                                              tableViewShadow.frame = _tableView.frame;
                                              CGRectSetY(tableHeaderView.frame, _tableView.frame.origin.y - CGRectGetHeight(tableHeaderView.frame));
                                              
                                          } completion:nil];
                     }];
    
    
    
    {
        closeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        closeGesture.delegate = self;
        
        [self.view addGestureRecognizer:closeGesture];
    }

}

@end