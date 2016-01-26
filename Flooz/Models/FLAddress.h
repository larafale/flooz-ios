//
//  FLAddress.h
//  Flooz
//
//  Created by Olive on 1/22/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLAddress : NSObject

@property (nonatomic, strong) NSString *addressId;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *zip;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *hint;
@property (nonatomic, strong) FLCountry *country;

- (id)initWithJSON:(NSDictionary *)json;

@end
