//
//  FLPrivacySelectorViewController.h
//  Flooz
//
//  Created by Epitech on 2/19/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLPrivacySelectorDelegate

- (void) scopeChange:(TransactionScope)scope;

@end

@interface FLPrivacySelectorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak) id <FLPrivacySelectorDelegate> delegate;
@property (nonatomic) TransactionScope currentScope;

@end