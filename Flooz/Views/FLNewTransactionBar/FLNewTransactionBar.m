//
//  FLNewTransactionBar.m
//  Flooz
//
//  Created by Olivier on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLNewTransactionBar.h"
#import "GBDeviceInfo.h"
#import "AppDelegate.h"
#import "NewCollectController.h"
#import "NewFloozViewController.h"

#define LOCATION_BAR_HEIGHT 20
#define BAR_HEIGHT 35.
#define ACTION_BAR_HEIGHT 37.5
#define MARGIN_H 5.
#define MARGIN_V 2.5

@implementation FLNewTransactionBar {
    CGFloat heightBar;
    CGFloat widthBar;
    CGFloat marginH;
    CGFloat marginV;
    CGFloat actionButtonWidth;
    CGFloat actionButtonHeight;
    CGFloat actionButtonMargin;
    
    UIView *tabBarView;
    UIView *actionView;
    
    UIView *locationView;
    UILabel *locationLabel;
    UIImageView *locationPrefix;
    
    FLPreset *currentPreset;
    
    BOOL isParticipation;
}

@synthesize textButton;
@synthesize cameraButton;
@synthesize gifButton;
@synthesize imageButton;
@synthesize askButton;
@synthesize sendButton;
@synthesize locationButton;
@synthesize collectButton;
@synthesize participateButton;
@synthesize paymentButtonsSeparator;

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller preset:(FLPreset *)preset actionParticipate:(SEL)actionParticipate {
    heightBar = BAR_HEIGHT + ACTION_BAR_HEIGHT;
    marginH = MARGIN_H;
    marginV = MARGIN_V;
    widthBar = SCREEN_WIDTH;
    
    isParticipation = YES;
    
    currentPreset = preset;
    
    if (!IS_IPHONE_4)
        heightBar += LOCATION_BAR_HEIGHT;
    
    self = [super initWithFrame:CGRectMake(0, 0, widthBar, heightBar)];
    if (self) {
        actionButtonHeight = actionButtonWidth = BAR_HEIGHT - (marginV * 2.0f);
        actionButtonMargin = (widthBar - (5.0f * actionButtonWidth)) / 6.0f;
        
        _dictionary = dictionary;
        currentController = controller;
        actionValidParticipation = actionParticipate;
        
        if (!IS_IPHONE_4)
            [self createLocationView];
        
        [self createTabBarView];
        [self createActionBarView];
    }
    return self;
}

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller preset:(FLPreset *)preset actionSend:(SEL)actionSend actionCharge:(SEL)actionCharge{
    heightBar = BAR_HEIGHT + ACTION_BAR_HEIGHT;
    marginH = MARGIN_H;
    marginV = MARGIN_V;
    widthBar = SCREEN_WIDTH;
    
    isParticipation = NO;
    
    currentPreset = preset;
    
    if (!IS_IPHONE_4)
        heightBar += LOCATION_BAR_HEIGHT;
    
    self = [super initWithFrame:CGRectMake(0, 0, widthBar, heightBar)];
    if (self) {
        actionButtonHeight = actionButtonWidth = BAR_HEIGHT - (marginV * 2.0f);
        actionButtonMargin = (widthBar - (5.0f * actionButtonWidth)) / 6.0f;
        
        _dictionary = dictionary;
        currentController = controller;
        actionValidSend = actionSend;
        actionValidCharge = actionCharge;
        
        if (!IS_IPHONE_4)
            [self createLocationView];
        
        [self createTabBarView];
        [self createActionBarView];
    }
    return self;
}

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller preset:(FLPreset *)preset actionCollect:(SEL)actionCollect {
    heightBar = BAR_HEIGHT + ACTION_BAR_HEIGHT;
    marginH = MARGIN_H;
    marginV = MARGIN_V;
    widthBar = SCREEN_WIDTH;
    
    isParticipation = NO;
    
    currentPreset = preset;
    
    if (!IS_IPHONE_4)
        heightBar += LOCATION_BAR_HEIGHT;
    
    self = [super initWithFrame:CGRectMake(0, 0, widthBar, heightBar)];
    if (self) {
        actionButtonHeight = actionButtonWidth = BAR_HEIGHT - (marginV * 2.0f);
        actionButtonMargin = (widthBar - (5.0f * actionButtonWidth)) / 6.0f;
        
        _dictionary = dictionary;
        currentController = controller;
        actionValidCollect = actionCollect;
        
        if (!IS_IPHONE_4)
            [self createLocationView];
        
        [self createTabBarView];
        [self createActionBarView];
    }
    return self;
}

