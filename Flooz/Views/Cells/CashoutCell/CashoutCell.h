//
//  CashoutCell.h
//  Flooz
//
//  Created by Olive on 02/09/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CashoutCell : UITableViewCell

+ (CGFloat)getHeight;
- (void)setHistoryItem:(NSDictionary *)item;

@end
