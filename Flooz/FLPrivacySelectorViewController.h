//
//  FLPrivacySelectorViewController.h
//  Flooz
//
//  Created by Olivier on 2/19/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLPrivacySelectorDelegate

- (void) scopeChange:(TransactionScope)scope;

@end

@interface FLPrivacySelectorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithPreset:(FLPreset *)preset;

@property (weak) id <FLPrivacySelectorDelegate> delegate;
@property (nonatomic) TransactionScope currentScope;

@end