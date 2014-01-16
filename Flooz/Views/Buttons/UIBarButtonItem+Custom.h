//
//  UIBarButtonItem+Custom.h
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Custom)

+ (id)createBackButtonWithTarget:(id)target action:(SEL)action;
+ (id)createCheckButtonWithTarget:(id)target action:(SEL)action;

@end
