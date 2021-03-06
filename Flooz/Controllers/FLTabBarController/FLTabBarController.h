//
//  FLTabBarController.h
//  Flooz
//
//  Created by Flooz on 7/9/15.
//  Copyright (c) 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTabBarController : UITabBarController<UITabBarControllerDelegate, UINavigationControllerDelegate>

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion;
- (BOOL)tabBarIsVisible;

@end
