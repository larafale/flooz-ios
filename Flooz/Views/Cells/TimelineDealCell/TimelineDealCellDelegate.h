//
//  TimelineDealCellDelegate.h
//  Flooz
//
//  Created by Olive on 1/21/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimelineDealCellDelegate <NSObject>

- (void)didDealUserTouchAtIndex:(NSIndexPath *)indexPath deal:(FLTimelineDeal *)deal;
- (void)didDealTouchAtIndex:(NSIndexPath *)indexPath deal:(FLTimelineDeal *)deal;
- (void)updateDealAtIndex:(NSIndexPath *)indexPath deal:(FLTimelineDeal *)deal;
- (void)commentDealAtIndex:(NSIndexPath *)indexPath deal:(FLTimelineDeal *)deal;
- (FLTableView *)tableView;

@end
