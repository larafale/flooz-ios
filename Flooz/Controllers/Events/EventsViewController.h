//
//  EventsViewController.h
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventCellDelegate.h"

@interface EventsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, EventCellDelegate>{
    NSMutableArray *events;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;
@property (strong) NSString *scope;

@end
