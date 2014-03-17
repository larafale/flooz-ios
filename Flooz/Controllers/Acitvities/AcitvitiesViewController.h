//
//  AcitvitiesViewController.h
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcitvitiesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSArray *activities;
    
    UIRefreshControl *refreshControl;
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
