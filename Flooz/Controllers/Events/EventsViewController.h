//
//  EventsViewController.h
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSArray *events;
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
