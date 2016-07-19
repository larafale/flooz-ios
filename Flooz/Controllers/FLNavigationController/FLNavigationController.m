//
//  FLNavigationController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLNavigationController.h"
#import "FLPopupInformation.h"
#import "UserViewController.h"
#import "3DSecureViewController.h"
#import "GlobalViewController.h"
#import "FLTabBarController.h"
#import "TransactionViewController.h"
#import "CollectViewController.h"

@interface FLNavigationController () {
    UIBarButtonItem *backItem;
    UIBarButtonItem *closeItem;
    
    UIViewController *controller;
}

@property (nonatomic, strong) dispatch_block_t completionBlock;

@end

@implementation FLNavigationController

@synthesize shadowImage;
@synthesize completionBlock;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    self.blockAmount = NO;
    [self customAppearence];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customAppearence {
    [self.navigationBar setBarTintColor:[UIColor customBackgroundHeader]];
    self.navigationBar.translucent = NO;
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor customBlue],
                                 NSFontAttributeName: [UIFont customTitleNav]
                                 };
    
    [self.navigationBar setTitleTextAttributes:attributes];
    
    backItem = [UIBarButtonItem createBackButtonWithTarget:self action:@selector(popViewController)];
    closeItem = [UIBarButtonItem createCloseButtonWithTarget:self action:@selector(dismiss)];
    
    [self.navigationBar setBackgroundImage:[UIImage new]
                            forBarPosition:UIBarPositionAny
                                barMetrics:UIBarMetricsDefault];
    
    shadowImage = self.navigationBar.shadowImage;
    
    [self.navigationBar setShadowImage:[UIImage new]];
    
    [self showShadow];
}

- (void)showShadow {
    self.navigationBar.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:.2];
    self.navigationBar.layer.shadowOpacity = .3;
    self.navigationBar.layer.shadowOffset = CGSizeMake(0, 2);
    self.navigationBar.layer.shadowRadius = 1;
    self.navigationBar.clipsToBounds = NO;
}

- (void)hideShadow {
    self.navigationBar.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:.2];
    self.navigationBar.layer.shadowOffset = CGSizeMake(0, 0);
    self.navigationBar.layer.shadowRadius = 0;
    self.navigationBar.clipsToBounds = NO;
}

- (NSArray<UIViewController *> * _Nullable)popToRootViewControllerAnimated:(BOOL)animated {
    if ([self.viewControllers[0] isKindOfClass:[UserViewController class]]) {
        [self setNavigationBarHidden:YES animated:YES];
    } else
        [self setNavigationBarHidden:NO animated:YES];
    
    return [super popToRootViewControllerAnimated:animated];
}

- (void)popViewController {
    [self popViewControllerAnimated:YES];
}

- (void)pushViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated completion:(dispatch_block_t)completion {
    if (completion)
        completionBlock = [completion copy];
    
    [self pushViewController:viewController animated:animated];
}

- (void)popViewControllerAnimated:(BOOL)animated completion:(dispatch_block_t)completion {
    if (completion)
        completionBlock = [completion copy];
    
    [self popViewControllerAnimated:animated];
}

- (void)dismiss {
    [self.view endEditing:YES];
    
    if ([self.topViewController isKindOfClass:[Secure3DViewController class]]) {
        [[Flooz sharedInstance] abort3DSecure];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma marks - UINavigationControllerDelegate

- (void)navigationController:(nonnull UINavigationController *)navigationController didShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated {
    //    if (![viewController isKindOfClass:[UserViewController class]]) {
    //        for (UIGestureRecognizer *gesture in viewController.view.gestureRecognizers) {
    //            if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
    //                [viewController.view removeGestureRecognizer:gesture];
    //            }
    //        }
    //    }
    //
    if (completionBlock) {
        dispatch_block_t tmp = [completionBlock copy];
        completionBlock = nil;
        tmp();
    }
    
    if (_navigationDelegate)
        [_navigationDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.view endEditing:YES];
    
    if ([viewController isKindOfClass:[GlobalViewController class]]) {
        if ([((GlobalViewController *)viewController) hideNavShadow]) {
            [self hideShadow];
        } else {
            [self showShadow];
        }
    } else
        [self showShadow];
    
    controller = viewController;
    
    if (_navigationDelegate)
        [_navigationDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    
    if ([viewController isKindOfClass:[UserViewController class]] && [self isNavigationBarHidden] == NO)
        [self  setNavigationBarHidden:YES animated:YES];
    else if (![viewController isKindOfClass:[UserViewController class]] && [self isNavigationBarHidden] == YES)
        [self setNavigationBarHidden:NO animated:YES];
    
    if ([viewController isKindOfClass:[GlobalViewController class]]) {
        GlobalViewController *gvc = (GlobalViewController *)controller;
        
        if (gvc.triggerData && gvc.triggerData[@"close"] && [gvc.triggerData[@"close"] boolValue] == NO)
            return;
    }
    
    if (navigationController.viewControllers.count == 1 && !navigationController.parentViewController) {
        viewController.navigationItem.leftBarButtonItem = closeItem;
    }
    else if (!navigationController.parentViewController) {
        viewController.navigationItem.leftBarButtonItem = backItem;
    }
    
    if (self.parentViewController && [self.parentViewController isKindOfClass:[FLTabBarController class]]) {
        if ([viewController isKindOfClass:TransactionViewController.class] || [viewController isKindOfClass:CollectViewController.class]) {
            [((FLTabBarController*)self.parentViewController) setTabBarVisible:NO animated:YES completion:nil];
        } else {
            [((FLTabBarController*)self.parentViewController) setTabBarVisible:YES animated:YES completion:nil];
        }
    }
}

//- (id<UIViewControllerAnimatedTransitioning>) navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
//
//    if ([toVC isKindOfClass:[UserViewController class]] || [fromVC isKindOfClass:[UserViewController class]]) {
//        [_interactionController wireToViewController:toVC forOperation:CEInteractionOperationPop];
//        _interactionController.popOnRightToLeft = NO;
//
//        _animationController.reverse = operation == UINavigationControllerOperationPop;
//
//        return _animationController;
//    }
//    return nil;
//}
//
//- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
//    if (animationController && [animationController isEqual:_animationController])
//        return _interactionController.interactionInProgress ? _interactionController : nil;
//    else
//        return nil;
//}

@end
