//
//  TimelineViewController.h
//  Flooz
//
//  Created by olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionCellDelegate.h"
#import "TimelineDealCellDelegate.h"
#import "FLScrollViewIndicator.h"
#import "TimelineDelegate.h"
#import "WYPopoverController.h"
#import "FLFilterPopoverViewController.h"

@interface TimelineViewController : GlobalViewController <UIScrollViewDelegate, TimelineDelegate, WYPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, TransactionCellDelegate, TimelineDealCellDelegate> {

}

@property (nonatomic) FLTableView *tableView;

@end
