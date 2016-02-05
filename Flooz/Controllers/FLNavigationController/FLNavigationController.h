//
//  FLNavigationController.h
//  Flooz
//
//  Created by Arnaud on 2014-10-14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLNavigationController : UINavigationController <UINavigationControllerDelegate>

@property (nonatomic) id<UINavigationControllerDelegate> navigationDelegate;

@property (nonatomic) BOOL blockBack;
@property (nonatomic) BOOL blockAmount;
@property (nonatomic) UIImage *shadowImage;

- (void)showShadow;
- (void)hideShadow;

- (void)pushViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated completion:(dispatch_block_t)completion;
- (void)popViewControllerAnimated:(BOOL)animated completion:(dispatch_block_t)completion;

@end
