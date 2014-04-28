//
//  TransactionContentView.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionContentView : UIView{
    CGFloat height;
    
    id _target;
    SEL _action;
}

@property (weak, nonatomic) FLTransaction *transaction;

- (void)addTargetForLike:(id)target action:(SEL)action;

@end
