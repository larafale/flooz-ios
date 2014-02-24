//
//  EventCell.h
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLEvent.h"
#import "EventCellDelegate.h"

#import "FLSocialView.h"

@interface EventCell : UITableViewCell{
    CGFloat height;
    
    UIView *actionView;
    UIView *rightView;
    UIView *slideView;
    
    CGPoint totalTranslation;
    CGPoint lastTranslation;
    
    BOOL isSwipable;
}

+ (CGFloat)getHeightForEvent:(FLEvent *)event;

@property (weak, nonatomic) UIViewController<EventCellDelegate> *delegate;
@property (weak, nonatomic) FLEvent *event;

@end
