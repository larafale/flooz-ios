//
//  FLFilterPopoverViewController.h
//  Flooz
//
//  Created by Flooz on 7/23/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLFilterPopoverDelegate

- (void) scopeChange:(TransactionScope)scope;

@end

@interface FLFilterPopoverViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak) id <FLFilterPopoverDelegate> delegate;
@property (nonatomic) TransactionScope currentScope;

@end
