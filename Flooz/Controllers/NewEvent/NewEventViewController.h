//
//  NewEventViewController.h
//  Flooz
//
//  Created by Jonathan on 31/07/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLSelectAmountDelegate.h"

@interface NewEventViewController : UIViewController<FLSelectAmountDelegate>

@property (weak, nonatomic) IBOutlet FLValidNavBar *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@end
