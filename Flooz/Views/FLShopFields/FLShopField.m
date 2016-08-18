//
//  FLShopField.m
//  Flooz
//
//  Created by Olive on 18/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLShopField.h"

@implementation FLShopField

- (id)initWithOptions:(NSDictionary *)options dic:(NSDictionary *)dic {
    self = [super initWithFrame:CGRectMake(0, 0, PPScreenWidth(), SHOP_FIELD_HEIGHT)];
    if (self) {
        self.dictionary = dic;
        self.options = options;
    }
    return self;
}

@end
