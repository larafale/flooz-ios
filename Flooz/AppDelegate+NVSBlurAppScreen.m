//
//  AppDelegate+NVSBlurAppScreen.m
//  BlurInactiveScreen-Objective C
//
//  Created by Nikolay Shubenkov on 21/05/15.
//  Copyright (c) 2015 Nikolay Shubenkov. All rights reserved.
//

#import "AppDelegate+NVSBlurAppScreen.h"
#import "CreditCardViewController.h"
#import "CashinCreditCardViewController.h"

static const int kNVSBlurViewTag = 198490;

@implementation AppDelegate (NVSBlurAppScreen)

#pragma mark - Public

- (void)nvs_blurPresentedView
{
    if ([self.window viewWithTag:kNVSBlurViewTag]){
        return;
    }
    
    UIViewController *vc = [self myTopViewController];
    
    
    if ([vc isKindOfClass:[FLTabBarController class]]) {
        vc = [((FLTabBarController *)vc) selectedViewController];
    }
    
    if ([vc isKindOfClass:[FLNavigationController class]]) {
        UIViewController *current = [(FLNavigationController*)vc topViewController];
        if ([current isKindOfClass:[CreditCardViewController class]] || [current isKindOfClass:[CashinCreditCardViewController class]]) {
            [[self window] endEditing:YES];
            
            [self.window addSubview:[self p_blurView]];
        }
    } else if ([vc isKindOfClass:[CreditCardViewController class]] || [vc isKindOfClass:[CashinCreditCardViewController class]]) {
        [[self window] endEditing:YES];
        
        [self.window addSubview:[self p_blurView]];
    }
}

- (void)nvs_unblurPresentedView
{
    [[self window] endEditing:NO];
    
    [[self.window viewWithTag:kNVSBlurViewTag] removeFromSuperview];
}

#pragma mark - Private

- (UIView *)p_blurView
{
    UIView *snapshot = [self.window snapshotViewAfterScreenUpdates:NO];
    
    UIView *blurView = nil;
    if ([UIVisualEffectView class]){
        UIVisualEffectView *aView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        blurView        = aView;
        blurView.frame  = snapshot.bounds;
        [snapshot addSubview:aView];
    }
    else {
        UIToolbar *toolBar  = [[UIToolbar alloc] initWithFrame:snapshot.bounds];
        toolBar.barStyle    = UIBarStyleBlackTranslucent;
        [snapshot addSubview:toolBar];
    }
    
    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(50, PPScreenHeight() / 2 - 100, PPScreenWidth() - 100, 200)];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.image = [UIImage imageNamed:@"home-title"];
    
    [snapshot addSubview:logo];
    
    snapshot.tag = kNVSBlurViewTag;
    return snapshot;
}

@end
