//
//  SocialViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "SocialViewController.h"

#import "EventCell.h"

@implementation SocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_SOCIAL", nil);
        events = [FLEvent testData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {
//        [_filterView addFilter:@"TIMELINE_FILTER_PUBLIC" target:self action:nil];
//        [_filterView addFilter:@"TIMELINE_FILTER_FRIEND" target:self action:nil];
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [events count];
}

- (CGFloat)tableView:(FLTableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EventCell getEstimatedHeight];
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
    }
    
    FLEvent *event = [events objectAtIndex:indexPath.row];
    [cell setEvent:event];
    
    return cell;
}

@end
