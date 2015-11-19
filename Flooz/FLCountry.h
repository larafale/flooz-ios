//
//  FLCountry.h
//  Flooz
//
//  Created by Epitech on 9/8/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLCountry : NSObject

@property (strong, nonatomic) NSString *code;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *phoneCode;
@property (strong, nonatomic) NSString *imageName;

- (id)initWithJSON:(NSDictionary *)json;

+ (FLCountry *) defaultCountry;
+ (FLCountry *) countryFromCode:(NSString *)code;
<<<<<<< HEAD
=======
+ (FLCountry *) countryFromIndicatif:(NSString *)indicatif;
>>>>>>> 6365ab2

@end
