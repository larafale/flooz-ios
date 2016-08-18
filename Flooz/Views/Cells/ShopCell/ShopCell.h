//
//  ShopCell.h
//  Flooz
//
//  Created by Olive on 16/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLShopItem.h"

#define MARGIN_H 10
#define MARGIN_V 10

@interface ShopCell : UITableViewCell

+ (CGFloat)getHeight;

- (void)setShopItem:(FLShopItem *)item;

@end
