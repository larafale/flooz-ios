//
//  PaymentSourceViewController.h
//  Flooz
//
//  Created by Olive on 18/05/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"

@interface PaymentSourceViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;

@end
