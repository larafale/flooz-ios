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

@interface FLHomeButton : NSObject

@property (nonatomic, retain) NSString *defaultImg;
@property (nonatomic, retain) NSString *imgUrl;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic) Boolean soon;
@property (nonatomic, retain) NSArray *triggers;

- (id)initWithJSON:(NSDictionary *)json;

@end

@interface FLTexts : NSObject

@property (nonatomic, retain) NSString *cardHolder;
@property (nonatomic, retain) NSString *audiotelNumber;
@property (nonatomic, retain) NSString *card;
@property (nonatomic, retain) NSDictionary *notificationsText;
@property (nonatomic, retain) NSDictionary *json;
@property (nonatomic, retain) FLSlider *slider;
@property (nonatomic, retain) NSDictionary *couponButton;
@property (nonatomic, retain) NSDictionary *menu;
@property (nonatomic, retain) NSString *signupSponsor;
@property (nonatomic, retain) NSMutableArray *avalaibleCountries;
@property (nonatomic, retain) NSArray *homeButtons;
@property (nonatomic, retain) NSArray *cashinButtons;

- (id)initWithJSON:(NSDictionary *)json;

@end
