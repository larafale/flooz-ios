//
//  FLTransaction.m
//  Flooz
//
//  Created by olivier on 12/31/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "FLTransaction.h"

@implementation FLTransaction

- (id)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json {
    _json = json;
    _transactionId = [json objectForKey:@"_id"];
    
    NSString *method = [json objectForKey:@"method"];
    if ([method isEqualToString:@"pay"]) {
        _type = TransactionTypePayment;
    }
    else if ([method isEqualToString:@"collect"]) {
        _type = TransactionTypeCollect;
    }
    else {
        _type = TransactionTypeCharge;
    }
    
    NSNumber *state = [json objectForKey:@"state"];
    
    if (!state) {
        _status = TransactionStatusNone;
    }
    else if ([state integerValue] == 0) {
        _status = TransactionStatusPending;
    }
    else if ([state integerValue] == 1) {
        _status = TransactionStatusAccepted;
    }
    else if ([state integerValue] == 2) {
        _status = TransactionStatusRefused;
    }
    else if ([state integerValue] == 3) {
        _status = TransactionStatusCanceled;
    }
    else if ([state integerValue] == 4) {
        _status = TransactionStatusExpired;
    }
    
    _amount = [json objectForKey:@"amount"];
    if (_amount && [[json objectForKey:@"payer"] isEqualToNumber:@1]) {
        _amount = [NSNumber numberWithFloat:([_amount floatValue] * -1.)];
    }
    
    if (json[@"amountText"]) {
        _amountText = json[@"amountText"];
    }
    
    if ([json objectForKey:@"avatar"]) {
        _avatarURL = json[@"avatar"];
    }
    
    _name = [json objectForKey:@"name"];
    _title = [json objectForKey:@"text"];
    _content = [json objectForKey:@"why"];
    
    _participants = [json objectForKey:@"participants"];
    
    _location = [json objectForKey:@"location"];
    
    _isCollect = NO;
    if ([json objectForKey:@"isPot"]) {
        _isCollect = [[json objectForKey:@"isPot"] boolValue];
    }
    
    if (_location && [_location isBlank])
        _location = nil;
    
    _attachmentURL = [json objectForKey:@"pic"];
    _attachmentThumbURL = [json objectForKey:@"picMini"];
    
    if (!_attachmentURL.length)
        _attachmentURL = nil;
    
    if (!_attachmentThumbURL.length)
        _attachmentThumbURL = nil;
    
    _social = [[FLSocial alloc] initWithJSON:json];
    
    _isCancelable = NO;
    _isAcceptable = NO;
    
    if (_status == TransactionStatusPending) {
        if ([[json objectForKey:@"actions"] count] == 2) {
            _isAcceptable = YES;
        }
    }
    
    _isAvailable = NO;
    _isClosable = NO;
    
    if ([json objectForKey:@"actions"] && _isCollect) {
        if ([[json objectForKey:@"actions"] containsObject:@"participate"]) {
            _isAvailable = YES;
        }
        
        if ([[json objectForKey:@"actions"] containsObject:@"close"]) {
            _isClosable = YES;
        }
    }
    
    _from = [[FLUser alloc] initWithJSON:[json objectForKey:@"from"]];
    _to = [[FLUser alloc] initWithJSON:[json objectForKey:@"to"]];
    
    NSString *starterId = [[json objectForKey:@"starter"] objectForKey:@"_id"];
    
    if ([starterId isEqualToString:_from.userId])
        _starter = _from;
    else
        _starter = _to;
    
    {
        static NSDateFormatter *dateFormatter;
        if (!dateFormatter) {
            dateFormatter = [NSDateFormatter new];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        }
        
        _date = [dateFormatter dateFromString:[json objectForKey:@"cAt"]];
    }
    
    {
        NSMutableArray *comments = [NSMutableArray new];
        for (NSDictionary *commentJSON in [json objectForKey:@"comments"]) {
            FLComment *comment = [[FLComment alloc] initWithJSON:commentJSON];
            if (comment) {
                [comments addObject:comment];
            }
        }
        _comments = comments;
    }
    
    if ([[Flooz sharedInstance] isConnectionAvailable] && [json objectForKey:@"when"]) {
        _when = [json objectForKey:@"when"];
    } else {
        _when = [FLHelper formatedDateFromNow:_date];
    }
    
    if ([json objectForKey:@"text3d"]) {
        _text3d = [json objectForKey:@"text3d"];
    }
    
    _haveAction = NO;
    if (_isAcceptable) {
        _haveAction = YES;
    }
}