- (void)reloadData {
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

- (void)hideButtonSeparator:(BOOL)hidden {
    if (hidden && paymentButtonsSeparator.superview != nil){
        [paymentButtonsSeparator removeFromSuperview];
    } else if (!hidden && paymentButtonsSeparator.superview == nil) {
        [actionView addSubview:paymentButtonsSeparator];
    }
}

- (void)hideChargeButton:(BOOL)hidden {
    if (hidden && askButton.superview != nil){
        [askButton removeFromSuperview];
        
        [paymentButtonsSeparator removeFromSuperview];
        
        [sendButton setFrame:CGRectMake(0, 0, PPScreenWidth(), ACTION_BAR_HEIGHT)];
        sendButton.titleLabel.font = [UIFont customTitleLight:18];
    } else if (!hidden && askButton.superview == nil) {
        [sendButton setFrame:CGRectMake(PPScreenWidth() / 2, 0, PPScreenWidth() / 2, ACTION_BAR_HEIGHT)];
        sendButton.titleLabel.font = [UIFont customTitleLight:14];
        
        [actionView addSubview:askButton];
        [actionView addSubview:paymentButtonsSeparator];
    }
}

- (void)hidePayButton:(BOOL)hidden {
    if (hidden && sendButton.superview != nil){
        [sendButton removeFromSuperview];
        [paymentButtonsSeparator removeFromSuperview];
        
        [askButton setFrame:CGRectMake(0, 0, PPScreenWidth(), ACTION_BAR_HEIGHT)];
        askButton.titleLabel.font = [UIFont customTitleLight:18];
    } else if (!hidden && askButton.superview == nil) {
        [askButton setFrame:CGRectMake(0, 0, PPScreenWidth() / 2, ACTION_BAR_HEIGHT)];
        askButton.titleLabel.font = [UIFont customTitleLight:14];
        
        [actionView addSubview:sendButton];
        
        [actionView addSubview:paymentButtonsSeparator];
    }
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

- (void)createTabBarView {
    CGFloat offsetY = 0;
    
    if (!IS_IPHONE_4)
        offsetY = LOCATION_BAR_HEIGHT;

    if (isBorderlessDisplay()) {
        offsetY = LOCATION_BAR_HEIGHT - 4;
    }

    tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, PPScreenWidth(), BAR_HEIGHT)];
    tabBarView.backgroundColor = [UIColor customMiddleBlue];

    NSMutableArray<UIButton *> *buttons = [NSMutableArray new];
    
    if (!currentPreset || currentPreset.options.allowWhy) {
        [self createTextButton];
        [buttons addObject:textButton];
    }
    
    if (!currentPreset || currentPreset.options.allowPic) {
        [self createCameraButton];
        [buttons addObject:cameraButton];
        
        [self createImageButton];
        [buttons addObject:imageButton];
    }
    
    if (!currentPreset || currentPreset.options.allowGif) {
        [self createGIFButton];
        [buttons addObject:gifButton];
    }
    
    if (!currentPreset || currentPreset.options.allowGeo) {
        [self createLocationButton];
        [buttons addObject:locationButton];
    }
    
    if (buttons.count == 0 || (buttons.count == 1 && currentPreset && currentPreset.options.allowWhy)) {
        tabBarView.backgroundColor = [UIColor clearColor];
    } else {
        actionButtonMargin = (widthBar - (buttons.count * actionButtonWidth)) / (buttons.count + 1);
        int i = 1;
        
        for (UIButton *button in buttons) {
            CGRectSetX(button.frame, (actionButtonMargin * i) + (actionButtonWidth * (i - 1)));
            [tabBarView addSubview:button];
            ++i;
        }
    }
    
    
    [self addSubview:tabBarView];
}

