//
//  TransactionCellDelegate.h
//  Flooz
//
//  Created by Olivier on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TransactionCellDelegate <NSObject>

- (void)didTransactionUserTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction;
- (void)didTransactionTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction;
- (void)updateTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction;
- (void)commentTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction;
- (FLTableView *)tableView;

@end
