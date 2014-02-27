//
//  EventUsersView.h
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EventActionViewDelegate.h"

@interface EventUsersView : UIView

@property (weak, nonatomic) FLEvent *event;
@property (weak, nonatomic) id<EventActionViewDelegate> delegate;

@end
