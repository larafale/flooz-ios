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
#import "FXBlurView.h"
#import "FLTabBarController.h"
#import "NewCollectController.h"

@interface UITabBarController (private)
- (UITabBar *)tabBar;
@end

@interface FLTabBarController()<LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate> {
    UITabBarItem *homeItem;
    UITabBarItem *notifItem;
    UITabBarItem *floozItem;
    UITabBarItem *thirdItem;
    UITabBarItem *profileItem;
    
    LiquidFloatingActionButton *homeButton;
    FXBlurView *homeButtonOverlay;
    NSArray *homeSubButtons;
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
    
    thirdItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"TAB_BAR_SHARE", nil) image:[FLHelper imageWithImage:[UIImage imageNamed:@"menu-share"] scaledToSize:iconSize] tag:3];
    thirdNavigationController = [[FLNavigationController alloc] initWithRootViewController:[ShareAppViewController new]];
    
    [[Flooz sharedInstance] invitationText:^(FLInvitationTexts *result) {
        [thirdItem setTitle:result.shareTitle];
    } failure:^(NSError *error) {
        
    }];
    
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
    
    [self addHomeButton];
    
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

-(void) addHomeButton
{
    homeButtonOverlay = [[FXBlurView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight())];
    [homeButtonOverlay setDynamic:NO];
    [homeButtonOverlay setBlurRadius:10];
    [homeButtonOverlay setTintColor:[UIColor clearColor]];
    [homeButtonOverlay setHidden:YES];
    [homeButtonOverlay setUserInteractionEnabled:false];
    [homeButtonOverlay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHomeButtonOverlayClick)]];
    
    homeButton = [[LiquidFloatingActionButton alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetHeight(self.tabBar.frame) + 15.0f, CGRectGetHeight(self.tabBar.frame) + 15.0f)];
    homeButton.delegate = self;
    homeButton.dataSource = self;
    homeButton.openDuration = 0.4;
    homeButton.closeDuration = 0.3;
    homeButton.viscosity = 0.75;
    homeButton.color = [UIColor customBlue];
    homeButton.cellRadiusRatio = 0.52;
    homeButton.userInteractionEnabled = YES;
    homeButton.center = self.tabBar.center;
    
    [homeButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [homeButton.layer setShadowOpacity:.6];
    [homeButton.layer setShadowRadius:1.0];
    [homeButton.layer setShadowOffset:CGSizeMake(0.0, -2.0)];
    [homeButton.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:homeButton.bounds cornerRadius:(CGRectGetHeight(self.tabBar.frame) + 10.0f) * 0.5].CGPath];
    
    CGRectSetY(homeButton.frame, CGRectGetHeight(self.view.frame) - CGRectGetHeight(homeButton.frame) - 3.0f);
    
    [self.view addSubview:homeButtonOverlay];
    
    [self.view addSubview:homeButton];
    
    homeSubButtons = @[[self createHomeSubButton:@"Floozer" color:[UIColor customRed]],
                       [self createHomeSubButton:@"Réclamer" color:[UIColor customGreen]],
                       [self createHomeSubButton:@"Cagnotte" color:[UIColor customPink]]];
}

- (LiquidFloatingCell *) createHomeSubButton:(NSString *)content color:(UIColor *)color {
    UILabel *label = [UILabel new];
    [label setFont:[UIFont customContentRegular:16]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:content];
    [label setNumberOfLines:1];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setAdjustsFontSizeToFitWidth:YES];
    [label setMinimumScaleFactor:10. / label.font.pointSize];
    [label setUserInteractionEnabled:YES];
    
    LiquidFloatingCell *cell = [[LiquidFloatingCell alloc] initWithView:label];
    cell.internalRatio = 0.5;
    cell.color = color;
    cell.userInteractionEnabled = YES;
    
    return cell;
}

