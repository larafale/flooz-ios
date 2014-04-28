//
//  EventContentView.h
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventContentView : UIView{
    CGFloat height;
    
    id _target;
    SEL _action;
}

@property (weak, nonatomic) FLEvent *event;

- (void)addTargetForLike:(id)target action:(SEL)action;

@end
