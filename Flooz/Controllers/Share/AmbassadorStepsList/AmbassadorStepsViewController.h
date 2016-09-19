//
//  AmbassadorStepsViewController.h
//  Flooz
//
//  Created by Olive on 4/4/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AmbassadorStepsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) MZFormSheetController *formSheet;

- (void)show;

@end
