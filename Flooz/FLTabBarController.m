//
//  FLTabBarController.m
//  Flooz
//
//  Created by Flooz on 7/9/15.
//  Copyright (c) 2015 Flooz. All rights reserved.
//

#import "TimelineViewController.h"
#import "NotificationsViewController.h"
#import "FriendsViewController.h"
#import "AccountViewController.h"
#import "ShareAppViewController.h"
#import "SDWebImageDownloader.h"
#import "UserViewController.h"
#import "DealViewController.h"
#import "FXBlurView.h"
#import "FLTabBarController.h"
#import "NewCollectController.h"
#import "FLPlusButton.h"
#import "UserPickerViewController.h"

@interface UITabBarController (private)
- (UITabBar *)tabBar;
@end

@interface FLTabBarController() {
    UITabBarItem *homeItem;
    UITabBarItem *notifItem;
    UITabBarItem *floozItem;
    UITabBarItem *thirdItem;
    UITabBarItem *profileItem;
    
    FLPlusButton *homeButton;
    FXBlurView *homeButtonOverlay;
    
    UIView *homeSubview;
    UILabel *homeOverlayTitle;
    
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
    [self registerNotification:@selector(reloadText) name:kNotificationReloadTexts object:nil];
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
        [profileItem setBadgeValue:[@(accountNotifs) stringValue]];
    else
        [profileItem setBadgeValue:nil];
}

- (void)reloadText {
    [self createHomeMenu];
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
 
    homeOverlayTitle = [[UILabel alloc] initWithText:@"Choisissez une option" textColor:[UIColor customBlue] font:[UIFont customContentBold:25] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    CGRectSetXY(homeOverlayTitle.frame, 20, 40);
    CGRectSetWidth(homeOverlayTitle.frame, PPScreenWidth() - 40);
    
    [homeButtonOverlay addSubview:homeOverlayTitle];

    homeButton = [[FLPlusButton alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetHeight(self.tabBar.frame) + 10.0f, CGRectGetHeight(self.tabBar.frame) + 10.0f)];
    homeButton.center = self.tabBar.center;
    [homeButton addTarget:self action:@selector(didHomeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    homeButton.layer.shadowColor = [UIColor blackColor].CGColor;
    homeButton.layer.shadowRadius = 1.0;
    homeButton.layer.shadowOffset = CGSizeMake(0.0, -2.0);
    homeButton.layer.shadowOpacity = 1.0f;
    homeButton.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:homeButton.bounds cornerRadius:CGRectGetHeight(homeButton.frame) / 2].CGPath;
    
    CGRectSetY(homeButton.frame, CGRectGetHeight(self.view.frame) - CGRectGetHeight(homeButton.frame) - 3.0f);
    
    [self.view addSubview:homeButtonOverlay];
    
    [self createHomeMenu];
    
    [self.view addSubview:homeButton];
}

- (void)createHomeMenu {
    if (homeSubview)
        [homeSubview removeFromSuperview];
    
    homeSubview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    
    CGFloat offSetY = 0;
    
    for (FLHomeButton *buttonData in [Flooz sharedInstance].currentTexts.homeButtons) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, offSetY, PPScreenWidth() - 20, 80)];
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHomeMenuButtonClick:)]];
        
        [self fillHomeSubButton:view data:buttonData];
        
        [homeSubview addSubview:view];

        CGRectSetHeight(homeSubview.frame, CGRectGetMaxY(view.frame));
        offSetY = CGRectGetMaxY(view.frame) + 20;
    }
    
    CGRectSetY(homeSubview.frame, PPScreenHeight() / 2 + 100);
    
    [homeButtonOverlay addSubview:homeSubview];
    
    if (homeViewOpen) {
        homeButtonOverlay.hidden = NO;
        homeButtonOverlay.alpha = 0.0;
        homeButtonOverlay.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:0 animations:^{
            homeButton.layer.transform = CATransform3DMakeRotation((M_PI * 45.0) / 180, 0, 0, 1);
            homeButtonOverlay.alpha = 1.0;
            
            CGFloat finalY;
            CGFloat viewHeight = CGRectGetHeight(homeSubview.frame);
            
            if (CGRectGetMinY(homeButton.frame) - CGRectGetMaxY(homeOverlayTitle.frame) - 20 < viewHeight) {
                homeOverlayTitle.hidden = YES;
                finalY = CGRectGetMinY(homeButton.frame) / 2 - CGRectGetHeight(homeSubview.frame) / 2;
            } else {
                homeOverlayTitle.hidden = NO;
                finalY = (CGRectGetMinY(homeButton.frame) - CGRectGetMaxY(homeOverlayTitle.frame)) / 2 - CGRectGetHeight(homeSubview.frame) / 2 + CGRectGetMaxY(homeOverlayTitle.frame);
            }
            
            CGRectSetY(homeSubview.frame, finalY);
        } completion:^(BOOL finished) {
            homeViewOpen = YES;
        }];
    } else {
        [UIView animateWithDuration:0 animations:^{
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

- (void)fillHomeSubButton:(UIView *)button data:(FLHomeButton *)buttonData {
    button.backgroundColor = [UIColor customBackground:0.6];
    button.layer.cornerRadius = 5;
    
    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(button.frame) / 2 - 25, 50, 50)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tintColor = [UIColor customBlue];
    
    if (buttonData.imgUrl && ![buttonData.imgUrl isBlank]) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:buttonData.imgUrl] placeholderImage:[[UIImage imageNamed:buttonData.defaultImg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] options:SDWebImageRefreshCached|SDWebImageContinueInBackground completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (imageView && !error) {
                imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            }
        }];
    } else {
        imageView.image = [[UIImage imageNamed:buttonData.defaultImg] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 15, 10, CGRectGetWidth(button.frame) - CGRectGetMaxX(imageView.frame) - 45, 25)];
    titleLabel.font = [UIFont customContentRegular:20];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = buttonData.title;
    titleLabel.numberOfLines = 1;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 10. / titleLabel.font.pointSize;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 15, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(button.frame) - CGRectGetMaxX(imageView.frame) - 45, 35)];
    subtitleLabel.font = [UIFont customContentRegular:13];
    subtitleLabel.textColor = [UIColor customPlaceholder];
    subtitleLabel.text = buttonData.subtitle;
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
    
    if (buttonData.soon) {
        imageView.tintColor = [UIColor customPlaceholder];
        nextIcon.tintColor = [UIColor customPlaceholder];
        button.userInteractionEnabled = NO;
        
        UILabel *soonLabel = [[UILabel alloc] initWithText:@"Bientôt disponible" textColor:[UIColor redColor] font:[UIFont customContentBold:14] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        soonLabel.layer.masksToBounds = YES;
        soonLabel.layer.borderWidth = 1.5;
        soonLabel.layer.borderColor = [UIColor redColor].CGColor;
        soonLabel.layer.cornerRadius = 4;
        soonLabel.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.7];
        
        CGRectSetWidthHeight(soonLabel.frame, [soonLabel widthToFit] + 30, 30);
        
        soonLabel.layer.transform = CATransform3DMakeRotation((M_PI * -15.0) / 180, 0, 0, 1);
        
        soonLabel.center = CGPointMake(CGRectGetWidth(button.frame) / 2, CGRectGetHeight(button.frame) / 2);
        
        [button addSubview:soonLabel];
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    [homeButtonOverlay updateAsynchronously:YES completion:nil];
    if ([viewController isEqual:[self.viewControllers objectAtIndex:2]]) {
        if (homeViewOpen) {
            [self closeHomeMenu];
        } else {
            [self openHomeMenu];
        }
        return NO;
    }
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self reloadBadge];
    [self reloadCurrentUser];
}

