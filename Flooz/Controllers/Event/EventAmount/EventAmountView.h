//
//  EventAmountView.h
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventAmountView : UIView{
    CGFloat height;
    
    UIView *amountView;
    UIView *dayView;
    UIView *progressBarView;
}

@property (weak, nonatomic) FLEvent *event;

+ (CGFloat)getHeightForEvent:(FLEvent *)event;
- (void)hideBottomBar;

@end
