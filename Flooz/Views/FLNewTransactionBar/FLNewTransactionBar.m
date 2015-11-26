//
//  FLNewTransactionBar.m
//  Flooz
//
//  Created by olivier on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLNewTransactionBar.h"

#import "AppDelegate.h"
#import "NewTransactionViewController.h"

#define LOCATION_BAR_HEIGHT 20
#define BAR_HEIGHT 50.
#define MARGIN_H 5.
#define MARGIN_V 10.

@implementation FLNewTransactionBar {
    CGFloat heightBar;
    CGFloat widthBar;
    CGFloat marginH;
    CGFloat marginV;
    CGFloat paymentButtonWidth;
    CGFloat paymentButtonHeight;
    CGFloat actionButtonWidth;
    CGFloat actionButtonHeight;
    CGFloat actionButtonMargin;
    
    UIView *separatorButtonBar;
    
    UIView *tabBarView;
    
    UIView *locationView;
    UILabel *locationLabel;
    UIImageView *locationPrefix;
    
    WYPopoverController *popoverController;
    FLPrivacySelectorViewController *privacyListController;
}

@synthesize facebookButton;
@synthesize privacyButton;
@synthesize imageButton;
@synthesize askButton;
@synthesize sendButton;
@synthesize locationButton;

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller actionSend:(SEL)actionSend actionCollect:(SEL)actionCollect {
    heightBar = BAR_HEIGHT;
    marginH = MARGIN_H;
    marginV = MARGIN_V;
    widthBar = SCREEN_WIDTH;
    
    if (!IS_IPHONE_4)
        heightBar += LOCATION_BAR_HEIGHT;
    
    self = [super initWithFrame:CGRectMake(0, 0, widthBar, heightBar)];
    if (self) {
        paymentButtonWidth = (widthBar / 4.0f) - marginH - (marginH / 2);
        actionButtonHeight = actionButtonWidth = paymentButtonHeight = BAR_HEIGHT - (marginV * 2.0f);
        actionButtonMargin = ((widthBar / 2.0f) - (3.0f * actionButtonWidth)) / 4.0f;
        
        _dictionary = dictionary;
        currentController = controller;
        actionValidSend = actionSend;
        actionValidCollect = actionCollect;
        
        if (!IS_IPHONE_4)
            [self createLocationView];
        
        [self createTabBarView];
        
        privacyListController = [FLPrivacySelectorViewController new];
        privacyListController.delegate = self;
    }
    return self;
}

