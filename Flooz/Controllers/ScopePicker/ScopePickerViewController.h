//
//  ScopePickerViewController.h
//  Flooz
//
//  Created by Olive on 13/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"

@protocol ScopePickerViewControllerDelegate

- (void)scope:(TransactionScope)scope pickedFrom:(UIViewController *)viewController;

@end

@interface ScopePickerViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<ScopePickerViewControllerDelegate> delegate;
@property (nonatomic) TransactionScope currentScope;

+ (id)newWithDelegate:(id<ScopePickerViewControllerDelegate>)delegate preset:(FLPreset *)preset forPot:(Boolean)pot;
- (id)initWithDelegate:(id<ScopePickerViewControllerDelegate>)delegate preset:(FLPreset *)preset forPot:(Boolean)pot;

@end
