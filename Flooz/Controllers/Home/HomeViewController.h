//
//  HomeViewController.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSArray *transactions;
}

@property (strong, nonatomic) IBOutlet FLTableView *tableView;

@end