- (void)reloadData {
    imageButton.selected = NO;
    facebookButton.selected = NO;
    
    if ([_dictionary objectForKey:@"share"]) {
        facebookButton.selected = YES;
    }
    
    {
        NSInteger currentIndex = [FLTransaction transactionParamsToScope:[[Flooz sharedInstance].currentUser.settings objectForKey:@"def"][@"scope"]];
        for (NSInteger scope = TransactionScopePublic; scope <= TransactionScopePrivate; ++scope) {
            if ([[_dictionary objectForKey:@"scope"] isEqualToString:[FLTransaction transactionScopeToParams:scope]]) {
                currentIndex = scope;
                break;
            }
        }
        
        privacyListController.currentScope = currentIndex;
        
        [privacyButton setImage:[[FLTransaction transactionScopeToImage:currentIndex] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [privacyButton setTintColor:[UIColor whiteColor]];
        
        [_dictionary setValue:[FLTransaction transactionScopeToParams:currentIndex] forKey:@"scope"];
    }
    
    if (_dictionary[@"geo"]) {
        if (!IS_IPHONE_4) {
            [locationView setHidden:NO];
            [locationLabel setText:_dictionary[@"geo"][@"name"]];
        }
        [locationButton setTintColor:[UIColor customBlue]];
    } else {
        [locationView setHidden:YES];
        [locationButton setTintColor:[UIColor whiteColor]];
    }
}

- (void)createButtonSend {
    
    askButton = [[FLActionButton alloc] initWithFrame:CGRectMake((widthBar / 2) + marginH, marginV, paymentButtonWidth, paymentButtonHeight)];
    [askButton setTitle:NSLocalizedString(@"MENU_COLLECT", nil) forState:UIControlStateNormal];
    askButton.titleLabel.font = [UIFont customTitleLight:14];
    [askButton addTarget:currentController action:actionValidCollect forControlEvents:UIControlEventTouchUpInside];
    [tabBarView addSubview:askButton];
    
    sendButton = [[FLActionButton alloc] initWithFrame:CGRectMake((widthBar / 2) + (widthBar / 4) + (marginH / 2), marginV, paymentButtonWidth, paymentButtonHeight)];
    [sendButton setTitle:NSLocalizedString(@"MENU_PAYMENT", nil) forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont customTitleLight:14];
    [sendButton addTarget:currentController action:actionValidSend forControlEvents:UIControlEventTouchUpInside];
    [tabBarView addSubview:sendButton];
    
    if ([_dictionary[@"preset"] boolValue]) {
        if ([_dictionary[@"method"] isEqualToString:@"pay"]) {
            [askButton removeFromSuperview];
            
            [sendButton setFrame:CGRectMake((widthBar / 2) + marginH, marginV, (widthBar / 2) - (marginH * 2), paymentButtonHeight)];
            sendButton.titleLabel.font = [UIFont customTitleLight:16];
        }
        else if ([_dictionary[@"method"] isEqualToString:@"charge"]) {
            [sendButton removeFromSuperview];
            
            [askButton setFrame:CGRectMake((widthBar / 2) + marginH, marginV, (widthBar / 2) - (marginH * 2), paymentButtonHeight)];
            askButton.titleLabel.font = [UIFont customTitleLight:16];
        }
    }
}

- (void)hideChargeButton:(BOOL)hidden {
    if (hidden && askButton.superview != nil){
        [askButton removeFromSuperview];
        
        [sendButton setFrame:CGRectMake((widthBar / 2) + marginH, marginV, (widthBar / 2) - (marginH * 2), paymentButtonHeight)];
        sendButton.titleLabel.font = [UIFont customTitleLight:16];
    } else if (!hidden && askButton.superview == nil) {
        [sendButton setFrame:CGRectMake((widthBar / 2) + (widthBar / 4) + (marginH / 2), marginV, paymentButtonWidth, paymentButtonHeight)];
        sendButton.titleLabel.font = [UIFont customTitleLight:14];
        
        [tabBarView addSubview:askButton];
    }
}

- (void)hidePayButton:(BOOL)hidden {
    if (hidden && sendButton.superview != nil){
        [sendButton removeFromSuperview];
        
        [askButton setFrame:CGRectMake((widthBar / 2) + marginH, marginV, (widthBar / 2) - (marginH * 2), paymentButtonHeight)];
        askButton.titleLabel.font = [UIFont customTitleLight:16];
    } else if (!hidden && askButton.superview == nil) {
        [askButton setFrame:CGRectMake((widthBar / 2) + marginH, marginV, paymentButtonWidth, paymentButtonHeight)];
        askButton.titleLabel.font = [UIFont customTitleLight:14];
        
        [tabBarView addSubview:sendButton];
    }
}

- (void)createTabBarView {
    CGFloat offsetY = 0;
    
    if (!IS_IPHONE_4)
        offsetY = LOCATION_BAR_HEIGHT;
    
    tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, PPScreenWidth(), BAR_HEIGHT)];
    tabBarView.backgroundColor = [UIColor customMiddleBlue];

    [self createPrivacyButton];
    [self createImageButton];
    [self createLocationButton];
    [self createButtonSend];
    
    [self addSubview:tabBarView];
}

