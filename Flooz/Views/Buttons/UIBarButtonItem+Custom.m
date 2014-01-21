//
//  UIBarButtonItem+Custom.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "UIBarButtonItem+Custom.h"

@implementation UIBarButtonItem (Custom)

+ (id)createBackButtonWithTarget:(id)target action:(SEL)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMakeSize(20, 17)];
    [button setImage:[UIImage imageNamed:@"navbar-back"]  forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchDown];
    
    return [[self alloc] initWithCustomView:button];
}

+ (id)createCheckButtonWithTarget:(id)target action:(SEL)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMakeSize(25, 17)];
    [button setImage:[UIImage imageNamed:@"navbar-check"]  forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchDown];
    
    return [[self alloc] initWithCustomView:button];
}

@end
