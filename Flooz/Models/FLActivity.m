//
//  FLActivity.m
//  Flooz
//
//  Created by olivier on 2/14/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLActivity.h"

@implementation FLActivity

- (id)initWithJSON:(NSDictionary *)json {
	self = [super init];
	if (self) {
        if ([json objectForKey:@"text"] && ![[json objectForKey:@"text"] isBlank])
            [self setJSON:json];
        else
            return nil;
	}
	return self;
}

- (void)setJSON:(NSDictionary *)json {
    _activityId = [json objectForKey:@"_id"];
    _type = [self.class activityTypeParamToEnum:[json objectForKey:@"type"]];
	_content = [json objectForKey:@"text"];
	_user = [[FLUser alloc] initWithJSON:json[@"emitter"]];

	// Si 0 alors pas lu
	_isRead = [json[@"state"] intValue] != 0;

	_isFriend = NO;
    if ([json[@"type"] isEqualToString:@"line"] && json[@"resource"]) {
        _transactionId = json[@"resource"][@"lineId"];
    }
    else if ([json[@"type"] isEqualToString:@"friendRequest"] || [json[@"type"] isEqualToString:@"friendJoin"]
            || [json[@"type"] isEqualToString:@"friendRequestCancelled"]) {
        _isFriend = YES;
    }

	_isForCompleteProfil = NO;
	if ([json[@"type"] isEqualToString:@"completeProfile"]) {
		_isForCompleteProfil = YES;
	}
    
    _isForAvatarMissing = NO;
    if ([json[@"type"] isEqualToString:@"addAvatar"]) {
        _isForAvatarMissing = YES;
    }

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
		static NSDateFormatter *dateFormatter;
		if (!dateFormatter) {
			dateFormatter = [NSDateFormatter new];
			[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
			[dateFormatter setDateFormat:@"dd' 'MMMM', 'HH':'mm"];
			[dateFormatter setDateStyle:NSDateFormatterShortStyle];
			[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
			[dateFormatter setDoesRelativeDateFormatting:YES];
		}
		NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
		NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
		NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:_date];
		NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:_date];
		NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
		NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:_date];

		_dateText = [dateFormatter stringFromDate:destinationDate];
	}

    if ([[Flooz sharedInstance] isConnectionAvailable] && [json objectForKey:@"when"]) {
        _when = [json objectForKey:@"when"];
    } else {
        _when = [FLHelper formatedDateFromNow:_date];
    }
    
    self.triggers = [FLTriggerManager convertDataInList:json[@"triggers"]];
}

+(FLActivityType)activityTypeParamToEnum:(NSString *)param {
    
    FLActivityType type = CompleteProfile;
    
    if ([param isEqualToString:@"accountLocked"]) {
        type = AccountLocked;
    }
    else if ([param isEqualToString:@"accountUnlocked"]) {
        type = AccountUnlocked;
    }
    else if ([param isEqualToString:@"addAvatar"]) {
        type = AddAvatar;
    }
    else if ([param isEqualToString:@"cardExpired"]) {
        type = CardExpired;
    }
    else if ([param isEqualToString:@"cashout"]) {
        type = Cashout;
    }
    else if ([param isEqualToString:@"checkDeclined"]) {
        type = CheckDeclined;
    }
    else if ([param isEqualToString:@"commentsLine"]) {
        type = CommentsLine;
    }
    else if ([param isEqualToString:@"completeProfile"]) {
        type = CompleteProfile;
    }
    else if ([param isEqualToString:@"friendJoined"]) {
        type = FriendJoined;
    }
    else if ([param isEqualToString:@"friendRequest"]) {
        type = FriendRequest;
    }
    else if ([param isEqualToString:@"friendRequestCancelled"]) {
        type = FriendRequestCancelled;
    }
    else if ([param isEqualToString:@"lineExpired"]) {
        type = LineExpired;
    }
    else if ([param isEqualToString:@"lineExpiredReceiver"]) {
        type = LineExpiredReceiver;
    }
    else if ([param isEqualToString:@"likesLine"]) {
        type = LikesLine;
    }
    else if ([param isEqualToString:@"lineCharge"]) {
        type = LineCharge;
    }
    else if ([param isEqualToString:@"lineChargeDeclined"]) {
        type = LineChargeDeclined;
    }
    else if ([param isEqualToString:@"linePay"]) {
        type = LinePay;
    }
    else if ([param isEqualToString:@"linePreset"]) {
        type = LinePreset;
    }
    
    return type;
}

@end
