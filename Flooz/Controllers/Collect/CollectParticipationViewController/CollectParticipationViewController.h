//
//  CollectParticipationViewController.h
//  Flooz
//
//  Created by Olive on 3/20/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "TransactionCellDelegate.h"

@interface CollectParticipationViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, TransactionCellDelegate>

- (id)initWithCollectId:(NSString *)collect;

@property (nonatomic, retain) UITableView *tableView;

@end
