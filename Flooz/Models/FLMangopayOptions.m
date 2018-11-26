//
//  FLMangopayOptions.m
//  Flooz
//
//  Created by Olivier Mouren on 26/11/2018.
//  Copyright © 2018 Flooz. All rights reserved.
//

#import "FLMangopayOptions.h"

@implementation FLMangopayOptions

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        self.clientId = json[@"clientId"];
        self.baseURL = json[@"baseUrl"];
    }
    return self;
}

@end
