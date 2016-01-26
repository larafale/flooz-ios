//
//  FLCountry.h
//  Flooz
//
//  Created by Epitech on 9/8/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLCountry : NSObject

@property (strong, nonatomic) NSString *countryId;
@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneCode;
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSNumber *numLength;

- (id)initWithJSON:(NSDictionary *)json;

+ (FLCountry *) defaultCountry;
+ (FLCountry *) countryFromCode:(NSString *)code;
+ (FLCountry *) countryFromIndicatif:(NSString *)indicatif;

@end
