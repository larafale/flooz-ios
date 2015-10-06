//
//  FLNavigationController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLNavigationController.h"
#import "NewTransactionViewController.h"
#import "FLPopupInformation.h"
#import "UserViewController.h"

@interface FLNavigationController () {
    UIBarButtonItem *backItem;
    UIBarButtonItem *closeItem;
    UIBarButtonItem *amountItem;
    UIBarButtonItem *cbItem;
    
    UIViewController *controller;
}

@end

@implementation FLNavigationController

@synthesize shadowImage;

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
    
    NSDictionary *attributes2 = @{
                                  NSForegroundColorAttributeName: [UIColor customBlue],
                                  NSFontAttributeName: [UIFont customTitleExtraLight:15]
                                  };
    
    [self.navigationBar setTitleTextAttributes:attributes];
    
    backItem = [UIBarButtonItem createBackButtonWithTarget:self action:@selector(popViewController)];
    closeItem = [UIBarButtonItem createCloseButtonWithTarget:self action:@selector(dismiss)];
    
    amountItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%.2f €", [[[Flooz sharedInstance] currentUser].amount floatValue]] style:UIBarButtonItemStylePlain target:self action:@selector(amountInfos)];
    [amountItem setTitleTextAttributes:attributes2 forState:UIControlStateNormal];
    
    UIImage *cbImage = [UIImage imageNamed:@"picto-cb"];
    CGSize newImgSize = CGSizeMake(30, 20);
    
    UIGraphicsBeginImageContextWithOptions(newImgSize, NO, 0.0);
    [cbImage drawInRect:CGRectMake(0, 0, newImgSize.width, newImgSize.height)];
    cbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cbItem = [[UIBarButtonItem alloc] initWithImage:cbImage style:UIBarButtonItemStylePlain target:self action:@selector(amountInfos)];
    [cbItem setTintColor:[UIColor customBlue]];
    
    
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

- (void)amountInfos {
    [self.view endEditing:YES];
    [self.view endEditing:NO];
    
    UIImage *cbImage = [UIImage imageNamed:@"picto-cb"];
    CGSize newImgSize = CGSizeMake(20, 14);
    
    UIGraphicsBeginImageContextWithOptions(newImgSize, NO, 0.0);
    [cbImage drawInRect:CGRectMake(0, 0, newImgSize.width, newImgSize.height)];
    cbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = cbImage;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_1", nil)];
    [string appendAttributedString:attachmentString];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_2", nil)]];
    
    [[[FLPopupInformation alloc] initWithTitle:NSLocalizedString(@"WALLET_INFOS_TITLE", nil) andMessage:string ok:nil] show];
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

- (void)dismiss {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setAmountHidden:(BOOL)hidden {
    self.blockAmount = hidden;
    
    if ([controller isKindOfClass:[NewTransactionViewController class]]) {
        if (self.blockAmount)
            controller.navigationItem.rightBarButtonItem = nil;
        else {
            if ([[Flooz sharedInstance].currentUser.amount isEqualToNumber:@0])
                controller.navigationItem.rightBarButtonItem = cbItem;
            else
                controller.navigationItem.rightBarButtonItem = amountItem;
        }
    }
}

- (void)setAmount:(NSNumber *)amount {
    NSNumber *balance = [Flooz sharedInstance].currentUser.amount;
    
    float tmp = [balance floatValue] - [amount floatValue];
    
    if (tmp < 0) {
        controller.navigationItem.rightBarButtonItem = cbItem;
    }
    else {
        [amountItem setTitle:[FLHelper formatedAmount:@(tmp) withSymbol:NO]];
        
        if (controller.navigationItem.rightBarButtonItem != amountItem)
            controller.navigationItem.rightBarButtonItem = amountItem;
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
    if (_navigationDelegate)
        [_navigationDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.view endEditing:YES];
    
    [self showShadow];
    
    controller = viewController;
    
    if (!self.blockBack) {
        if (navigationController.viewControllers.count == 1 && !navigationController.parentViewController) {
            viewController.navigationItem.leftBarButtonItem = closeItem;
        }
        else if (!navigationController.parentViewController) {
            viewController.navigationItem.leftBarButtonItem = backItem;
        }
        else
            viewController.navigationItem.leftBarButtonItem = nil;
    }
    else
        viewController.navigationItem.leftBarButtonItem = nil;
    
    
    if (_navigationDelegate)
        [_navigationDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    
    if ([viewController isKindOfClass:[UserViewController class]] && [self isNavigationBarHidden] == NO)
        [self  setNavigationBarHidden:YES animated:YES];
    else if (![viewController isKindOfClass:[UserViewController class]] && [self isNavigationBarHidden] == YES)
        [self setNavigationBarHidden:NO animated:YES];
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
