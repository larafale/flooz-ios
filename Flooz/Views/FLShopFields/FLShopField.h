//
//  FLShopField.h
//  Flooz
//
//  Created by Olive on 18/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SHOP_FIELD_HEIGHT 50

@interface FLShopField : UIView

@property (nonatomic, weak) NSDictionary *options;
@property (nonatomic, weak) NSMutableDictionary *dictionary;

- (id)initWithOptions:(NSDictionary *)options dic:(NSMutableDictionary *)dic;

@end
