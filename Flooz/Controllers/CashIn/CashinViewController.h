//
//  CashinViewController.h
//  Flooz
//
//  Created by Olive on 4/14/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"

@interface CashinViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;

@end
