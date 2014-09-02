//
//  HistoricalViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-08-27.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoricalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

- (id) initWithArrayTransaction:(NSArray *)array;

@end
