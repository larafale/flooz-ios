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
    _transactionId = json[@"_id"];
    
    NSString *method = json[@"method"];
    if([method isEqualToString:@"pay"]){
        _type = TransactionTypePayment;
    }
    else if([method isEqualToString:@"collect"]){
        _type = TransactionTypeCollect;
    }
    else{
        _type = TransactionTypeCharge;
    }
    
    NSNumber *state = json[@"state"];
    
    if(!state){
        _status = TransactionStatusNone;
    }
    else if([state integerValue] == 0){
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
    
        
    _amount = json[@"amount"];
    if(_amount && [json[@"payer"] isEqualToNumber:@1]){
        _amount = [NSNumber numberWithFloat:([_amount floatValue] * -1.)];
    }
    
    
    if(json[@"avatar"]){
        _avatarURL = json[@"avatar"];
    }
    
    _title = json[@"text"];
    _content = json[@"why"];
    
    _attachmentURL = json[@"pic"];
    _attachmentThumbURL = json[@"picMini"];
    
    _social = [[FLSocial alloc] initWithJSON:json];
    
    _isPrivate = NO;
    if([json[@"currentScope"] isEqualToString:@"private"]){
        _isPrivate = YES;
    }
    
    {
        _isCancelable = NO;
        _isAcceptable = NO;
    
        if(_status == TransactionStatusPending){
            if([json[@"actions"] count] == 1){
                _isCancelable = YES;
            }
            else if([json[@"actions"] count] == 2){
                _isAcceptable = YES;
            }
        }
    }
    
    _from = [[FLUser alloc] initWithJSON:json[@"from"]];
    _to = [[FLUser alloc] initWithJSON:json[@"to"]];
    
    
    {
        static NSDateFormatter *dateFormatter;
        if(!dateFormatter){
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        }
                
        _date = [dateFormatter dateFromString:json[@"cAt"]];
    }
    
    {
        NSMutableArray *comments = [NSMutableArray new];
        for(NSDictionary *commentJSON in json[@"comments"]){
            [comments addObject:[[FLComment alloc] initWithJSON:commentJSON]];
        }
        _comments = comments;
    }
        
    _when = [FLHelper formatedDateFromNow:_date];
    
    if(json[@"text3d"]){
        _text3d = json[@"text3d"];
    }
    
    _isCollect = [json[@"isCollect"] boolValue];
    
    _collectCanParticipate = NO; //Collect removed
    if([[[[Flooz sharedInstance] currentUser] userId] isEqual:[_to userId]]){
        _collectCanParticipate = NO;
    }
    
    if(json[@"collect"]){
        NSMutableArray *colllectUsers = [NSMutableArray new];
        
        for(NSDictionary *userJSON in json[@"collect"][@"froms"]){
            [colllectUsers addObject:[[FLUser alloc] initWithJSON:userJSON]];
        }
        
        _collectUsers = colllectUsers;
    }
    
    _collectTitle = json[@"collect"][@"title"];
    
    _haveAction = NO;
    if(_isPrivate && _status == TransactionStatusPending){
        _haveAction = YES;
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
    else if(type == TransactionTypeCharge){
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
