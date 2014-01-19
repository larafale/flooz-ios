//
//  TimelineViewController.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLFilterView.h"

@interface TimelineViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSArray *transactions;
    UIButton *crossButton;
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;
@property (weak, nonatomic) IBOutlet FLFilterView *filterView;

@end