- (void)createTextButton {
    textButton = [[UIButton alloc] initWithFrame:CGRectMake(actionButtonMargin, marginV, actionButtonWidth, actionButtonHeight)];
    [textButton setImage:[[UIImage imageNamed:@"action-text"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [textButton setTintColor:[UIColor whiteColor]];
    
    [textButton addTarget:self action:@selector(didTextButtonTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createCameraButton {
    cameraButton = [[UIButton alloc] initWithFrame:CGRectMake((actionButtonMargin * 2) + (actionButtonWidth * 1), marginV, actionButtonWidth, actionButtonHeight)];
    [cameraButton setImage:[[UIImage imageNamed:@"action-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [cameraButton setTintColor:[UIColor whiteColor]];
    
    [cameraButton addTarget:self action:@selector(didCameraButtonTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createImageButton {
    imageButton = [[UIButton alloc] initWithFrame:CGRectMake((actionButtonMargin * 3) + (actionButtonWidth * 2), marginV, actionButtonWidth, actionButtonHeight)];
    [imageButton setImage:[[UIImage imageNamed:@"action-album"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [imageButton setTintColor:[UIColor whiteColor]];
    
    [imageButton addTarget:self action:@selector(didImageButtonTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createGIFButton {
    gifButton = [[UIButton alloc] initWithFrame:CGRectMake((actionButtonMargin * 4) + (actionButtonWidth * 3), marginV, actionButtonWidth, actionButtonHeight)];
    [gifButton setImage:[[UIImage imageNamed:@"action-gif"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [gifButton setTintColor:[UIColor whiteColor]];
    
    [gifButton addTarget:self action:@selector(didGIFButtonTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createLocationButton {
    locationButton = [[UIButton alloc] initWithFrame:CGRectMake((actionButtonMargin * 5) + (actionButtonWidth * 4), marginV, actionButtonWidth, actionButtonHeight)];
    [locationButton setImage:[[UIImage imageNamed:@"action-location"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [locationButton setTintColor:[UIColor whiteColor]];
    
    [locationButton addTarget:self action:@selector(didLocationButtonTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createActionBarView {
    actionView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tabBarView.frame), PPScreenWidth(), ACTION_BAR_HEIGHT)];
    if (isBorderlessDisplay()) {
        CGRectSetHeight(actionView.frame, ACTION_BAR_HEIGHT + 4);
    }

    actionView.backgroundColor = [UIColor customBlue];
    
    [self createButtonSend];
    
    [self addSubview:actionView];
}

- (void)createButtonSend {
    askButton = [[FLActionButton alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth() / 2, ACTION_BAR_HEIGHT)];
    [askButton setTitle:NSLocalizedString(@"MENU_CHARGE", nil) forState:UIControlStateNormal];
    askButton.titleLabel.font = [UIFont customTitleLight:17];
    [askButton addTarget:currentController action:actionValidCharge forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:askButton];
    
    sendButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2, 0, PPScreenWidth() / 2, ACTION_BAR_HEIGHT)];
    [sendButton setTitle:NSLocalizedString(@"MENU_PAYMENT", nil) forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont customTitleLight:17];
    [sendButton addTarget:currentController action:actionValidSend forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:sendButton];
    
    collectButton = [[FLActionButton alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), ACTION_BAR_HEIGHT)];
    [collectButton setTitle:NSLocalizedString(@"MENU_COLLECT", nil) forState:UIControlStateNormal];
    collectButton.titleLabel.font = [UIFont customTitleLight:18];
    [collectButton addTarget:currentController action:actionValidCollect forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:collectButton];
    
    participateButton = [[FLActionButton alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), ACTION_BAR_HEIGHT)];
    [participateButton setTitle:NSLocalizedString(@"MENU_PARTICIPATE", nil) forState:UIControlStateNormal];
    participateButton.titleLabel.font = [UIFont customTitleLight:18];
    [participateButton addTarget:currentController action:actionValidParticipation forControlEvents:UIControlEventTouchUpInside];
    [actionView addSubview:participateButton];
    
    paymentButtonsSeparator = [[UIView alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2 - .5, 5, 1, ACTION_BAR_HEIGHT - 10)];
    [paymentButtonsSeparator setBackgroundColor:[UIColor whiteColor]];
    [actionView addSubview:paymentButtonsSeparator];
    
    if (isParticipation) {
        [collectButton removeFromSuperview];
        [askButton removeFromSuperview];
        [sendButton removeFromSuperview];
        [paymentButtonsSeparator removeFromSuperview];
    } else if ([currentController isKindOfClass:[NewFloozViewController class]]) {
        [participateButton removeFromSuperview];
        [collectButton removeFromSuperview];
        if (currentPreset) {
            if (currentPreset.options.type == TransactionTypePayment) {
                [askButton removeFromSuperview];
                [paymentButtonsSeparator removeFromSuperview];
                
                [sendButton setFrame:CGRectMake(0, 0, PPScreenWidth(), ACTION_BAR_HEIGHT)];
                sendButton.titleLabel.font = [UIFont customTitleLight:18];
            }
            else if (currentPreset.options.type == TransactionTypeCharge) {
                [sendButton removeFromSuperview];
                [paymentButtonsSeparator removeFromSuperview];
                
                [askButton setFrame:CGRectMake(0, 0, PPScreenWidth(), ACTION_BAR_HEIGHT)];
                askButton.titleLabel.font = [UIFont customTitleLight:18];
            }
        }
    } else if ([currentController isKindOfClass:[NewCollectController class]]) {
        [askButton removeFromSuperview];
        [sendButton removeFromSuperview];
        [participateButton removeFromSuperview];
        [paymentButtonsSeparator removeFromSuperview];
    }
}

- (void)enablePaymentButtons:(BOOL)enable {
    [askButton setEnabled:enable];
    [sendButton setEnabled:enable];
}

#pragma mark -

- (void)didTextButtonTouch {
    if (_delegate){
        [_delegate focusDescription];
    }
}

- (void)didCameraButtonTouch {
    if (_delegate){
        [_delegate presentCamera];
    }
}

- (void)didImageButtonTouch {
    if (_delegate){
        [_delegate presentImagePicker];
    }
}

- (void)didGIFButtonTouch {
    if (_delegate){
        [_delegate presentGIFPicker];
    }
}

- (void)didLocationButtonTouch {
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([CLLocationManager locationServicesEnabled]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways)) {
            [locationManager requestWhenInUseAuthorization];
        } else if (_delegate){
            [_delegate presentLocation];
        }
    }
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
            if (_delegate){
                [_delegate presentLocation];
            }
        case kCLAuthorizationStatusAuthorizedAlways: {
            if (_delegate){
                [_delegate presentLocation];
            }
        }
            break;
        default:
            break;
    }
}

@end
