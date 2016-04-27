//
//  FLActivity.m
//  Flooz
//
//  Created by Olive on 4/20/16.
//  Copyright © 2016 Flooz. All rights reserved.
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

    NSArray *splitType = [[json objectForKey:@"type"] componentsSeparatedByString:@":"];
    
    if ([splitType[0] isEqualToString:@"flooz"]) {
        _icon = @"home_sub_flooz";
    } else if ([splitType[0] isEqualToString:@"cash"]) {
        _icon = @"home_sub_cashin";
    } else if ([splitType[0] isEqualToString:@"pot"]) {
        _icon = @"home_sub_pot";
    } else if ([splitType[0] isEqualToString:@"card"]) {
        _icon = @"cashin_cb";
    }
    
    if ([splitType[1] isEqualToString:@"create"]) {
        _backIconColor = [UIColor customBlue];
    } else if ([splitType[1] isEqualToString:@"out"]) {
        _backIconColor = [UIColor customRed];
    } else if ([splitType[1] isEqualToString:@"int"]) {
        _backIconColor = [UIColor customGreen];
    }
    
    _content = [json objectForKey:@"text"];
    _imgURL = [json objectForKey:@"imageURL"];
    _triggers = [FLTriggerManager convertDataInList:json[@"triggers"]];
    
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
}

@end
