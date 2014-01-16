//
//  SettingsViewController.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSArray *transactions;
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
