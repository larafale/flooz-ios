//
//  FLMenuNewTransactionButton.h
//  Flooz
//
//  Created by olivier on 1/11/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLMenuNewTransactionButton : UIButton

- (id)initWithPosition:(CGFloat)positionY imageNamed:(NSString *)imageNamed title:(NSString *)title;

- (void)startAnimationWithDelay:(NSTimeInterval)delay;
- (void)startReverseAnimationWithDelay:(NSTimeInterval)delay;

@end
