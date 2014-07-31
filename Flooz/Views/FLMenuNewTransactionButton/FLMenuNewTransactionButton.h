//
//  FLMenuNewTransactionButton.h
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLMenuNewTransactionButton : UIButton

- (id)initWithPosition:(CGFloat)positionY imageNamed:(NSString *)imageNamed title:(NSString *)title;

- (void)startAnimationWithDelay:(NSTimeInterval)delay;
- (void)startReverseAnimationWithDelay:(NSTimeInterval)delay;

@end
