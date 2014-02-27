//
//  EventParticipantsViewController.h
//  Flooz
//
//  Created by jonathan on 2/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventParticipantsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithEvent:(FLEvent *)event;

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
