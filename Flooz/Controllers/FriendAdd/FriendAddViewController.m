//
//  FriendAddViewController.m
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendAddViewController.h"

@interface FriendAddViewController ()

@end

@implementation FriendAddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        friends = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchBar becomeFirstResponder];
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [friends count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [FriendAddCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"FriendAddCell";
    FriendAddCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[FriendAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLUser *user = [friends objectAtIndex:indexPath.row];
    [cell setUser:user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLUser *user = [friends objectAtIndex:indexPath.row];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendAcceptSuggestion:[user userId] success:^{
        [self dismiss];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchBar close];
}

#pragma -

- (void)dismiss{
    if([self navigationController]){
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)didFilterChange:(NSString *)text
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] friendSearch:text success:^(id result) {
        friends = result;
        [_tableView reloadData];
        [_tableView setContentOffset:CGPointZero animated:YES];
    }];
}

@end
