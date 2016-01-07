//
//  DealViewController.m
//  Flooz
//
//  Created by Olive on 1/6/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "DealCell.h"
#import "DealViewController.h"

@interface DealViewController ()

@property (nonatomic, strong) NSMutableArray *deals;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DealViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.deals = [NSMutableArray new];
    
    FLDeal *deal = [[FLDeal alloc] initWithJSON:nil];
    deal.amount = @88;
    deal.amountType = FLDealAmountTypeVariable;
    deal.desc = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    deal.pic = @"https://res.cloudinary.com/dc1emihjc/image/upload/5_wwfk2a.png";
    deal.title = @"Offre de Bienvenue";
    
    [self.deals addObject:deal];
    
    FLDeal *deal2 = [[FLDeal alloc] initWithJSON:nil];
    deal2.amount = @100;
    deal2.amountType = FLDealAmountTypeFixed;
    deal2.desc = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    deal2.title = @"Offre de Bienvenue";
    
    [self.deals addObject:deal2];

    FLDeal *deal3 = [[FLDeal alloc] initWithJSON:nil];
    deal3.amount = @5;
    deal3.amountType = FLDealAmountTypeVariable;
    deal3.desc = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit.";
    deal3.title = @"Offre de Bienvenue";
    
    [self.deals addObject:deal3];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor customBackgroundHeader]];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    [_mainBody addSubview:self.tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLDeal *deal = [self.deals objectAtIndex:indexPath.row];
    return [DealCell getHeight:deal];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.deals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DealCell";
    DealCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[DealCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLDeal *deal = [self.deals objectAtIndex:indexPath.row];
    [cell setDeal:deal];

    return cell;
}

@end
