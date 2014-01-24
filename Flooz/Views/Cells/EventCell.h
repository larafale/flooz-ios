//
//  EventCell.h
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLEvent.h"

#import "FLSocialView.h"

@interface EventCell : UITableViewCell{
    CGFloat height;
        
    UIView *rightView;
    UIView *slideView;
}

+ (CGFloat)getEstimatedHeight;
+ (CGFloat)getHeightForEvent:(FLEvent *)event;

@property (strong, nonatomic) FLEvent *event;

@end