- (NSString *)statusText {
    if ([self status] == TransactionStatusAccepted) {
        return NSLocalizedString(@"TRANSACTION_STATUS_ACCEPTED", nil);
    }
    else if ([self status] == TransactionStatusRefused) {
        return NSLocalizedString(@"TRANSACTION_STATUS_REFUSED", nil);
    }
    else if ([self status] == TransactionStatusPending) {
        return NSLocalizedString(@"TRANSACTION_STATUS_PENDING", nil);
    }
    else if ([self status] == TransactionStatusCanceled) {
        return NSLocalizedString(@"TRANSACTION_STATUS_CANCELED", nil);
    }
    else { // if([self status] == TransactionStatusExpired){
        return NSLocalizedString(@"TRANSACTION_STATUS_EXPIRED", nil);
    }
}

+ (NSString *)transactionScopeToText:(TransactionScope)scope {
    NSString *key = nil;
    
    if (scope == TransactionScopePublic)
        key = @"PUBLIC";
    else if (scope == TransactionScopeFriend)
        key = @"FRIEND";
    else // if(status == TransactionScopePrivate){
        key = @"PRIVATE";
    
    return NSLocalizedString([@"TRANSACTION_SCOPE_" stringByAppendingString: key], nil);
}

+ (UIImage *)transactionScopeToImage:(TransactionScope)scope {
    NSString *key = nil;
    
    if (scope == TransactionScopePublic)
        key = @"transaction-scope-public";
    else if (scope == TransactionScopeFriend)
        key = @"transaction-scope-friend";
    else // if(status == TransactionScopePrivate){
        key = @"transaction-scope-private";
    
    return [UIImage imageNamed:key];
}

+ (NSString *)transactionStatusToParams:(TransactionStatus)status {
    if (status == TransactionStatusAccepted)
        return @"accept";
    else if (status == TransactionStatusRefused)
        return @"decline";
    else if (status == TransactionStatusCanceled)
        return @"cancel";
    else
        return @"";
}

+ (TransactionScope)transactionParamsToScope:(NSString *)param {
    if (param) {
        if ([param isEqualToString:@"public"])
            return TransactionScopePublic;
        if ([param isEqualToString:@"friend"])
            return TransactionScopeFriend;
        if ([param isEqualToString:@"private"])
            return TransactionScopePrivate;
        if ([param isEqualToString:@"all"])
            return TransactionScopeAll;
    }
    return TransactionScopePublic;
}

+ (NSString *)transactionScopeToParams:(TransactionScope)scope {
    if (scope == TransactionScopePublic)
        return @"public";
    else if (scope == TransactionScopeFriend)
        return @"friend";
    else if (scope == TransactionScopePrivate)
        return @"private";
    else if (scope == TransactionScopeAll)
        return @"all";
    
    return @"";
}

+ (NSString *)transactionScopeToTextParams:(TransactionScope)scope {
    if (scope == TransactionScopePublic)
        return @"public";
    else if (scope == TransactionScopeFriend)
        return @"friend";
    else if (scope == TransactionScopePrivate)
        return @"private";
    
    return @"";
}

+ (NSString *)transactionTypeToParams:(TransactionType)type {
    if (type == TransactionTypePayment)
        return @"pay";
    else if (type == TransactionTypeCharge)
        return @"charge";
    else
        return @"base";
}

+ (NSString *)transactionPaymentMethodToParams:(TransactionPaymentMethod)paymentMethod {
    if (paymentMethod == TransactionPaymentMethodWallet)
        return @"balance";
    else
        return @"card";
}

@end
