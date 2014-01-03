//
//  FLTransaction.m
//  Flooz
//
//  Created by jonathan on 12/31/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "FLTransaction.h"

@implementation FLTransaction

- (NSString *)typeText{
    if([self type] == TransactionTypePayment){
        return NSLocalizedString(@"TRANSACTION_TYPE_PAYMENT", nil);
    }else{
        return NSLocalizedString(@"TRANSACTION_TYPE_COLLECTION", nil);
    }
}

- (NSString *)statusText{
    if([self status] == TransactionStatusAccepted){
        return NSLocalizedString(@"TRANSACTION_STATUS_ACCEPTED", nil);
    }else if([self status] == TransactionStatusRefused){
        return NSLocalizedString(@"TRANSACTION_STATUS_REFUSED", nil);
    }else{
        return NSLocalizedString(@"TRANSACTION_STATUS_WAITING", nil);
    }
}

- (NSString *)amountText{
    return @"+ $3500";
}

- (NSString *)text{
    NSString *key = @"TRANSACTION_TEXT_";
    NSString *text = nil;
    
    if([self type] == TransactionTypePayment){
        key = [key stringByAppendingString:@"PAYMENT_"];
    }else{
        key = [key stringByAppendingString:@"COLLECTION_"];
    }
    
    if([self status] == TransactionStatusAccepted){
        key = [key stringByAppendingString:@"ACCEPTED_"];
    }else if([self status] == TransactionStatusRefused){
        key = [key stringByAppendingString:@"REFUSED_"];
    }else{
        key = [key stringByAppendingString:@"WAITING_"];
    }
    
    if([self from] != nil && [self to] != nil){
        key = [key stringByAppendingString:@"FROM_TO"];
        text = [NSString stringWithFormat:NSLocalizedString(key, nil), [self from], [self to]];
    }else if([self from] != nil){
        key = [key stringByAppendingString:@"FROM"];
        text = [NSString stringWithFormat:NSLocalizedString(key, nil), [self from]];
    }else{
        key = [key stringByAppendingString:@"TO"];
        text = [NSString stringWithFormat:NSLocalizedString(key, nil), [self to]];
    }
        
    return text;
}

+ (NSArray *)testTransactions{
    NSMutableArray *transactions = [NSMutableArray new];
    
    FLTransaction *transaction = nil;

    int i = 0;
    
    for(NSInteger type = TransactionTypePayment; type <= TransactionTypeCollection; ++type){
        for(NSInteger status = TransactionStatusAccepted; status <= TransactionStatusWaiting; ++status){
                        
            transaction = [FLTransaction new];
            transaction.type = type;
            transaction.status = status;
            transaction.from = @"John Tribouharet";
            transaction.to = @"Barth Chalvet";
            transaction.content = [NSString stringWithFormat:@"%d Merci pour le café ;)", ++i];
            [transactions addObject:transaction];
            
            transaction = [FLTransaction new];
            transaction.type = type;
            transaction.status = status;
            transaction.from = @"John";
             transaction.content = [NSString stringWithFormat:@"%d Ca roxe", ++i];
            [transactions addObject:transaction];
            
            transaction = [FLTransaction new];
            transaction.type = type;
            transaction.status = status;
            transaction.to = @"Barth";
             transaction.content = [NSString stringWithFormat:@"%d Plop plop plop", ++i];
            [transactions addObject:transaction];
            
        }
    }
        
    return transactions;
}

@end
