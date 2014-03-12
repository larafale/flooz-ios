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

@interface AcitvitiesViewController ()

@end

@implementation AcitvitiesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        activities = @[];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!animated){
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] activitiesWithSuccess:^(id result) {
            activities = result;
            [_tableView reloadData];
            [_tableView setContentOffset:CGPointZero animated:YES];
        } failure:NULL];
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [activities count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLActivity *activity = [activities objectAtIndex:indexPath.row];
    return [ActivityCell getHeightForActivity:activity];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ActivityCell";
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[ActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLActivity *activity = [activities objectAtIndex:indexPath.row];
    [cell setActivity:activity];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLActivity *activity = [activities objectAtIndex:indexPath.row];
    
    if([activity transactionId]){
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] transactionWithId:[activity transactionId] success:^(id result) {
            FLTransaction *event = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            TransactionViewController *controller = [[TransactionViewController alloc] initWithTransaction:event indexPath:indexPath];
            
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
}

@end
