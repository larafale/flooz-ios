//
//  FLShopItem.h
//  Flooz
//
//  Created by Olive on 16/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLShopItem : NSObject

typedef NS_ENUM (NSInteger, ShopItemType) {
    ShopItemTypeCard,
    ShopItemTypeCategory
};

@property (nonatomic) TransactionType type;

@property (nonatomic, retain) NSString *itemId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *pic;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) NSString *tosString;
@property (nonatomic, retain) NSString *shareUrl;

@property (nonatomic, retain) NSArray *openTriggers;
@property (nonatomic, retain) NSArray *purchaseTriggers;

-(id)initWithJson:(NSDictionary *)json;

@end
