//
//  UIBarButtonItem+Custom.h
//  Flooz
//
//  Created by olivier on 1/15/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (custom)

+ (id)createBackButtonWithTarget:(id)target action:(SEL)action;
+ (id)createCheckButtonWithTarget:(id)target action:(SEL)action;
+ (id)createCloseButtonWithTarget:(id)target action:(SEL)action;
+ (id)createSearchButtonWithTarget:(id)target action:(SEL)action;

@end
