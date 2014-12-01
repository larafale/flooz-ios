//
//  FLActivity.m
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLActivity.h"

@implementation FLActivity

- (id)initWithJSON:(NSDictionary *)json {
	self = [super init];
	if (self) {
		[self setJSON:json];
	}
	return self;
}

- (void)setJSON:(NSDictionary *)json {
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

	_when = [FLHelper formatedDateFromNow:_date];

    self.triggers = [NSMutableArray new];
    NSArray *t = json[@"triggers"];
    for (NSDictionary *trigger in t) {
        [self.triggers addObject:[[FLTrigger alloc] initWithJson:trigger]];
    }
}

@end
