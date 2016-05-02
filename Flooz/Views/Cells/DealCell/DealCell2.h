//
//  DealCell2.h
//  Flooz
//
//  Created by Olive on 1/8/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLDeal.h"
#import "MGSwipeTableCell.h"

@interface DealCell2 : MGSwipeTableCell

+ (CGFloat)getHeight:(FLDeal *)deal;

- (void)setDeal:(FLDeal *)deal;

@end
