//
//  FLTabBarController.m
//  Flooz
//
//  Created by Flooz on 7/9/15.
//  Copyright (c) 2015 Flooz. All rights reserved.
//

#import "TimelineViewController.h"
#import "NotificationsViewController.h"
#import "NewTransactionViewController.h"
#import "FriendsViewController.h"
#import "AccountViewController.h"
#import "ShareAppViewController.h"

#import "FLTabBarController.h"

@interface UITabBarController (private)
- (UITabBar *)tabBar;
@end

@interface FLTabBarController () {
    UITabBarItem *homeItem;
    UITabBarItem *notifItem;
    UITabBarItem *floozItem;
    UITabBarItem *shareItem;
    UITabBarItem *profileItem;
    UIButton *centerButton;
}

@end

@implementation FLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setDelegate:self];
    
    [self.tabBar setBarStyle:UIBarStyleDefault];
    [self.tabBar setBarTintColor:[UIColor customBackgroundHeader]];
    [self.tabBar setTranslucent:NO];
    [self.tabBar setBackgroundImage:[UIImage new]];
    [self.tabBar setShadowImage:[UIImage new]];
    
    [[UITabBarItem appearance] setTitleTextAttributes: @{NSFontAttributeName: [UIFont customContentRegular:12], NSForegroundColorAttributeName: [UIColor customPlaceholder]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont customContentRegular:12], NSForegroundColorAttributeName: [UIColor customBlue]} forState:UIControlStateSelected];
    
    NSMutableArray *tabBarItems = [NSMutableArray new];
    
    homeItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_HOME", nil) image:[UIImage imageNamed:@"menu-home"] tag:0];
    notifItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_NOTIFICATIONS", nil) image:[UIImage imageNamed:@"menu-notifications"] tag:1];
    floozItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage new] tag:2];
    shareItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_SHARE", nil) image:[UIImage imageNamed:@"menu-share"] tag:3];
    profileItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_ACCOUNT", nil) image:[UIImage imageNamed:@"menu-account"] tag:4];
    
    FLNavigationController *homeNavigationController = [[FLNavigationController alloc] initWithRootViewController:[TimelineViewController new]];
    FLNavigationController *notifNavigationController = [[FLNavigationController alloc] initWithRootViewController:[NotificationsViewController new]];
    FLNavigationController *floozNavigationController = [[FLNavigationController alloc] initWithRootViewController:[UIViewController new]];
    FLNavigationController *shareNavigationController = [[FLNavigationController alloc] initWithRootViewController:[ShareAppViewController new]];
    FLNavigationController *profileNavigationController = [[FLNavigationController alloc] initWithRootViewController:[AccountViewController new]];
    
    if ([[Flooz sharedInstance] invitationTexts]) {
        [shareItem setTitle:[[Flooz sharedInstance] invitationTexts].shareTitle];
    }
    
    [[Flooz sharedInstance] invitationText:^(FLInvitationTexts *result) {
        [shareItem setTitle:result.shareTitle];
    } failure:^(NSError *error) {
        
    }];
    
    [[homeNavigationController.viewControllers objectAtIndex:0] setTabBarItem:homeItem];
    [[notifNavigationController.viewControllers objectAtIndex:0] setTabBarItem:notifItem];
    [[floozNavigationController.viewControllers objectAtIndex:0] setTabBarItem:floozItem];
    [[shareNavigationController.viewControllers objectAtIndex:0] setTabBarItem:shareItem];
    [[profileNavigationController.viewControllers objectAtIndex:0] setTabBarItem:profileItem];
    
    [tabBarItems addObject:homeNavigationController];
    [tabBarItems addObject:notifNavigationController];
    [tabBarItems addObject:floozNavigationController];
    [tabBarItems addObject:shareNavigationController];
    [tabBarItems addObject:profileNavigationController];
    
    [self setViewControllers:tabBarItems];
    
    [self setSelectedIndex:0];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.tabBar.bounds];
    
    self.tabBar.layer.shadowOpacity = .3;
    self.tabBar.layer.shadowOffset = CGSizeMake(0, -2);
    self.tabBar.layer.shadowRadius = 1;
    self.tabBar.clipsToBounds = NO;
    self.tabBar.layer.shadowPath = shadowPath.CGPath;
    
    [self addCenterButtonWithImage:[UIImage imageNamed:@"add-flooz-plus"] highlightImage:nil];
    
    [self reloadBadge];
    [self reloadCurrentUser];
    
    [self registerNotification:@selector(reloadBadge) name:@"newNotifications" object:nil];
    [self registerNotification:@selector(reloadCurrentUser) name:kNotificationReloadCurrentUser object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadCurrentUser {
    int accountNotifs = 0;
    
    FLUser *currentUser = [Flooz sharedInstance].currentUser;
    
    accountNotifs += [currentUser.metrics[@"accountMissing"] intValue];
    
    if (accountNotifs > 0)
        [profileItem setBadgeValue:[@(accountNotifs) stringValue]];
    else
        [profileItem setBadgeValue:nil];
}

-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    centerButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    centerButton.contentMode = UIViewContentModeScaleAspectFit;
    centerButton.frame = CGRectMake(0.0, 0.0, 70.0f, 70.0f);
    [centerButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [centerButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [centerButton addTarget:self action:@selector(openNewFlooz) forControlEvents:UIControlEventTouchUpInside];
    centerButton.center = self.tabBar.center;
    
    CGRectSetY(centerButton.frame, CGRectGetMaxY(self.tabBar.frame) - CGRectGetHeight(centerButton.frame));
    
    [self.view addSubview:centerButton];
}

- (void)openNewFlooz {
    [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:NO completionHandler:nil];
    
    NSDictionary *ux = [[[Flooz sharedInstance] currentUser] ux];
    if (ux && ux[@"homeButton"] && [ux[@"homeButton"] count] > 0) {
        NSArray *triggers = ux[@"homeButton"];
        for (NSDictionary *triggerData in triggers) {
            FLTrigger *trigger = [[FLTrigger alloc] initWithJson:triggerData];
            [[Flooz sharedInstance] handleTrigger:trigger];
        }
    } else {
        NewTransactionViewController *newTransac = [[NewTransactionViewController alloc] initWithTransactionType:TransactionTypeBase];
        
        FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:newTransac];
        controller.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isEqual:[self.viewControllers objectAtIndex:2]]) {
        [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:NO completionHandler:nil];
        
        NSDictionary *ux = [[[Flooz sharedInstance] currentUser] ux];
        if (ux && ux[@"homeButton"] && [ux[@"homeButton"] count] > 0) {
            NSArray *triggers = ux[@"homeButton"];
            for (NSDictionary *triggerData in triggers) {
                FLTrigger *trigger = [[FLTrigger alloc] initWithJson:triggerData];
                [[Flooz sharedInstance] handleTrigger:trigger];
            }
        } else {
            NewTransactionViewController *newTransac = [[NewTransactionViewController alloc] initWithTransactionType:TransactionTypeBase];
            
            FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:newTransac];
            controller.modalPresentationStyle = UIModalPresentationCustom;
            
            [self presentViewController:controller animated:YES completion:NULL];
        }
        return NO;
    }
    
    return YES;
}

- (void)reloadBadge {
    NSNumber *numberNotif = [[Flooz sharedInstance] notificationsCount];
    [notifItem setBadgeValue:[numberNotif stringValue]];
    if ([numberNotif intValue] == 0)
        [notifItem setBadgeValue:nil];
}

@end
