//
//  FLTexts.h
//  Flooz
//
//  Created by Epitech on 2/24/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLSlider.h"

@interface FLTexts : NSObject

@property (nonatomic, retain) NSString *shareCode;
@property (nonatomic, retain) NSString *shareTitle;
@property (nonatomic, retain) NSString *shareHeader;
@property (nonatomic, retain) NSString *shareSms;
@property (nonatomic, retain) NSString *shareTwitter;
@property (nonatomic, retain) NSDictionary *shareMail;
@property (nonatomic, retain) NSDictionary *shareFb;
@property (nonatomic, retain) NSArray *shareText;
@property (nonatomic, retain) NSDictionary *notificationsText;
@property (nonatomic, retain) NSDictionary *json;
@property (nonatomic, retain) FLSlider *slider;
@property (nonatomic, retain) NSDictionary *couponButton;

- (id)initWithJSON:(NSDictionary *)json;

@end
