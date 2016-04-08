//
//  CollectParticipantViewController.m
//  Flooz
//
//  Created by Olive on 3/19/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ParticipantCell.h"
#import "LoadingCell.h"
#import "CollectParticipantViewController.h"
#import "CollectParticipationViewController.h"

@interface CollectParticipantViewController () {
    FLTransaction *_collect;
}

@end

@implementation CollectParticipantViewController

@synthesize tableView;

- (id)initWithCollect:(FLTransaction *)collect {
    self = [super init];
    if (self) {
        _collect = collect;
    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        if (data && data[@"_id"]) {
            [[Flooz sharedInstance] transactionWithId:data[@"_id"] success:^(id result) {
                _collect = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
                [tableView reloadData];
            }];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = @"Participants";
    
    self.tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    
    [_mainBody addSubview:self.tableView];
}

#pragma marks - tableview delegate / datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_collect.participants.count ? _collect.participants.count : 1);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_collect)
        return [LoadingCell getHeight];
    
    return [ParticipantCell getHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_collect)
        return [LoadingCell new];
    
    static NSString *cellIdentifier = @"FriendCell";
    ParticipantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[ParticipantCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLUser *participant = [_collect.participants objectAtIndex:indexPath.row];
    
    [cell setParticipant:participant];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_collect) {
        FLUser *participant = _collect.participants[indexPath.row];
        
        if ([participant.countParticipations intValue] > 1)
            [self.navigationController pushViewController:[[CollectParticipationViewController alloc] initWithCollectId:_collect.transactionId andUserId:[_collect.participants[indexPath.row] userId]] animated:YES];
        else {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] transactionWithId:participant.participations[0][@"_id"] success: ^(id result) {
                FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
                [appDelegate showTransaction:transaction inController:self withIndexPath:nil focusOnComment:NO completion:nil];
            }];
        }
    }
}

@end
