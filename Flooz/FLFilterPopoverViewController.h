//
//  FLFilterPopoverViewController.h
//  Flooz
//
//  Created by Epitech on 7/23/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLFilterPopoverDelegate

- (void) scopeChange:(TransactionScope)scope;

@end

@interface FLFilterPopoverViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak) id <FLFilterPopoverDelegate> delegate;
@property (nonatomic) TransactionScope currentScope;

@end
