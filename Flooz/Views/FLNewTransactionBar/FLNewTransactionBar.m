//
//  FLNewTransactionBar.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLNewTransactionBar.h"

#import "AppDelegate.h"
#import "NewTransactionViewController.h"

@implementation FLNewTransactionBar {
	CGFloat heightBar;
	CGFloat heightTopBar;
	CGFloat heightButtonBar;
    UIView *separatorButtonBar;
}

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller actionSend:(SEL)actionSend actionCollect:(SEL)actionCollect {
	heightTopBar = 37.0f;
	heightButtonBar = 50.0f;
	heightBar = heightTopBar + heightButtonBar;
	self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightBar)];
	if (self) {
		self.backgroundColor = [UIColor customBackground];

		_dictionary = dictionary;
		currentController = controller;
		actionValidSend = actionSend;
		actionValidCollect = actionCollect;

		locationManager = [CLLocationManager new];
		locationManager.delegate = self;

        [self createPrivacyButton];
        [self createFacebookButton];
        [self createLocalizeButton];
        [self createImageButton];
        //            [self createSeparator];
        [self createButtonSend];
	}
	return self;
}

- (void)reloadData {
	localizeButton.selected = NO;
	imageButton.selected = NO;
	facebookButton.selected = NO;

	if ([_dictionary objectForKey:@"lat"]) {
		localizeButton.selected = YES;
	}
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
        [privacyButton setTitle:[FLTransaction transactionScopeToText:currentIndex] forState:UIControlStateNormal];
        [privacyButton setImage:[FLTransaction transactionScopeToImage:currentIndex] forState:UIControlStateNormal];
        
        [_dictionary setValue:[FLTransaction transactionScopeToParams:currentIndex] forKey:@"scope"];
	}
}

- (void)createButtonSend {

	askButton = [[UIButton alloc] initWithFrame:CGRectMake(1, heightTopBar + 1, CGRectGetWidth(self.frame) / 2. - 1, heightButtonBar - 2)];
	[askButton setTitle:NSLocalizedString(@"MENU_COLLECT", nil) forState:UIControlStateNormal];
	askButton.titleLabel.font = [UIFont customTitleLight:16];
	[askButton setBackgroundColor:[UIColor customBlue]];
	[askButton addTarget:currentController action:actionValidCollect forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:askButton];


	sendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., heightTopBar + 1, CGRectGetWidth(self.frame) / 2. - 1, heightButtonBar - 2)];
	[sendButton setTitle:NSLocalizedString(@"MENU_PAYMENT", nil) forState:UIControlStateNormal];
	sendButton.titleLabel.font = [UIFont customTitleLight:16];
	[sendButton setBackgroundColor:[UIColor customBlue]];
	[sendButton addTarget:currentController action:actionValidSend forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:sendButton];


	separatorButtonBar = [UIView newWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., heightTopBar + heightButtonBar / 4., 1, heightButtonBar / 2.0)];
	[separatorButtonBar setBackgroundColor:[UIColor whiteColor]];
	[self addSubview:separatorButtonBar];
    
    if ([_dictionary[@"preset"] boolValue]) {
        if ([_dictionary[@"method"] isEqualToString:@"pay"]) {
            [separatorButtonBar removeFromSuperview];
            [askButton removeFromSuperview];
            
            [sendButton setFrame:CGRectMake(1, heightTopBar + 1, CGRectGetWidth(self.frame) - 2, heightButtonBar - 2)];
        }
        else if ([_dictionary[@"method"] isEqualToString:@"charge"]) {
            [separatorButtonBar removeFromSuperview];
            [sendButton removeFromSuperview];
            
            [askButton setFrame:CGRectMake(1, heightTopBar + 1, CGRectGetWidth(self.frame) - 2, heightButtonBar - 2)];
        }
    }
}

- (void)createLocalizeButton {
	localizeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 4., heightTopBar)];

	[localizeButton setImage:[UIImage imageNamed:@"new-transaction-bar-localize"] forState:UIControlStateNormal];
	[localizeButton setImage:[UIImage imageNamed:@"new-transaction-bar-localize-selected"] forState:UIControlStateSelected];
	[localizeButton setImage:[UIImage imageNamed:@"new-transaction-bar-localize-selected"] forState:UIControlStateHighlighted];

	[localizeButton addTarget:self action:@selector(didLocalizeButtonTouch) forControlEvents:UIControlEventTouchUpInside];

	[self addSubview:localizeButton];

	// WARNING cache le bouton
	localizeButton.hidden = YES;
}

