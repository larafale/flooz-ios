//
//  FLTransaction.m
//  Flooz
//
//  Created by jonathan on 12/31/2013.
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
	if (json[@"amountTextFull"]) {
		_amountTextFull = json[@"amountTextFull"];
	}

	if ([json objectForKey:@"avatar"]) {
		_avatarURL = json[@"avatar"];
	}

	_title = [json objectForKey:@"text"];
	_content = [json objectForKey:@"why"];

	_attachmentURL = [json objectForKey:@"pic"];
	_attachmentThumbURL = [json objectForKey:@"picMini"];
    
    if (!_attachmentURL.length)
        _attachmentURL = nil;

    if (!_attachmentThumbURL.length)
        _attachmentThumbURL = nil;

	_social = [[FLSocial alloc] initWithJSON:json];

	_isPrivate = NO;
	if ([[json objectForKey:@"currentScope"] isEqualToString:@"private"]) {
		_isPrivate = YES;
	}

	{
		_isCancelable = NO;
		_isAcceptable = NO;

		if (_status == TransactionStatusPending) {
			if ([[json objectForKey:@"actions"] count] == 1) {
				_isCancelable = YES;
			}
			else if ([[json objectForKey:@"actions"] count] == 2) {
				_isAcceptable = YES;
			}
		}
	}

	_from = [[FLUser alloc] initWithJSON:[json objectForKey:@"from"]];
	_to = [[FLUser alloc] initWithJSON:[json objectForKey:@"to"]];


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
		for (NSDictionary *commentJSON in[json objectForKey:@"comments"]) {
			FLComment *comment = [[FLComment alloc] initWithJSON:commentJSON];
			if (comment) {
				[comments addObject:comment];
			}
		}
		_comments = comments;
	}

	_when = [FLHelper formatedDateFromNow:_date];

	if ([json objectForKey:@"text3d"]) {
		_text3d = [json objectForKey:@"text3d"];
	}

	_isCollect = [[json objectForKey:@"isCollect"] boolValue];

	_collectCanParticipate = NO; //Collect removed
	if ([[[[Flooz sharedInstance] currentUser] userId] isEqual:[_to userId]]) {
		_collectCanParticipate = NO;
	}

	if ([json objectForKey:@"collect"]) {
		NSMutableArray *colllectUsers = [NSMutableArray new];

		for (NSDictionary *userJSON in json[@"collect"][@"froms"]) {
			FLUser *user = [[FLUser alloc] initWithJSON:userJSON];
			if (user) {
				[colllectUsers addObject:user];
			}
		}

		_collectUsers = colllectUsers;
	}

	_collectTitle = json[@"collect"][@"title"];

	_haveAction = NO;
	if (_isPrivate && _status == TransactionStatusPending) {
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

- (NSString *)typeText {
	if ([self type] == TransactionTypePayment) {
		return NSLocalizedString(@"TRANSACTION_TYPE_PAYMENT", nil);
	}
	else {
		return NSLocalizedString(@"TRANSACTION_TYPE_COLLECTION", nil);
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
		key = @"bar-scope-public";
	else if (scope == TransactionScopeFriend)
		key = @"bar-scope-friend";
	else // if(status == TransactionScopePrivate){
		key = @"bar-scope-private";

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
    if ([param isEqualToString:@"public"])
        return TransactionScopePublic;
    if ([param isEqualToString:@"friend"])
        return TransactionScopeFriend;
    if ([param isEqualToString:@"private"])
        return TransactionScopePrivate;
    return TransactionScopePublic;
}

+ (NSString *)transactionScopeToParams:(TransactionScope)scope {
	if (scope == TransactionScopePublic)
		return @"0";
	else if (scope == TransactionScopeFriend)
		return @"1";
	else // if(status == TransactionScopePrivate){
		return @"2";
}

+ (NSString *)transactionScopeToTextParams:(TransactionScope)scope {
    if (scope == TransactionScopePublic)
        return @"public";
    else if (scope == TransactionScopeFriend)
        return @"friend";
    else // if(status == TransactionScopePrivate){
        return @"private";
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
