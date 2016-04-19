//
//  FLLikePopoverViewController.h
//  Flooz
//
//  Created by Olivier on 12/31/14.
//  Copyright (c) 2014 Olivier Mouren. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLLikePopoverViewControllerDelegate

- (void)didUserClick:(FLUser *)user;

@end

@interface FLLikePopoverViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) id<FLLikePopoverViewControllerDelegate> delegate;
@property (nonatomic, retain) UITableView *tableView;

- (id)initWithSocial:(FLSocial*)social;

@end
