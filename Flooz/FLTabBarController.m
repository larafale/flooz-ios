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
#import "SDWebImageDownloader.h"
#import "UserViewController.h"
#import "DealViewController.h"

#import "UITabBarItem+CustomBadge.h"

#import "FLTabBarController.h"

@interface UITabBarController (private)
- (UITabBar *)tabBar;
@end

@interface FLTabBarController () {
    UITabBarItem *homeItem;
    UITabBarItem *notifItem;
    UITabBarItem *floozItem;
    UITabBarItem *thirdItem;
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
    
    CGSize iconSize = CGSizeMake(30, 30);
    
    homeItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_HOME", nil) image:[FLHelper imageWithImage:[UIImage imageNamed:@"menu-home"] scaledToSize:iconSize] tag:0];
    notifItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_NOTIFICATIONS", nil) image:[FLHelper imageWithImage:[UIImage imageNamed:@"menu-notifications"] scaledToSize:iconSize] tag:1];
    floozItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage new] tag:2];
    profileItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_ACCOUNT", nil) image:[FLHelper imageWithImage:[UIImage imageNamed:@"menu-account"] scaledToSize:iconSize] tag:4];
    
    FLNavigationController *thirdNavigationController;
    
//    NSDictionary *ux = [[[Flooz sharedInstance] currentUser] ux];
//    if (ux && ux[@"deals"] && [ux[@"deals"] boolValue]) {
//        thirdItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_DEALS", nil) image:[FLHelper imageWithImage:[UIImage imageNamed:@"menu-deals"] scaledToSize:iconSize] tag:3];
//        thirdNavigationController = [[FLNavigationController alloc] initWithRootViewController:[DealViewController new]];
//    } else {
        thirdItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_SHARE", nil) image:[FLHelper imageWithImage:[UIImage imageNamed:@"menu-share"] scaledToSize:iconSize] tag:3];
        thirdNavigationController = [[FLNavigationController alloc] initWithRootViewController:[ShareAppViewController new]];

        [[Flooz sharedInstance] invitationText:^(FLInvitationTexts *result) {
            [thirdItem setTitle:result.shareTitle];
        } failure:^(NSError *error) {
            
        }];
//    }
    
    FLNavigationController *homeNavigationController = [[FLNavigationController alloc] initWithRootViewController:[TimelineViewController new]];
    FLNavigationController *notifNavigationController = [[FLNavigationController alloc] initWithRootViewController:[NotificationsViewController new]];
    FLNavigationController *floozNavigationController = [[FLNavigationController alloc] initWithRootViewController:[UIViewController new]];
    
    FLNavigationController *profileNavigationController = [[FLNavigationController alloc] initWithRootViewController:[[UserViewController alloc] initWithUser:[Flooz sharedInstance].currentUser]];
    
    [[homeNavigationController.viewControllers objectAtIndex:0] setTabBarItem:homeItem];
    [[notifNavigationController.viewControllers objectAtIndex:0] setTabBarItem:notifItem];
    [[floozNavigationController.viewControllers objectAtIndex:0] setTabBarItem:floozItem];
    [[thirdNavigationController.viewControllers objectAtIndex:0] setTabBarItem:thirdItem];
    [[profileNavigationController.viewControllers objectAtIndex:0] setTabBarItem:profileItem];
    
    [tabBarItems addObject:homeNavigationController];
    [tabBarItems addObject:notifNavigationController];
    [tabBarItems addObject:floozNavigationController];
    [tabBarItems addObject:thirdNavigationController];
    [tabBarItems addObject:profileNavigationController];
    
    [self setViewControllers:tabBarItems];
    
    [self setSelectedIndex:0];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.tabBar.bounds];
    
    self.tabBar.layer.shadowOpacity = .3;
    self.tabBar.layer.shadowOffset = CGSizeMake(0, -2);
    self.tabBar.layer.shadowRadius = 1;
    self.tabBar.clipsToBounds = NO;
    self.tabBar.layer.shadowPath = shadowPath.CGPath;
    
    [self addCenterButtonWithImage:[FLHelper imageWithImage:[UIImage imageNamed:@"flooz-mini"] scaledToSize:CGSizeMake(35, 35)] highlightImage:nil];
    
    [self reloadBadge];
    [self reloadCurrentUser];
    
    [self registerNotification:@selector(reloadBadge) name:@"newNotifications" object:nil];
    [self registerNotification:@selector(reloadCurrentUser) name:kNotificationReloadCurrentUser object:nil];
    [self registerNotification:@selector(enterBackground) name:kNotificationEnterBackground object:nil];
    [self registerNotification:@selector(reloadShareTexts) name:kNotificationReloadShareTexts object:nil];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)enterBackground {
    for (FLNavigationController *controller in self.viewControllers) {
        if (controller != self.selectedViewController)
            [controller popToRootViewControllerAnimated:NO];
    }
}

- (void)reloadShareTexts {
    [thirdItem setTitle:[[Flooz sharedInstance] invitationTexts].shareTitle];
}

- (void)reloadCurrentUser {
    int accountNotifs = 0;
    
    FLUser *currentUser = [Flooz sharedInstance].currentUser;
    
    accountNotifs += [currentUser.metrics[@"accountMissing"] intValue];
    
    if (accountNotifs > 0)
        [profileItem setCustomBadgeValue:[@(accountNotifs) stringValue] withFont:[UIFont customContentRegular:12] andFontColor:[UIColor whiteColor] andBackgroundColor:[UIColor customBlue]];
    else
        [profileItem setCustomBadgeValue:nil withFont:[UIFont customContentRegular:12] andFontColor:[UIColor whiteColor] andBackgroundColor:[UIColor customBlue]];
}

-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    centerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    centerButton.contentMode = UIViewContentModeCenter;
    centerButton.frame = CGRectMake(0.0, 0.0, CGRectGetHeight(self.tabBar.frame) + 10.0f, CGRectGetHeight(self.tabBar.frame) + 10.0f);
    [centerButton setImage:buttonImage forState:UIControlStateNormal];
    [centerButton setImage:highlightImage forState:UIControlStateHighlighted];
    [centerButton setBackgroundColor:[UIColor customBackground]];
    centerButton.clipsToBounds = YES;
    centerButton.layer.masksToBounds = YES;
    centerButton.layer.cornerRadius = CGRectGetHeight(centerButton.frame) / 2;
    [centerButton addTarget:self action:@selector(openNewFlooz) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *container = [[UIView alloc] initWithFrame:centerButton.frame];
    container.backgroundColor = [UIColor clearColor];
    [container.layer setShadowColor:[UIColor blackColor].CGColor];
    [container.layer setShadowOpacity:.4];
    [container.layer setShadowRadius:1];
    [container.layer setShadowOffset:CGSizeMake(0.0, -2.0)];
    [container.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:container.bounds cornerRadius:centerButton.layer.cornerRadius].CGPath];
    container.center = self.tabBar.center;

    CGRectSetY(container.frame, CGRectGetHeight(self.view.frame) - CGRectGetHeight(container.frame) - 3.0f);
    
    [container addSubview:centerButton];
    
    [self.view addSubview:container];
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
    
    [notifItem setCustomBadgeValue:[numberNotif stringValue] withFont:[UIFont customContentRegular:12] andFontColor:[UIColor whiteColor] andBackgroundColor:[UIColor customBlue]];
    
    if ([numberNotif intValue] == 0)
        [notifItem setCustomBadgeValue:nil withFont:[UIFont customContentRegular:12] andFontColor:[UIColor whiteColor] andBackgroundColor:[UIColor customBlue]];
}

@end
