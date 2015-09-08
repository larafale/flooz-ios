//
//  FLTexts.h
//  Flooz
//
//  Created by Olivier on 2/24/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLSlider.h"
#import "FLInvitationTexts.h"

@interface FLTexts : NSObject

@property (nonatomic, retain) NSString *card;
@property (nonatomic, retain) NSDictionary *notificationsText;
@property (nonatomic, retain) NSDictionary *json;
@property (nonatomic, retain) FLSlider *slider;
@property (nonatomic, retain) NSDictionary *couponButton;
@property (nonatomic, retain) NSDictionary *menu;
@property (nonatomic, retain) NSMutableArray *avalaibleCountries;

- (id)initWithJSON:(NSDictionary *)json;

@end
