//
//  FLTabBarController.m
//  Flooz
//
//  Created by Epitech on 7/9/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import "TimelineViewController.h"
#import "NotificationsViewController.h"
#import "NewTransactionViewController.h"
#import "FriendsViewController.h"
#import "AccountViewController.h"

#import "FLTabBarController.h"

@interface UITabBarController (private)
- (UITabBar *)tabBar;
@end

@interface FLTabBarController () {
    UITabBarItem *homeItem;
    UITabBarItem *notifItem;
    UITabBarItem *floozItem;
    UITabBarItem *friendsItem;
    UITabBarItem *profileItem;
}

@end

@implementation FLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setDelegate:self];
    
    [self.tabBar setBarStyle:UIBarStyleDefault];
    [self.tabBar setBarTintColor:[UIColor customBackgroundHeader]];
    
    [[UITabBarItem appearance] setTitleTextAttributes: @{NSFontAttributeName: [UIFont customContentRegular:10]} forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont customContentRegular:10]} forState:UIControlStateSelected];
    
    NSMutableArray *tabBarItems = [NSMutableArray new];
    
    homeItem = [[UITabBarItem alloc] initWithTitle:@"Accueil" image:[UIImage imageNamed:@"menu-home"] tag:0];
    notifItem = [[UITabBarItem alloc] initWithTitle:@"Notifs" image:[UIImage imageNamed:@"menu-notifications"] tag:1];
    floozItem = [[UITabBarItem alloc] initWithTitle:nil image:[UIImage imageNamed:@"friends-field-add"] tag:2];
    friendsItem = [[UITabBarItem alloc] initWithTitle:@"Amis" image:[UIImage imageNamed:@"menu-friends"] tag:3];
    profileItem = [[UITabBarItem alloc] initWithTitle:@"Compte" image:[UIImage imageNamed:@"menu-account"] tag:4];
    
    FLNavigationController *homeNavigationController = [[FLNavigationController alloc] initWithRootViewController:[TimelineViewController new]];
    FLNavigationController *notifNavigationController = [[FLNavigationController alloc] initWithRootViewController:[NotificationsViewController new]];
    FLNavigationController *floozNavigationController = [[FLNavigationController alloc] initWithRootViewController:[UIViewController new]];
    FLNavigationController *friendsNavigationController = [[FLNavigationController alloc] initWithRootViewController:[FriendsViewController new]];
    FLNavigationController *profileNavigationController = [[FLNavigationController alloc] initWithRootViewController:[AccountViewController new]];
    
    int offset = 7;
    UIEdgeInsets imageInset = UIEdgeInsetsMake(offset, 0, -offset, 0);
    floozItem.imageInsets = imageInset;
    
    [[homeNavigationController.viewControllers objectAtIndex:0] setTabBarItem:homeItem];
    [[notifNavigationController.viewControllers objectAtIndex:0] setTabBarItem:notifItem];
    [[floozNavigationController.viewControllers objectAtIndex:0] setTabBarItem:floozItem];
    [[friendsNavigationController.viewControllers objectAtIndex:0] setTabBarItem:friendsItem];
    [[profileNavigationController.viewControllers objectAtIndex:0] setTabBarItem:profileItem];
    
    [tabBarItems addObject:homeNavigationController];
    [tabBarItems addObject:notifNavigationController];
    [tabBarItems addObject:floozNavigationController];
    [tabBarItems addObject:friendsNavigationController];
    [tabBarItems addObject:profileNavigationController];
    
    [self setViewControllers:tabBarItems];
    
    [self setSelectedIndex:0];

    [self registerNotification:@selector(reloadBadge) name:@"newNotifications" object:nil];
    
    [self reloadBadge];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
