//
//  EventActionViewDelegate.h
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventActionViewDelegate <NSObject>

- (void)reloadEvent;

- (void)showPaymentField;
- (void)refuseEvent;

- (void)presentEventParticipantsController;

@end
