//
//  SocialViewController.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLFilterView.h"

@interface SocialViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>{
    NSArray *events;
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;
@property (weak, nonatomic) IBOutlet FLFilterView *filterView;

@end
