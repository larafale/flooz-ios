//
//  FLShopItem.m
//  Flooz
//
//  Created by Olive on 16/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLShopItem.h"

@implementation FLShopItem

@synthesize type;
@synthesize itemId;
@synthesize name;
@synthesize pic;
@synthesize description;
@synthesize value;
@synthesize tosString;
@synthesize openTriggers;
@synthesize shareUrl;
@synthesize purchaseTriggers;

-(id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJson:json];
    }
    return self;
}

- (void)setJson:(NSDictionary *)json {
    if ([json[@"type"] isEqualToString:@"category"])
        self.type = ShopItemTypeCategory;
    else if ([json[@"type"] isEqualToString:@"card"])
        self.type = ShopItemTypeCard;
    
    self.itemId = json[@"_id"];
    self.name = json[@"name"];
    self.pic = json[@"pic"];
    self.description = json[@"description"];
    self.value = json[@"amountText"];
    self.tosString = json[@"tosUrl"];
    self.shareUrl = json[@"shareUrl"];
    
    if (json[@"action"]) {
        self.openTriggers = json[@"action"][@"open"];
        self.purchaseTriggers = json[@"action"][@"purchase"];
    } else {
        self.openTriggers = nil;
        self.purchaseTriggers = nil;
    }
}

@end
