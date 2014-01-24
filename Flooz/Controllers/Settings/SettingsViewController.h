//
//  SettingsViewController.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLFilterView.h"

@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