- (void)openHomeMenu {
    if (!homeViewOpen) {
        homeButtonOverlay.hidden = NO;
        homeButtonOverlay.alpha = 0.0;
        homeButtonOverlay.userInteractionEnabled = YES;
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
        [UIView animateWithDuration:0.3 animations:^{
            homeButton.layer.transform = CATransform3DMakeRotation((M_PI * 45.0) / 180, 0, 0, 1);
            homeButtonOverlay.alpha = 1.0;
            
            CGFloat finalY;
            CGFloat viewHeight = CGRectGetHeight(homeSubview.frame);
            
            if (CGRectGetMinY(homeButton.frame) - CGRectGetMaxY(homeOverlayTitle.frame) - 20 < viewHeight) {
                homeOverlayTitle.hidden = YES;
                finalY = CGRectGetMinY(homeButton.frame) / 2 - CGRectGetHeight(homeSubview.frame) / 2;
            } else {
                homeOverlayTitle.hidden = NO;
                finalY = (CGRectGetMinY(homeButton.frame) - CGRectGetMaxY(homeOverlayTitle.frame)) / 2 - CGRectGetHeight(homeSubview.frame) / 2 + CGRectGetMaxY(homeOverlayTitle.frame);
            }
            
            CGRectSetY(homeSubview.frame, finalY);
        } completion:^(BOOL finished) {
            homeViewOpen = YES;
        }];
    }
}

- (void)closeHomeMenu {
    if (homeViewOpen) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

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

- (void)didHomeMenuButtonClick:(UITapGestureRecognizer *)sender {
    [self closeHomeMenu];

    NSInteger i = [homeSubview.subviews indexOfObject:sender.view];
    
    if (i != NSNotFound) {
        FLHomeButton *currentButton = [Flooz sharedInstance].currentTexts.homeButtons[i];
        
        [[FLTriggerManager sharedInstance] executeTriggerList:currentButton.triggers];
    }
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
    
    if ([numberNotif intValue] == 0)
        [notifItem setBadgeValue:nil];
    else
        [notifItem setBadgeValue:[numberNotif stringValue]];
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
