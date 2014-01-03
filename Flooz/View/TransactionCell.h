//
//  TransactionCell.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLTransaction.h"

@interface TransactionCell : UITableViewCell

+ (CGFloat)getEstimatedHeight;
+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction;

@property (strong, nonatomic) FLTransaction *transaction;

@end
