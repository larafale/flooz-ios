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
    _transactionId = [json objectForKey:@"_id"];
    
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
    if(_amount && [[json objectForKey:@"payer"] isEqualToNumber:@1]){
        _amount = [NSNumber numberWithFloat:([_amount floatValue] * -1.)];
    }
        
    if([[json objectForKey:@"currentScope"] isEqualToString:@"private"]){
        _avatarURL = [[json objectForKey:[json objectForKey:@"myFriend"]] objectForKey:@"pic"];
    }
    else{
        if([[[json objectForKey:@"starter"] objectForKey:@"field"] isEqualToString:@"from"]){
            _avatarURL = [[json objectForKey:@"from"] objectForKey:@"pic"];
        }
        else{
            _avatarURL = [[json objectForKey:@"to"] objectForKey:@"pic"];
        }
    }
        
    _title = [json objectForKey:@"text"];
    _content = [json objectForKey:@"why"];
    
    _attachmentURL = [json objectForKey:@"pic"];
    _attachmentThumbURL = [json objectForKey:@"picMini"];
    
    _social = [[FLSocial alloc] initWithJSON:json];
    
    _isPrivate = NO;
    if([[json objectForKey:@"currentScope"] isEqualToString:@"private"]){
        _isPrivate = YES;
    }
    
    {
        _isCancelable = NO;
        _isAcceptable = NO;
    
        if(_status == TransactionStatusPending){
            if([[json objectForKey:@"actions"] count] == 1){
                _isCancelable = YES;
            }
            else if([[json objectForKey:@"actions"] count] == 2){
                _isAcceptable = YES;
            }
        }
    }
    
    _from = [[FLUser alloc] initWithJSON:[json objectForKey:@"from"]];
    _to = [[FLUser alloc] initWithJSON:[json objectForKey:@"to"]];
    
    
    {
        static NSDateFormatter *dateFormatter;
        if(!dateFormatter){
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        }
                
        _date = [dateFormatter dateFromString:[json objectForKey:@"cAt"]];
    }
    
    {
        NSMutableArray *comments = [NSMutableArray new];
        for(NSDictionary *commentJSON in [json objectForKey:@"comments"]){
            [comments addObject:[[FLComment alloc] initWithJSON:commentJSON]];
        }
        _comments = comments;
    }
    
    if([json objectForKey:@"event"] && [[json objectForKey:@"event"] objectForKey:@"_id"]){
        _eventId = [[json objectForKey:@"event"] objectForKey:@"_id"];
    }
    
    _when = [FLHelper formatedDateFromNow:_date];
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

- (NSString *)typeText
{
    if([self type] == TransactionTypePayment){
        return NSLocalizedString(@"TRANSACTION_TYPE_PAYMENT", nil);
    }
    else{
        return NSLocalizedString(@"TRANSACTION_TYPE_COLLECTION", nil);
    }
}

+ (NSString *)transactionScopeToText:(TransactionScope)scope
{
    NSString *key = nil;
    
    if(scope == TransactionScopePublic){
        key = @"PUBLIC";
    }
    else if(scope == TransactionScopeFriend){
        key = @"FRIEND";
    }
    else{ // if(status == TransactionScopePrivate){
        key = @"PRIVATE";
    }
    
    return NSLocalizedString([@"TRANSACTION_SCOPE_" stringByAppendingString:key], nil);
}

+ (UIImage *)transactionScopeToImage:(TransactionScope)scope
{
    NSString *key = nil;
    
    if(scope == TransactionScopePublic){
        key = @"scope-public-large-selected";
    }
    else if(scope == TransactionScopeFriend){
        key = @"scope-friend-large-selected";
    }
    else{ // if(status == TransactionScopePrivate){
        key = @"scope-private-large-selected";
    }
    
    return [UIImage imageNamed:key];
}

+ (NSString *)transactionStatusToParams:(TransactionStatus)status
{
    if(status == TransactionStatusAccepted){
        return @"accept";
    }
    else if(status == TransactionStatusRefused){
        return @"decline";
    }
    else if(status == TransactionStatusCanceled){
        return @"cancel";
    }
    else{
        NSLog(@"Bad TransactionStatus");
        return @"";
    }
}

+ (NSString *)transactionScopeToParams:(TransactionScope)scope
{
    if(scope == TransactionScopePublic){
        return @"0";
    }
    else if(scope == TransactionScopeFriend){
        return @"1";
    }
    else{ // if(status == TransactionScopePrivate){
        return @"2";
    }
}

+ (NSString *)transactionTypeToParams:(TransactionType)type
{
    if(type == TransactionTypePayment){
        return @"pay";
    }
    else if(type == TransactionTypeCollection){
        return @"charge";
    }
    else{ // if(type == TransactionTypeEvent){
        return @"event";
    }
}

+ (NSString *)transactionPaymentMethodToParams:(TransactionPaymentMethod)paymentMethod
{
    if(paymentMethod == TransactionPaymentMethodWallet){
        return @"balance";
    }
    else{
        return @"card";
    }
}

@end
