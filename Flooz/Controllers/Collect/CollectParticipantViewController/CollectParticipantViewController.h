//
//  CollectParticipantViewController.h
//  Flooz
//
//  Created by Olive on 3/19/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectParticipantViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;

- (id)initWithCollect:(FLTransaction *)collect;

@end
