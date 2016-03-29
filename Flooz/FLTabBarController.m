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

@interface FLTabBarController() {
    UITabBarItem *homeItem;
    UITabBarItem *notifItem;
    UITabBarItem *floozItem;
    UITabBarItem *thirdItem;
    UITabBarItem *profileItem;
    
    UIButton *homeButton;
    FXBlurView *homeButtonOverlay;
    
    UIView *homeSubview;
    UIView *homeSubButtonPay;
    UIView *homeSubButtonCollect;
    UIView *homeSubButtonShop;
    
    BOOL homeViewOpen;
}

@end

@implementation FLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    homeViewOpen = NO;
    
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
    [homeButtonOverlay setDynamic:YES];
    [homeButtonOverlay setBlurRadius:25];
    [homeButtonOverlay setTintColor:[UIColor blackColor]];
    [homeButtonOverlay setHidden:YES];
    [homeButtonOverlay setUserInteractionEnabled:false];
    [homeButtonOverlay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHomeButtonOverlayClick)]];
    
    homeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetHeight(self.tabBar.frame) + 15.0f, CGRectGetHeight(self.tabBar.frame) + 15.0f)];
    [homeButton setImage:[UIImage imageNamed:@"add-flooz-plus-white"] forState:UIControlStateNormal];
    homeButton.contentMode = UIViewContentModeScaleAspectFill;
    homeButton.center = self.tabBar.center;
    [homeButton addTarget:self action:@selector(didHomeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    CGRectSetY(homeButton.frame, CGRectGetHeight(self.view.frame) - CGRectGetHeight(homeButton.frame) - 3.0f);
    
    [self.view addSubview:homeButtonOverlay];
    
    homeSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];

    UILabel *overlayTitle = [[UILabel alloc] initWithText:@"Choisissez une option" textColor:[UIColor customBlue] font:[UIFont customContentBold:25] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    CGRectSetXY(overlayTitle.frame, 20, 50);
    CGRectSetWidth(overlayTitle.frame, PPScreenWidth() - 40);
    
    [homeButtonOverlay addSubview:overlayTitle];
    
    homeSubButtonShop = [[UIView alloc] initWithFrame:CGRectMake(10, 0, PPScreenWidth() - 20, 80)];
    homeSubButtonShop.userInteractionEnabled = YES;
    [homeSubButtonShop addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHomeSubShopClick)]];
    
    [self fillHomeSubButton:homeSubButtonShop image:[UIImage imageNamed:@"home-sub-collect"] title:@"Faire du shopping" subtitle:@"Payez avec Flooz sur Amazon, iTunes, Netflix ou chez l'un de nos partenaires" available:NO];

    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(homeSubButtonShop.frame) + 10, PPScreenWidth() - 100, 1)];
//    separator.backgroundColor = [UIColor customSeparator];
    
    homeSubButtonCollect = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(separator.frame) + 10, PPScreenWidth() - 20, 80)];
    homeSubButtonCollect.userInteractionEnabled = YES;
    [homeSubButtonCollect addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHomeSubCollectClick)]];

    [self fillHomeSubButton:homeSubButtonCollect image:[UIImage imageNamed:@"home-sub-collect"] title:@"Créer une cagnotte" subtitle:@"Collectez de l'argent pour un anniv, un week-end ou un pot de départ" available:TRUE];

    UIView *separator2 = [[UIView alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(homeSubButtonCollect.frame) + 10, PPScreenWidth() - 100, 1)];
//    separator2.backgroundColor = [UIColor customSeparator];

    homeSubButtonPay = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(separator2.frame) + 10, PPScreenWidth() - 20, 80)];
    homeSubButtonPay.userInteractionEnabled = YES;
    [homeSubButtonPay addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHomeSubPayClick)]];

    [self fillHomeSubButton:homeSubButtonPay image:[UIImage imageNamed:@"home-sub-pay"] title:@"Payer ou rembourser" subtitle:@"Simplifiez vos échanges d'argent entre amis !" available:TRUE];
    
    [homeSubview addSubview:homeSubButtonShop];
    [homeSubview addSubview:homeSubButtonCollect];
    [homeSubview addSubview:homeSubButtonPay];
    [homeSubview addSubview:separator];
    [homeSubview addSubview:separator2];
    
    CGRectSetHeight(homeSubview.frame, CGRectGetMaxY(homeSubButtonPay.frame));
    CGRectSetY(homeSubview.frame, PPScreenHeight() / 2 + 100);
    
    [homeButtonOverlay addSubview:homeSubview];
    
    [self.view addSubview:homeButton];
}

