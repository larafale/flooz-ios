//
//  TimelineViewController.h
//  Flooz
//
//  Created by Olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionCellDelegate.h"
#import "TimelineDelegate.h"
#import "WYPopoverController.h"

@interface TimelineViewController : GlobalViewController <UIScrollViewDelegate, TimelineDelegate, WYPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, TransactionCellDelegate> {

}

@property (nonatomic) FLTableView *tableView;

@end
