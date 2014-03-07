//
//  EventAmountActionsView.h
//  Flooz
//
//  Created by jonathan on 2/28/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EventActionViewDelegate.h"

@interface EventAmountActionsView : UIView

@property (weak, nonatomic) FLEvent *event;
@property (weak, nonatomic) id<EventActionViewDelegate> delegate;

@end