- (void)fillHomeSubButton:(UIView *)button image:(UIImage*)image title:(NSString *)title subtitle:(NSString *)subtitle available:(BOOL)available {
    button.backgroundColor = [UIColor customBackground:0.6];
    button.layer.cornerRadius = 5;
    
    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(button.frame) / 2 - 25, 50, 50)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tintColor = [UIColor customBlue];
    imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 15, 10, CGRectGetWidth(button.frame) - CGRectGetMaxX(imageView.frame) - 45, 25)];
    titleLabel.font = [UIFont customContentRegular:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = title;
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 10. / titleLabel.font.pointSize;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 15, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(button.frame) - CGRectGetMaxX(imageView.frame) - 45, 35)];
    subtitleLabel.font = [UIFont customContentRegular:13];
    subtitleLabel.textColor = [UIColor customPlaceholder];
    subtitleLabel.text = subtitle;
    subtitleLabel.numberOfLines = 2;
    subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    subtitleLabel.adjustsFontSizeToFitWidth = YES;
    subtitleLabel.minimumScaleFactor = 5. / titleLabel.font.pointSize;
    subtitleLabel.textAlignment = NSTextAlignmentLeft;
    
    CGFloat fontSize = [subtitleLabel.text fontSizeWithFont:subtitleLabel.font constrainedToSize:subtitleLabel.frame.size];
    subtitleLabel.font = [UIFont customContentRegular:fontSize];
    
    UIImageView *nextIcon = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(button.frame) - 25, CGRectGetHeight(button.frame) / 2 - 10, 20, 20)];
    nextIcon.contentMode = UIViewContentModeScaleAspectFit;
    nextIcon.tintColor = [UIColor customBlue];
    nextIcon.image = [[UIImage imageNamed:@"arrow-right-accessory"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [button addSubview:imageView];
    [button addSubview:titleLabel];
    [button addSubview:subtitleLabel];
    [button addSubview:nextIcon];
    
    if (!available) {
        imageView.tintColor = [UIColor customPlaceholder];
        nextIcon.tintColor = [UIColor customPlaceholder];
        button.userInteractionEnabled = NO;
        
        UILabel *soonLabel = [[UILabel alloc] initWithText:@"Bientôt" textColor:[UIColor redColor] font:[UIFont customContentBold:13] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        soonLabel.layer.masksToBounds = YES;
        soonLabel.layer.borderWidth = 1;
        soonLabel.layer.borderColor = [UIColor customRed].CGColor;
        soonLabel.layer.cornerRadius = 4;
        
        soonLabel.layer.transform = CATransform3DMakeRotation((M_PI * 45.0) / 180, 0, 0, 1);
        
        CGRectSetWidthHeight(soonLabel.frame, CGRectGetWidth(soonLabel.frame) + 15, 20);

        soonLabel.center = imageView.center;
        
        [button addSubview:soonLabel];
    }

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

- (void)openHomeMenu {
    if (!homeViewOpen) {
        homeButtonOverlay.hidden = NO;
        homeButtonOverlay.alpha = 0.0;
        homeButtonOverlay.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.3 animations:^{
            homeButton.layer.transform = CATransform3DMakeRotation((M_PI * 45.0) / 180, 0, 0, 1);
            homeButtonOverlay.alpha = 1.0;
            CGRectSetY(homeSubview.frame, PPScreenHeight() / 2 - CGRectGetHeight(homeSubview.frame) / 2);
        } completion:^(BOOL finished) {
            homeViewOpen = YES;
        }];
    }
}

- (void)closeHomeMenu {
    if (homeViewOpen) {
        [UIView animateWithDuration:0.3 animations:^{
            homeButton.layer.transform = CATransform3DIdentity;
            homeButtonOverlay.alpha = 0.0;
            CGRectSetY(homeSubview.frame, PPScreenHeight() / 2 + 100);
        } completion:^(BOOL finished) {
            homeViewOpen = NO;
            homeButtonOverlay.hidden = YES;
            homeButtonOverlay.userInteractionEnabled = NO;
        }];
    }
}

- (void)didHomeSubShopClick {
    
}

- (void)didHomeSubPayClick {
    [self closeHomeMenu];
    
    NewTransactionViewController *newTransac = [[NewTransactionViewController alloc] initWithTransactionType:TransactionTypeBase];
    
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:newTransac];
    controller.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)didHomeSubCollectClick {
    [self closeHomeMenu];
    
    NewCollectController *newTransac = [NewCollectController new];
    
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:newTransac];
    controller.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)didHomeButtonClick {
    if (homeViewOpen) {
        [self closeHomeMenu];
    } else {
        [self openHomeMenu];
    }
}

- (void)didHomeButtonOverlayClick {

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
