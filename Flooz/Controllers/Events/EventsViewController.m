//
//  EventsViewController.m
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventsViewController.h"

#import "EventCell.h"
#import "TransactionViewController.h"

@implementation EventsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        events = [NSMutableArray new];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(!animated){
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] eventsWithSuccess:^(id result) {
            events = [result mutableCopy];
                        
            [_tableView reloadData];
            [_tableView setContentOffset:CGPointZero animated:YES];
        } failure:NULL];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // WARNING Hack contraintes ne fonctionnent pas
    _tableView.frame = CGRectMakeWithSize(self.view.frame.size);
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
    
    return cell;
}

#pragma mark - EventCellDelegate

- (void)didEventTouchAtIndex:(NSIndexPath *)indexPath event:(FLEvent *)event
{
//    TransactionViewController *controller = [[TransactionViewController alloc] initWithTransaction:event indexPath:indexPath];
//    controller.delegateController = self;
//    self.parentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
//    
//    [self presentViewController:controller animated:YES completion:^{
//        self.parentViewController.modalPresentationStyle = UIModalPresentationFullScreen;
//    }];
}

- (void)updateEventAtIndex:(NSIndexPath *)indexPath event:(FLTransaction *)event
{
    [events replaceObjectAtIndex:indexPath.row withObject:event];
    
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

@end
