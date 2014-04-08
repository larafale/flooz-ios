//
//  EventViewController.h
//  Flooz
//
//  Created by jonathan on 2/25/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EventActionViewDelegate.h"
#import "EventCellDelegate.h"
#import "FLPaymentFieldDelegate.h"
#import "FLNewTransactionAmountDelegate.h"
#import "FLSwitchView.h"

@interface EventViewController : UIViewController<EventActionViewDelegate, FLPaymentFieldDelegate, FLNewTransactionAmountDelegate, FLSwitchViewDelegate>

- (id)initWithEvent:(FLEvent *)event indexPath:(NSIndexPath *)indexPath;

@property (strong, nonatomic) UIViewController<EventCellDelegate> *delegateController;
@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@end
