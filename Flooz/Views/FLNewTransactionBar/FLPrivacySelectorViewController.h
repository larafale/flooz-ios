//
//  FLPrivacySelectorViewController.h
//  Flooz
//
//  Created by Olivier on 2/19/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLScope.h"

@protocol FLPrivacySelectorDelegate

- (void) scopeChange:(FLScope *)scope;

@end

@interface FLPrivacySelectorViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithPreset:(FLPreset *)preset;

@property (weak) id <FLPrivacySelectorDelegate> delegate;
@property (nonatomic, strong) FLScope *currentScope;

@end