- (void)openNewFlooz {
    [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:NO completionHandler:nil];
    
    NSDictionary *ux = [[[Flooz sharedInstance] currentUser] ux];
    if (ux && ux[@"homeButton"] && [ux[@"homeButton"] count] > 0) {
        [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:ux[@"homeButton"]]];
    } else {
        NewTransactionViewController *newTransac = [[NewTransactionViewController alloc] initWithTransactionType:TransactionTypeBase];
        
        FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:newTransac];
        controller.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [homeButtonOverlay updateAsynchronously:YES completion:nil];
    if ([viewController isEqual:[self.viewControllers objectAtIndex:2]]) {
        [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:NO completionHandler:nil];
        
        NSDictionary *ux = [[[Flooz sharedInstance] currentUser] ux];
        if (ux && ux[@"homeButton"] && [ux[@"homeButton"] count] > 0) {
            [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:ux[@"homeButton"]]];
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

- (void)liquidFloatingActionButtonAnimate:(LiquidFloatingActionButton *)liquidFloatingActionButton {
    [homeButtonOverlay updateAsynchronously:YES completion:nil];
    [homeButtonOverlay setHidden:NO];
    [homeButtonOverlay setAlpha:0.0f];
    [UIView animateWithDuration:homeButton.openDuration animations:^{
        [homeButtonOverlay setUserInteractionEnabled:YES];
        [homeButtonOverlay setAlpha:1.0f];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)liquidFloatingActionButtonClose:(LiquidFloatingActionButton *)liquidFloatingActionButton {
    [homeButtonOverlay setUserInteractionEnabled:NO];
    
    [UIView animateWithDuration:homeButton.openDuration animations:^{
        [homeButtonOverlay setUserInteractionEnabled:YES];
        [homeButtonOverlay setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [homeButtonOverlay setHidden:YES];
    }];
}

- (LiquidFloatingCell *)cellForIndex:(NSInteger)index {
    return homeSubButtons[index];
}

- (NSInteger)numberOfCells:(LiquidFloatingActionButton *)liquidFloatingActionButton {
    return homeSubButtons.count;
}

- (void)liquidFloatingActionButton:(LiquidFloatingActionButton *)liquidFloatingActionButton didSelectItemAtIndex:(NSInteger)index {
    [liquidFloatingActionButton close];
    switch (index) {
        case 0:
        {
            NewTransactionViewController *newTransac = [[NewTransactionViewController alloc] initWithTransactionType:TransactionTypePayment];
            
            FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:newTransac];
            controller.modalPresentationStyle = UIModalPresentationCustom;
            
            [self presentViewController:controller animated:YES completion:NULL];
        }
            break;
        case 1:
        {
            NewTransactionViewController *newTransac = [[NewTransactionViewController alloc] initWithTransactionType:TransactionTypeCharge];
            
            FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:newTransac];
            controller.modalPresentationStyle = UIModalPresentationCustom;
            
            [self presentViewController:controller animated:YES completion:NULL];
        }
            break;
        case 2:
        {
            NewCollectController *newTransac = [NewCollectController new];
            
            FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:newTransac];
            controller.modalPresentationStyle = UIModalPresentationCustom;
            
            [self presentViewController:controller animated:YES completion:NULL];
        }
            break;
        default:
            break;
    }
}

- (void)didHomeButtonOverlayClick {
    if (!homeButton.isClosed) {
        [homeButton close];
    }
}

- (void)reloadBadge {
    NSNumber *numberNotif = [[Flooz sharedInstance] notificationsCount];
    
    [notifItem setCustomBadgeValue:[numberNotif stringValue] withFont:[UIFont customContentRegular:12] andFontColor:[UIColor whiteColor] andBackgroundColor:[UIColor customBlue]];
    
    if ([numberNotif intValue] == 0)
        [notifItem setCustomBadgeValue:nil withFont:[UIFont customContentRegular:12] andFontColor:[UIColor whiteColor] andBackgroundColor:[UIColor customBlue]];
}

// pass a param to describe the state change, an animated flag and a completion block matching UIView animations completion
- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
    
    // get a frame calculation ready
    CGFloat height = self.tabBar.frame.size.height;
    CGFloat offsetY = (visible)? -height : height;
    
    CGFloat heightButton = homeButton.frame.size.height + 6;
    CGFloat offsetYButton = (visible)? -heightButton : heightButton;
    
    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;
    
    if (visible) {
        self.tabBar.hidden = NO;
        self.tabBar.userInteractionEnabled = YES;
        homeButton.hidden = NO;
        homeButton.userInteractionEnabled = YES;
    }
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBar.frame = CGRectOffset(self.tabBar.frame, 0, offsetY);
        homeButton.frame = CGRectOffset(homeButton.frame, 0, offsetYButton);
    } completion:^(BOOL finished) {
        if (!visible) {
            self.tabBar.hidden = YES;
            self.tabBar.userInteractionEnabled = NO;
            homeButton.hidden = YES;
            homeButton.userInteractionEnabled = NO;
        }
        
        if (completion)
            completion(finished);
    }];
}

// know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

@end
