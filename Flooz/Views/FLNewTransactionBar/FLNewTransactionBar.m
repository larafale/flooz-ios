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
    
    WYPopoverController *popoverController;
    FLPrivacySelectorViewController *privacyListController;
}

@synthesize facebookButton;
@synthesize privacyButton;
@synthesize imageButton;
@synthesize askButton;
@synthesize sendButton;

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller actionSend:(SEL)actionSend actionCollect:(SEL)actionCollect {
    heightBar = BAR_HEIGHT;
    marginH = MARGIN_H;
    marginV = MARGIN_V;
    widthBar = SCREEN_WIDTH;
    self = [super initWithFrame:CGRectMake(0, 0, widthBar, heightBar)];
    if (self) {
        self.backgroundColor = [UIColor customMiddleBlue];
        paymentButtonWidth = (widthBar / 4.0f) - marginH - (marginH / 2);
        actionButtonHeight = actionButtonWidth = paymentButtonHeight = heightBar - (marginV * 2.0f);
        actionButtonMargin = ((widthBar / 2.0f) - (2.0f * actionButtonWidth)) / 3.0f;
        
        
        _dictionary = dictionary;
        currentController = controller;
        actionValidSend = actionSend;
        actionValidCollect = actionCollect;
        
        locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        
        [self createPrivacyButton];
//        [self createFacebookButton];
//        [self createQRCodeButton];
        [self createImageButton];
        [self createButtonSend];
        
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
}

- (void)createButtonSend {
    
    askButton = [[FLActionButton alloc] initWithFrame:CGRectMake((widthBar / 2) + marginH, marginV, paymentButtonWidth, paymentButtonHeight)];
    [askButton setTitle:NSLocalizedString(@"MENU_COLLECT", nil) forState:UIControlStateNormal];
    askButton.titleLabel.font = [UIFont customTitleLight:14];
    [askButton addTarget:currentController action:actionValidCollect forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:askButton];
    
    sendButton = [[FLActionButton alloc] initWithFrame:CGRectMake((widthBar / 2) + (widthBar / 4) + (marginH / 2), marginV, paymentButtonWidth, paymentButtonHeight)];
    [sendButton setTitle:NSLocalizedString(@"MENU_PAYMENT", nil) forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont customTitleLight:14];
    [sendButton addTarget:currentController action:actionValidSend forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];
    
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
        
        [self addSubview:askButton];
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
        
        [self addSubview:sendButton];
    }
}

- (void)createImageButton {
    imageButton = [[UIButton alloc] initWithFrame:CGRectMake((actionButtonMargin * 2) + actionButtonWidth, marginV, actionButtonWidth, actionButtonHeight)];
    [imageButton setImage:[[UIImage imageNamed:@"bar-camera"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [imageButton setTintColor:[UIColor whiteColor]];
    
    [imageButton addTarget:self action:@selector(didImageButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:imageButton];
}

- (void)createFacebookButton {
    facebookButton = [[UIButton alloc] initWithFrame:CGRectMake((actionButtonMargin * 3) + (actionButtonWidth * 2), marginV, actionButtonWidth, actionButtonHeight)];
    
    [facebookButton setImage:[UIImage imageNamed:@"bar-facebook"] forState:UIControlStateNormal];
    [facebookButton setImage:[UIImage imageNamed:@"bar-facebook-blue"] forState:UIControlStateSelected];
    [facebookButton setImage:[UIImage imageNamed:@"bar-facebook-blue"] forState:UIControlStateHighlighted];
    
    [facebookButton addTarget:self action:@selector(didFacebookButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:facebookButton];
}

- (void)createPrivacyButton {
    privacyButton = [[UIButton alloc] initWithFrame:CGRectMake(actionButtonMargin, marginV, actionButtonWidth, actionButtonHeight)];
    
    [privacyButton addTarget:self action:@selector(didPrivacyButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:privacyButton];
}

- (void)enablePaymentButtons:(BOOL)enable {
    [askButton setEnabled:enable];
    [sendButton setEnabled:enable];
}

#pragma mark -

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

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSNumber *lat = [NSNumber numberWithDouble:[manager.location coordinate].latitude];
    NSNumber *lng = [NSNumber numberWithDouble:[manager.location coordinate].longitude];
    
    [_dictionary setValue:lat forKey:@"lat"];
    [_dictionary setValue:lng forKey:@"lng"];
    
    [manager stopUpdatingLocation];
}

@end
