//
//  EventsViewController.m
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventsViewController.h"

#import "EventCell.h"
#import "EventViewController.h"

#import "MenuNewTransactionViewController.h"

@implementation EventsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_EVENTS", nil);
        events = [NSMutableArray new];
        nextPageIsLoading = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *shadow = [UIImageView imageNamed:@"tableview-shadow"];
    CGRectSetY(shadow.frame, self.view.frame.size.height - shadow.frame.size.height);
    [self.view addSubview:shadow];
    
    refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:refreshControl];
    
    // Padding pour que le dernier element au dessus du +
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMakeSize(SCREEN_WIDTH, 90)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefresh) name:@"reloadEvents" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    if(!animated){
        [self handleRefresh];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [events count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLEvent *event = [events objectAtIndex:indexPath.row];
    return [EventCell getHeightForEvent:event];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"EventCell";
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate = self;
    }
    
    FLEvent *event = [events objectAtIndex:indexPath.row];
    [cell setEvent:event];
    
    if(_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [events count] - 1){
        [self loadNextPage];
    }
    
    return cell;
}

#pragma mark - EventCellDelegate

- (void)didEventTouchAtIndex:(NSIndexPath *)indexPath event:(FLEvent *)event
{
    EventViewController *controller = [[EventViewController alloc] initWithEvent:event indexPath:indexPath];
    controller.delegateController = self;
    self.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self presentViewController:controller animated:NO completion:^{
        self.parentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }];
}

- (void)updateEventAtIndex:(NSIndexPath *)indexPath event:(FLTransaction *)event
{
    [events replaceObjectAtIndex:indexPath.row withObject:event];
    
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

- (void)loadNextPage{
    if(!_nextPageUrl || [_nextPageUrl isBlank]){
        return;
    }
    nextPageIsLoading = YES;
    
    [[Flooz sharedInstance] eventsNextPage:_nextPageUrl success:^(id result, NSString *nextPageUrl) {
        [events addObjectsFromArray:result];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [_tableView reloadData];
    }];
}

- (void)handleRefresh
{
    [refreshControl beginRefreshing];
    
    [[Flooz sharedInstance] events:@"1" success:^(id result, NSString *nextPageUrl) {
        events = [result mutableCopy];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [refreshControl endRefreshing];
        
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointZero animated:YES];
    } failure:NULL];
}

#pragma mark -

- (void)presentMenuTransactionController
{    
    UIViewController *controller = [MenuNewTransactionViewController new];
    self.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [self presentViewController:controller animated:YES completion:^{
        self.parentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }];
}

@end
