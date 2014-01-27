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
    else if([state integerValue] == 2){
        _status = TransactionStatusRefused;
    }
    else if([state integerValue] == 3){
        _status = TransactionStatusCanceled;
    }
    else if([state integerValue] == 4){
        _status = TransactionStatusExpired;
    }
    
    _amount = [json objectForKey:@"amount"];
    if(_amount && _type == TransactionTypePayment){
        _amount = [NSNumber numberWithFloat:([_amount floatValue] * -1.)];
    }
    
    if([[[json objectForKey:@"starter"] objectForKey:@"field"] isEqualToString:@"from"]){
        _avatarURL = [[json objectForKey:@"from"] objectForKey:@"pic"];
    }
    else{
        _avatarURL = [[json objectForKey:@"to"] objectForKey:@"pic"];
    }
    
    _text = [json objectForKey:@"text"];
    _why = [json objectForKey:@"why"];

    _attachmentURL = [json objectForKey:@"pic"];
    _attachmentThumbURL = [json objectForKey:@"picMini"];
    
    _social = [[FLSocial alloc] initWithJSON:json];
}

- (NSString *)typeText
{
    if([self type] == TransactionTypePayment){
        return NSLocalizedString(@"TRANSACTION_TYPE_PAYMENT", nil);
    }else{
        return NSLocalizedString(@"TRANSACTION_TYPE_COLLECTION", nil);
    }
}

- (NSString *)statusText
{
    if([self status] == TransactionStatusAccepted){
        return NSLocalizedString(@"TRANSACTION_STATUS_ACCEPTED", nil);
    }
    else if([self status] == TransactionStatusRefused){
        return NSLocalizedString(@"TRANSACTION_STATUS_REFUSED", nil);
    }
    else if([self status] == TransactionStatusPending){
        return NSLocalizedString(@"TRANSACTION_STATUS_PENDING", nil);
    }
    else if([self status] == TransactionStatusCanceled){
        return NSLocalizedString(@"TRANSACTION_STATUS_CANCELED", nil);
    }
    else{ // if([self status] == TransactionStatusExpired){
        return NSLocalizedString(@"TRANSACTION_STATUS_EXPIRED", nil);
    }
}

+ (NSArray *)testData
{
    NSMutableArray *transactions = [NSMutableArray new];
    
    FLTransaction *transaction = nil;

    int i = 0;
    
    for(NSInteger type = TransactionTypePayment; type <= TransactionTypeCollection; ++type){
        for(NSInteger status = TransactionStatusAccepted; status <= TransactionStatusExpired; ++status){
                        
            transaction = [FLTransaction new];
            transaction.type = type;
            transaction.status = status;
            transaction.text = @"koko a flooz avec kik";
            transaction.why = [NSString stringWithFormat:@"%d Merci pour le café ;)", ++i];
            [transactions addObject:transaction];
            
            transaction = [FLTransaction new];
            transaction.type = type;
            transaction.status = status;
             transaction.text = [NSString stringWithFormat:@"%d Ca roxe", ++i];
            [transactions addObject:transaction];
            
            transaction = [FLTransaction new];
            transaction.type = type;
            transaction.status = status;
             transaction.why = [NSString stringWithFormat:@"%d Plop plop plop", ++i];
            [transactions addObject:transaction];
            
        }
    }
        
    return transactions;
}

@end
