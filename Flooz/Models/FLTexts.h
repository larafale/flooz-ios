//
//  FLTexts.h
//  Flooz
//
//  Created by Olivier on 2/24/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLSlider.h"
#import "FLInvitationTexts.h"
#import "FLPreset.h"
#import "FLTransaction.h"

@interface FLHomeButton : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *defaultImg;
@property (nonatomic, retain) NSString *imgUrl;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic) Boolean soon;
@property (nonatomic, retain) NSArray *triggers;
@property (nonatomic, retain) NSDictionary *json;

- (id)initWithJSON:(NSDictionary *)json;

@end

@interface FLTexts : NSObject

@property (nonatomic, retain) NSString *balancePopupTitle;
@property (nonatomic, retain) NSString *balancePopupText;

@property (nonatomic, retain) NSString *friendSearch;
@property (nonatomic, retain) NSString *cardHolder;
@property (nonatomic, retain) NSString *audiotelNumber;
@property (nonatomic, retain) NSString *audiotelImage;
@property (nonatomic, retain) NSString *audiotelInfos;
@property (nonatomic, retain) NSString *card;
@property (nonatomic, retain) NSDictionary *notificationsText;
@property (nonatomic, retain) NSDictionary *json;
@property (nonatomic, retain) FLSlider *slider;
@property (nonatomic, retain) NSDictionary *couponButton;
@property (nonatomic, retain) NSDictionary *menu;
@property (nonatomic, retain) NSString *signupSponsor;
@property (nonatomic, retain) NSMutableArray *avalaibleCountries;
@property (nonatomic, retain) NSArray *homeButtons;
@property (nonatomic, retain) NSArray *homeTriggers;
@property (nonatomic, retain) NSArray *cashinButtons;
@property (nonatomic, retain) NSArray *paymentSources;
@property (nonatomic, retain) NSArray *suggestGif;
@property (nonatomic, retain) NSArray *suggestWeb;
@property (nonatomic, retain) NSArray *homeScopes;
@property (nonatomic, strong) FLNewFloozOptions *createFloozOptions;
@property (nonatomic, strong) FLTransactionOptions *floozOptions;

- (id)initWithJSON:(NSDictionary *)json;

@end
