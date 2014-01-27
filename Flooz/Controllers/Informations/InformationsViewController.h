//
//  InformationsViewController.h
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InformationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
