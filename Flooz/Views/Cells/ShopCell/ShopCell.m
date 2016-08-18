//
//  ShopCell.m
//  Flooz
//
//  Created by Olive on 16/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ShopCell.h"

@implementation ShopCell

+ (CGFloat)getHeight {
    return [FLHelper cardScaleHeightFromWidth:(PPScreenWidth() - (MARGIN_H * 2))] + (MARGIN_V * 2);
}

- (void)setShopItem:(FLShopItem *)item {
    
}

@end
