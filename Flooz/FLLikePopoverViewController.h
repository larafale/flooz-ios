//
//  FLLikePopoverViewController.h
//  Flooz
//
//  Created by Olivier on 12/31/14.
//  Copyright (c) 2014 olivier Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLLikePopoverViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithTransaction:(FLTransaction*)transac;

@end
