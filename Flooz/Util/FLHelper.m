//
//  FLHelper.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLHelper.h"
#import "YLMoment.h"

@implementation FLHelper

+ (NSString *)generateRandomString {
	const int randomStringLength = 16;
	NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
	NSMutableString *randomString = [NSMutableString stringWithCapacity:randomStringLength];

	for (int i = 0; i < randomStringLength; i++) {
		[randomString appendFormat:@"%C", [letters characterAtIndex:(arc4random() % [letters length])]];
	}

	return randomString;
}

+ (NSString *)formatedAmount:(NSNumber *)amount {
	return [self formatedAmount:amount withCurrency:YES withSymbol:YES];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency {
	return [self formatedAmount:amount withCurrency:withCurrency withSymbol:YES];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withSymbol:(BOOL)withSymbol {
	return [self formatedAmount:amount withCurrency:YES withSymbol:withSymbol];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency withSymbol:(BOOL)withSymbol;
{
	static NSNumberFormatter *formatter = nil;
	static NSString *currency = nil;

	if (!formatter) {
		formatter = [NSNumberFormatter new];
		[formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
		[formatter setGroupingSeparator:@""];
		[formatter setDecimalSeparator:@"."];
		[formatter setMinimumFractionDigits:0];
		[formatter setMaximumFractionDigits:2];

		currency = NSLocalizedString(@"GLOBAL_EURO", nil);
	}

	if (!amount) {
		return nil;
	}

	NSString *prefix = @"";
	NSString *suffix = @"";

	if (withSymbol) {
		if ([amount floatValue] > 0) {
			prefix = @"+ ";
		}
		else if ([amount floatValue] < 0) {
			prefix = @"- ";
		}
	}

	if (withCurrency) {
		suffix = [NSString stringWithFormat:@" %@", currency];
	}

	NSNumber *absoluteValue = [NSNumber numberWithFloat:fabsf([amount floatValue])];
	NSString *amountString = [formatter stringFromNumber:absoluteValue];

	// Si 1 seul chiffre apres la virguel
	NSRange rangeDot = [amountString rangeOfString:@"."];
	if (rangeDot.location == amountString.length - 2) {
		amountString = [amountString stringByAppendingString:@"0"];
	}

	return [NSString stringWithFormat:@"%@%@%@", prefix, amountString, suffix];
}

+ (NSString *)formatedDate:(NSDate *)date {
	static NSDateFormatter *dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateFormat:@"dd MMM 'à' HH:mm"];
	}

	if (date) {
		return [dateFormatter stringFromDate:date];
	}

	return nil;
}

+ (NSString *)hourInDate:(NSDate *)date {
	static NSDateFormatter *dateFormatter;
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateFormat:@"HH:mm"];
	}

	if (date) {
		return [dateFormatter stringFromDate:date];
	}

	return nil;
}

+ (NSString *)momentWithDate:(NSDate *)date {
	NSString *momentForDate = @"";

	NSDate *day = [NSDate date];
	if ([date isEqualToDay:day]) {
        NSString *moment = [self momentWithDate:date compareToDate:day];
        if ([moment length]) {
            momentForDate = [NSString stringWithFormat:@"il y a %@", moment];
        }
        else {
            momentForDate = @"à l'instant";
        }
	}
	else {
		day = [[NSDate date] dateByAddingDays:-1];
		if ([date isEqualToDay:day]) {
			momentForDate = [NSString stringWithFormat:@"hier, %@", [FLHelper hourInDate:date]];
		}
		else {
			day = [[NSDate date] dateByAddingDays:-2];
			if ([date isEqualToDay:day]) {
				momentForDate = [NSString stringWithFormat:@"avant-hier, %@", [FLHelper hourInDate:date]];
			}
			else {
				momentForDate = [FLHelper formatedDate:date];
			}
		}
	}
	return momentForDate;
}

+ (NSString *)momentWithDate:(NSDate *)date compareToDate:(NSDate *)dateToCompare {
	// Compute the time interval
	double referenceTime = [dateToCompare timeIntervalSinceDate:date];
	double seconds       = round(fabs(referenceTime));
	double minutes       = trunc(seconds / 60.0f);
	double hours         = trunc(minutes / 60.0f);

	// Build the formatted string
	NSString *formattedString = @"";
	int unit                  = 0;
	if (seconds < 20) {
		formattedString = @"";
	}
	else if (seconds < 60) {
		formattedString = @"sec";
		unit = seconds;
		formattedString = [NSString stringWithFormat:@"%d %@", (int)unit, formattedString];
	}
	else if (minutes < 60) {
		formattedString = @"min";
		unit = minutes;
		formattedString = [NSString stringWithFormat:@"%d %@", (int)unit, formattedString];
	}
	else if (hours < 24) {
		formattedString = @"h";
		unit = hours;
		formattedString = [NSString stringWithFormat:@"%d %@", (int)unit, formattedString];
	}
	else {
		formattedString = [FLHelper formatedDate:date];
	}

	return formattedString;
}

