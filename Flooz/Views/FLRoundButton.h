//
//  RoundButton.h
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLRoundButton : UIButton

- (id)initWithPosition:(CGFloat)positionY imageName:(NSString *)imageName text:(NSString *)text;

- (void)startAnimationWithDelay:(NSTimeInterval)delay;

@end
