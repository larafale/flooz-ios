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
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