+ (NSString *)formatedDateFromNow:(NSDate *)date {
	if (!date) {
		return nil;
	}

	YLMoment *moment = [YLMoment momentWithDate:date];
	return [moment fromNow];
}

+ (NSString *)formatedPhone:(NSString *)phone {
	NSString *formatedPhone = [[[[[[phone stringByReplacingOccurrencesOfString:@" " withString:@""]
	                               stringByReplacingOccurrencesOfString:@" " withString:@""]
	                              stringByReplacingOccurrencesOfString:@"." withString:@""]
	                             stringByReplacingOccurrencesOfString:@"-" withString:@""]
	                            stringByReplacingOccurrencesOfString:@")" withString:@""]
	                           stringByReplacingOccurrencesOfString:@"(" withString:@""];

	if ([formatedPhone hasPrefix:@"+33"]) {
		formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"0"];
	}

	if ([formatedPhone hasPrefix:@"0033"]) {
		formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@"0"];
	}

	if ([formatedPhone length] != 10) {
		formatedPhone = nil;
	}

	if (![formatedPhone hasPrefix:@"06"] && ![formatedPhone hasPrefix:@"07"]) {
		formatedPhone = nil;
	}

	if (formatedPhone) {
		if ([formatedPhone hasPrefix:@"06"] || [formatedPhone hasPrefix:@"07"]) {
			formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"+33"];
		}
	}

	return formatedPhone;
}

+ (NSString *)formatedPhone2:(NSString *)phone {
    NSString *formatedPhone = [[[[[[phone stringByReplacingOccurrencesOfString:@" " withString:@""]
                                   stringByReplacingOccurrencesOfString:@" " withString:@""]
                                  stringByReplacingOccurrencesOfString:@"." withString:@""]
                                 stringByReplacingOccurrencesOfString:@"-" withString:@""]
                                stringByReplacingOccurrencesOfString:@")" withString:@""]
                               stringByReplacingOccurrencesOfString:@"(" withString:@""];
    
    if ([formatedPhone hasPrefix:@"+33"]) {
        formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"0"];
    }
    
    if ([formatedPhone hasPrefix:@"0033"]) {
        formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@"0"];
    }
    
    if ([formatedPhone length] < 3) {
        formatedPhone = nil;
    }
    
    if (![formatedPhone hasPrefix:@"06"] && ![formatedPhone hasPrefix:@"07"]) {
        formatedPhone = nil;
    }
    
    if (formatedPhone) {
        if ([formatedPhone hasPrefix:@"06"] || [formatedPhone hasPrefix:@"07"]) {
            formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"+33"];
        }
    }
    
    return formatedPhone;
}


+ (NSString *)formatedPhoneForDisplay:(NSString *)phone {
	if (!phone) {
		return nil;
	}


	NSString *formattedPhone;
	int i = 0;
	if ([phone hasPrefix:@"+33"]) {
		formattedPhone = [phone substringWithRange:NSMakeRange(i, 4)];
		i = 4;
	}
	else if ([phone hasPrefix:@"06"] || [phone hasPrefix:@"07"]) {
		formattedPhone = [phone substringWithRange:NSMakeRange(i, 2)];
		i = 2;
	}

	while (i < phone.length) {
		formattedPhone = [NSString stringWithFormat:@"%@ %@", formattedPhone, [phone substringWithRange:NSMakeRange(i, 2)]];
		i += 2;
	}

	return formattedPhone;
}

+ (void)addMotionEffect:(UIView *)view {
	// Set vertical effect
	UIInterpolatingMotionEffect *verticalMotionEffect =
	    [[UIInterpolatingMotionEffect alloc]
	 initWithKeyPath:@"center.y"
	            type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
	verticalMotionEffect.minimumRelativeValue = @(-20);
	verticalMotionEffect.maximumRelativeValue = @(20);

	// Set horizontal effect
	UIInterpolatingMotionEffect *horizontalMotionEffect =
	    [[UIInterpolatingMotionEffect alloc]
	 initWithKeyPath:@"center.x"
	            type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
	horizontalMotionEffect.minimumRelativeValue = @(-20);
	horizontalMotionEffect.maximumRelativeValue = @(20);

	// Create group to combine both
	UIMotionEffectGroup *group = [UIMotionEffectGroup new];
	group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];

	[view addMotionEffect:group];
}

@end
