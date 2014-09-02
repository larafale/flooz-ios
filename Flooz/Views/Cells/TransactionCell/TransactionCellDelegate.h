//
//  TransactionCellDelegate.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TransactionCellDelegate <NSObject>

- (void)didTransactionTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction;
- (void)updateTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction;
- (void)commentTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction;
- (FLTableView *)tableView;
- (void)showPayementFieldAtIndex:(NSIndexPath *)indexPath;

- (BOOL)transactionAlreadyLoaded:(FLTransaction *)transaction;

@end
