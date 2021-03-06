//
//  UIBarButtonItem+Custom.m
//  Flooz
//
//  Created by Olivier on 1/15/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "UIBarButtonItem+custom.h"

@implementation UIBarButtonItem (custom)

+ (id)createBackButtonWithTarget:(id)target action:(SEL)action {
	return [UIBarButtonItem barButtonWithImageNamed:@"navbar-back" target:target action:action];
}

+ (id)createCheckButtonWithTarget:(id)target action:(SEL)action {
	return [UIBarButtonItem barButtonWithImageNamed:@"navbar-check" target:target action:action];
}

+ (id)createCloseButtonWithTarget:(id)target action:(SEL)action {
    UIImage *image = [[FLHelper imageWithImage:[UIImage imageNamed:@"navbar-cross"] scaledToSize:CGSizeMake(18, 18)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMakeWithSize(image.size)];
    [button setTintColor:[UIColor customBlue]];
    [button setImage:image  forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
    
//	return [UIBarButtonItem barButtonWithImageNamed:@"navbar-cross" target:target action:action];
}

+ (id)createSearchButtonWithTarget:(id)target action:(SEL)action {
	return [UIBarButtonItem barButtonWithImageNamed:@"navbar-search" target:target action:action];
}

@end
