//
//  FLTransaction.m
//  Flooz
//
//  Created by jonathan on 12/31/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "FLTransaction.h"

@implementation FLTransaction

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if(self){
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json
{
    _amount = [json objectForKey:@"amount"];
    _text = [json objectForKey:@"text"];
    _content = [json objectForKey:@"why"];

    _attachment_url = [json objectForKey:@"pic"];
    _attachment_thumb_url = [json objectForKey:@"picMini"];
        
    NSString *method = [json objectForKey:@"method"];
    if([method isEqualToString:@"pay"]){
        _type = TransactionTypePayment;
    }
    else{
        _type = TransactionTypeCollection;
    }
    
    NSNumber *state = [json objectForKey:@"state"];
    if([state integerValue] == 0){
        _status = TransactionStatusPending;
    }
    else if([state integerValue] == 1){
        _status = TransactionStatusAccepted;
    }
    else{
        _status = TransactionStatusRefused;
    }
}

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

- (NSString *)amountFormated{
    if(_amount){
        return [NSString stringWithFormat:@"+ $%@", _amount];
    }
    else{
        return nil;
    }
}

+ (NSArray *)testData{
    NSMutableArray *transactions = [NSMutableArray new];
    
    FLTransaction *transaction = nil;

    int i = 0;
    
    for(NSInteger type = TransactionTypePayment; type <= TransactionTypeCollection; ++type){
        for(NSInteger status = TransactionStatusAccepted; status <= TransactionStatusPending; ++status){
                        
            transaction = [FLTransaction new];
            transaction.type = type;
            transaction.status = status;
            transaction.text = @"koko a flooz avec kik";
            transaction.content = [NSString stringWithFormat:@"%d Merci pour le café ;)", ++i];
            [transactions addObject:transaction];
            
            transaction = [FLTransaction new];
            transaction.type = type;
            transaction.status = status;
             transaction.text = [NSString stringWithFormat:@"%d Ca roxe", ++i];
            [transactions addObject:transaction];
            
            transaction = [FLTransaction new];
            transaction.type = type;
            transaction.status = status;
             transaction.content = [NSString stringWithFormat:@"%d Plop plop plop", ++i];
            [transactions addObject:transaction];
            
        }
    }
        
    return transactions;
}

@end
