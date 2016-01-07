//
//  DealCell.h
//  Flooz
//
//  Created by Olive on 1/6/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLDeal.h"

@interface DealCell : UITableViewCell

+ (CGFloat)getHeight:(FLDeal *)deal;

- (void)setDeal:(FLDeal *)deal;

@end