- (void)createImageButton {
	imageButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.frame) / 4., 0, CGRectGetWidth(self.frame) / 8., heightTopBar)];
	[imageButton setImage:[UIImage imageNamed:@"bar-camera"] forState:UIControlStateNormal];

	[imageButton addTarget:self action:@selector(didImageButtonTouch) forControlEvents:UIControlEventTouchUpInside];

	[self addSubview:imageButton];
}

- (void)createFacebookButton {
	//facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(localizeButton.frame), 0, CGRectGetWidth(self.frame) / 4., heightTopBar)];
	facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - CGRectGetWidth(self.frame) / 8., 0, CGRectGetWidth(self.frame) / 8., heightTopBar)];

	[facebookButton setImage:[UIImage imageNamed:@"bar-facebook"] forState:UIControlStateNormal];
	[facebookButton setImage:[UIImage imageNamed:@"bar-facebook-blue"] forState:UIControlStateSelected];
	[facebookButton setImage:[UIImage imageNamed:@"bar-facebook-blue"] forState:UIControlStateHighlighted];

	[facebookButton addTarget:self action:@selector(didFacebookButtonTouch) forControlEvents:UIControlEventTouchUpInside];

	[self addSubview:facebookButton];
}

- (void)createSeparator {
	UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(facebookButton.frame) + 15, 11, 1, 15)];

	separator.backgroundColor = [UIColor customSeparator];

	[self addSubview:separator];
}

- (void)createPrivacyButton {
	//privacyButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(facebookButton.frame), 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(facebookButton.frame), heightTopBar)];
	privacyButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 3., heightTopBar)];
	privacyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

	[privacyButton setTitleColor:[UIColor customGrey] forState:UIControlStateNormal];
	privacyButton.titleLabel.font = [UIFont customContentRegular:12];

	[privacyButton addTarget:self action:@selector(didPrivacyButtonTouch) forControlEvents:UIControlEventTouchUpInside];

	privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
	privacyButton.titleEdgeInsets = UIEdgeInsetsMake(2, 12, 0, 0);

	{
		UIImageView *arr = [UIImageView imageNamed:@"arrow-white-down"];
		//[privacyButton addSubview:arr];
		CGRectSetY(arr.frame, CGRectGetHeight(privacyButton.frame) / 2. - CGRectGetHeight(arr.frame) / 2. - 1);
		CGRectSetX(arr.frame, CGRectGetWidth(privacyButton.frame) - 10 - CGRectGetWidth(arr.frame));
	}

	[self addSubview:privacyButton];
}

#pragma mark -

- (void)didLocalizeButtonTouch {
	localizeButton.selected = !localizeButton.selected;

	if (localizeButton.selected) {
		if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
			[locationManager startUpdatingLocation];
		}
		else {
			localizeButton.selected = NO;
			DISPLAY_ERROR(FLGPSAccessDenyError);
		}
	}
	else {
		[_dictionary setValue:nil forKey:@"lat"];
		[_dictionary setValue:nil forKey:@"lng"];
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
    
	NSInteger currentIndex = [FLTransaction transactionParamsToScope:[[Flooz sharedInstance].currentUser.settings objectForKey:@"def"][@"scope"]];

	for (NSInteger scope = TransactionScopePublic; scope <= TransactionScopePrivate; ++scope) {
		if ([[_dictionary objectForKey:@"scope"] isEqualToString:[FLTransaction transactionScopeToParams:scope]]) {
			currentIndex = scope;
			break;
		}
	}

	currentIndex++;
	if (currentIndex > TransactionScopePrivate) {
		currentIndex = TransactionScopePublic;
	}

	[_dictionary setValue:[FLTransaction transactionScopeToParams:currentIndex] forKey:@"scope"];

    [privacyButton setTitle:[FLTransaction transactionScopeToText:currentIndex] forState:UIControlStateNormal];
    [privacyButton setImage:[FLTransaction transactionScopeToImage:currentIndex] forState:UIControlStateNormal];
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
