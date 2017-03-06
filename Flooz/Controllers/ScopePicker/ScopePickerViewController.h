//
//  ScopePickerViewController.h
//  Flooz
//
//  Created by Olive on 13/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FLScope.h"

@protocol ScopePickerViewControllerDelegate

- (void)scope:(FLScope *)scope pickedFrom:(UIViewController *)viewController;

@end

@interface ScopePickerViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<ScopePickerViewControllerDelegate> delegate;
@property (nonatomic, strong) FLScope * currentScope;

+ (id)newWithDelegate:(id<ScopePickerViewControllerDelegate>)delegate preset:(FLPreset *)preset forPot:(Boolean)pot;
- (id)initWithDelegate:(id<ScopePickerViewControllerDelegate>)delegate preset:(FLPreset *)preset forPot:(Boolean)pot;

@end