- (void)createLocationView {
    locationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), LOCATION_BAR_HEIGHT)];
    [locationView setBackgroundColor:[UIColor customBackgroundHeader:1.0f]];
    [locationView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didLocationButtonTouch)]];
    
    locationPrefix = [[UIImageView alloc] initWithFrame:CGRectMake(5, 3, 14, 14)];
    [locationPrefix setContentMode:UIViewContentModeScaleAspectFit];
    [locationPrefix setImage:[[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [locationPrefix setTintColor:[UIColor whiteColor]];
    
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(22, 2, PPScreenWidth() - 50, 16)];
    [locationLabel setFont:[UIFont customContentRegular:11]];
    [locationLabel setTextColor:[UIColor whiteColor]];
    [locationLabel setNumberOfLines:1];
    
    [locationView addSubview:locationPrefix];
    [locationView addSubview:locationLabel];
    
    [self addSubview:locationView];
}

- (void)createLocationButton {
    locationButton = [[UIButton alloc] initWithFrame:CGRectMake((actionButtonMargin * 3) + (actionButtonWidth * 2), marginV, actionButtonWidth, actionButtonHeight)];
    [locationButton setImage:[[UIImage imageNamed:@"map"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [locationButton setTintColor:[UIColor whiteColor]];
    
    [locationButton addTarget:self action:@selector(didLocationButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [tabBarView addSubview:locationButton];
}

- (void)createImageButton {
    imageButton = [[UIButton alloc] initWithFrame:CGRectMake((actionButtonMargin * 2) + actionButtonWidth, marginV, actionButtonWidth, actionButtonHeight)];
    [imageButton setImage:[[UIImage imageNamed:@"bar-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [imageButton setTintColor:[UIColor whiteColor]];
    
    [imageButton addTarget:self action:@selector(didImageButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [tabBarView addSubview:imageButton];
}

- (void)createPrivacyButton {
    privacyButton = [[UIButton alloc] initWithFrame:CGRectMake(actionButtonMargin, marginV, actionButtonWidth, actionButtonHeight)];
    
    [privacyButton addTarget:self action:@selector(didPrivacyButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [tabBarView addSubview:privacyButton];
}

- (void)enablePaymentButtons:(BOOL)enable {
    [askButton setEnabled:enable];
    [sendButton setEnabled:enable];
}

#pragma mark -

- (void)didLocationButtonTouch {
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([CLLocationManager locationServicesEnabled]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)) {
            [locationManager requestWhenInUseAuthorization];
        } else {
            [(NewTransactionViewController *)currentController presentLocation];
        }
    }
}

- (void)didImageButtonTouch {
    [(NewTransactionViewController *)currentController presentCamera];
}

- (void)didFacebookButtonTouch {
    facebookButton.selected = !facebookButton.selected;
    
    if (facebookButton.selected) {
        [_dictionary setValue:[[Flooz sharedInstance] facebook_token] forKey:@"share"];
        if (![[Flooz sharedInstance] facebook_token]) {
            [[Flooz sharedInstance] connectFacebook];
        }
    }
    else {
        [_dictionary setValue:nil forKey:@"share"];
    }
}

- (void)didPrivacyButtonTouch {
    if (self.delegate)
        [self.delegate scopePopoverWillAppear];
    
    popoverController = [[WYPopoverController alloc] initWithContentViewController:privacyListController];
    popoverController.delegate = self;
    
    [popoverController presentPopoverFromRect:privacyButton.bounds inView:privacyButton permittedArrowDirections:WYPopoverArrowDirectionDown animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:nil];
}

- (void)scopeChange:(TransactionScope)scope {
    [_dictionary setValue:[FLTransaction transactionScopeToParams:scope] forKey:@"scope"];
    [privacyButton setImage:[[FLTransaction transactionScopeToImage:scope] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
        if (self.delegate)
            [self.delegate scopePopoverDidDisappear];
    }];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    if (self.delegate)
        [self.delegate scopePopoverDidDisappear];
}

- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value
{
    *value = 0;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            
        } break;
        case kCLAuthorizationStatusDenied: {
            
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [(NewTransactionViewController *)currentController presentLocation];
        case kCLAuthorizationStatusAuthorizedAlways: {
            [(NewTransactionViewController *)currentController presentLocation];
        } break;
        default:
            break;
    }
}

@end
