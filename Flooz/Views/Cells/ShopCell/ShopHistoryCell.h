//
//  ShopHistoryCell.h
//  Flooz
//
//  Created by Olive on 01/09/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopHistoryCell : UITableViewCell

+ (CGFloat)getHeight;

- (void)setShopHistoryItem:(NSDictionary *)item;

@end
