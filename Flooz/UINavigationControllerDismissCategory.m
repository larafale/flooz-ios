//
//  UINavigationControllerDismissCategory.m
//  Flooz
//
//  Created by Gawen Berger on 19/07/2017.
//  Copyright © 2017 Flooz. All rights reserved.
//

#import "UINavigationControllerDismissCategory.h"

@implementation UINavigationController (DismissCategory)

- (UIViewController *)findFirstViewControllerOfClass:(Class)cClass
{
  UIViewController *foundedController = nil;
  for (int i = [self.viewControllers count] - 1 ; i >= 0 ; i--)
  {
    id controller = self.viewControllers[i];
    if ([controller isKindOfClass:cClass]) {
      foundedController = controller;
      break;
    }
  }
  
  return foundedController;
}

- (UIViewController *)climbVCStacksAndPopToFirstControllerOfClass:(Class)cClass animated:(BOOL)animated
{

  UIViewController *result = [self findFirstViewControllerOfClass:cClass];
  if (result != nil) {
    [result.presentedViewController dismissViewControllerAnimated:animated completion:^{}];
    return result;
  }
  
  UIViewController *presentingVC = self.presentingViewController;
  if (presentingVC != nil && [presentingVC isKindOfClass:[UINavigationController class]]) {
    return [((UINavigationController *)presentingVC)
            climbVCStacksAndPopToFirstControllerOfClass:cClass animated:animated];
  }
  return nil;
}

@end
