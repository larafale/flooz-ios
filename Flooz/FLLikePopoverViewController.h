//
//  FLLikePopoverViewController.h
//  Flooz
//
//  Created by Epitech on 12/31/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLLikePopoverViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithTransaction:(FLTransaction*)transac;

@end
