//
//  FLMangopayOptions.h
//  Flooz
//
//  Created by Olivier Mouren on 26/11/2018.
//  Copyright © 2018 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLMangopayOptions : NSObject

@property (nonatomic, retain) NSString *baseURL;
@property (nonatomic, retain) NSString *clientId;

- (id)initWithJSON:(NSDictionary *)json;

@end
