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

@implementation TimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_TIMELINE", nil);
        transactions = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    UIImageView *shadow = [UIImageView imageNamed:@"tableview-shadow"];
    shadow.frame = CGRectSetY(shadow.frame, self.view.frame.size.height - shadow.frame.size.height);
    [self.view addSubview:shadow];
        
    UIImage *buttonImage = [UIImage imageNamed:@"menu-new-transaction"];
    crossButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonImage.size.width) / 2., self.view.frame.size.height - buttonImage.size.height - 20, buttonImage.size.width, buttonImage.size.height)];
    [crossButton setImage:buttonImage forState:UIControlStateNormal];
    [self.view addSubview:crossButton];
    
    [crossButton addTarget:self action:@selector(presentMenuTransactionController) forControlEvents:UIControlEventTouchDown];
    
    
    {
        [_filterView addFilter:@"TIMELINE_FILTER_PUBLIC" target:self action:@selector(didFilterPublicTouch)];
        [_filterView addFilter:@"TIMELINE_FILTER_FRIEND" target:self action:@selector(didFilterFriendTouch)];
        [_filterView addFilter:@"TIMELINE_FILTER_PERSO" target:self action:@selector(didFilterPersoTouch:) colors:@[
                                                                                        [UIColor customBlue],
                                                                                        [UIColor customYellow],
                                                                                        [UIColor customGreen]
                                                                                        ]];
    }
    
    [self didFilterPublicTouch];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    crossButton.hidden = NO;
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [transactions count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
    return [TransactionCell getHeightForTransaction:transaction];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TransactionCell";
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
    [cell setTransaction:transaction];
    
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

- (void)didFilterPublicTouch
{
    [[Flooz sharedInstance] timeline:@"public" success:^(id result) {
        transactions = result;
        [self didFilterChange];
    } failure:NULL];
}

- (void)didFilterFriendTouch
{
    [[Flooz sharedInstance] timeline:@"friend" success:^(id result) {
        transactions = result;
        [self didFilterChange];
    } failure:NULL];
}

- (void)didFilterPersoTouch:(NSNumber *)index
{
    [[Flooz sharedInstance] timeline:@"perso" success:^(id result) {
        transactions = result;
        [self didFilterChange];
    } failure:NULL];
}

- (void)didFilterChange
{
    [_tableView reloadData];
    [_tableView setContentOffset:CGPointZero animated:YES]; // WARNING Bug graphique quand scroll
}

@end
