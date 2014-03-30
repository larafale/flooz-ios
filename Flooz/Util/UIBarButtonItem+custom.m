//
//  UIBarButtonItem+Custom.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "UIBarButtonItem+custom.h"

@implementation UIBarButtonItem (custom)

+ (id)createBackButtonWithTarget:(id)target action:(SEL)action
{
    return [UIBarButtonItem barButtonWithImageNamed:@"navbar-back" target:target action:action];
}

+ (id)createCheckButtonWithTarget:(id)target action:(SEL)action
{
    return [UIBarButtonItem barButtonWithImageNamed:@"navbar-check" target:target action:action];
}

+ (id)createCloseButtonWithTarget:(id)target action:(SEL)action
{
    return [UIBarButtonItem barButtonWithImageNamed:@"navbar-cross" target:target action:action];
}

+ (id)createSearchButtonWithTarget:(id)target action:(SEL)action
{
    return [UIBarButtonItem barButtonWithImageNamed:@"navbar-search" target:target action:action];
}

@end
