//
//  FLTimelineTableViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-09-24.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLScrollViewIndicator.h"

#import "TransactionCellDelegate.h"
#import "TransactionCell.h"

#import "MenuNewTransactionViewController.h"
#import "NewTransactionViewController.h"
#import "TransactionViewController.h"

@interface FLTimelineTableViewController : GlobalViewController <UITableViewDelegate, UITableViewDataSource, TransactionCellDelegate>

@property (nonatomic) FLTableView *tableView;

- (id)initWithFrame:(CGRect)frame andFilter:(NSString *)filter;
- (void)reloadTableView;

@end
