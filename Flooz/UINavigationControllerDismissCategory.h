//
//  UINavigationControllerDismissCategory.h
//  Flooz
//
//  Created by Gawen Berger on 19/07/2017.
//  Copyright © 2017 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (DismissCategory)

- (UIViewController*)climbVCStacksAndPopToFirstControllerOfClass:(Class)cClass animated:(BOOL)animated;
- (UIViewController *)findFirstViewControllerOfClass:(Class)cClass;

@end
