//
//  FLHelper.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLHelper.h"

@implementation FLHelper

+ (NSString *)formatedAmount:(NSNumber *)amount
{
    return [self formatedAmount:amount withCurrency:YES withSymbol:YES];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency
{
    return [self formatedAmount:amount withCurrency:withCurrency withSymbol:YES];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withSymbol:(BOOL)withSymbol
{
    return [self formatedAmount:amount withCurrency:YES withSymbol:withSymbol];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency withSymbol:(BOOL)withSymbol;
{
    static NSNumberFormatter *formatter = nil;
    static NSString *currency = nil;
    
    if(!formatter){
        formatter = [NSNumberFormatter new];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGroupingSeparator:@""];
        [formatter setDecimalSeparator:@"."];
        [formatter setMinimumFractionDigits:0];
        [formatter setMaximumFractionDigits:2];
        
        currency = NSLocalizedString(@"GLOBAL_EURO", nil);
    }
    
    if(!amount){
        return nil;
    }
    
    NSString *prefix = @"";
    NSString *suffix = @"";
    
    if(withSymbol){
        if([amount floatValue] > 0){
            prefix = @"+ ";
        }
        else if([amount floatValue] < 0){
            prefix = @"- ";
        }
    }
        
    if(withCurrency){
        suffix = [NSString stringWithFormat:@" %@", currency];
    }
    
    NSNumber *absoluteValue = [NSNumber numberWithFloat:fabsf([amount floatValue])];
    NSString *amountString = [formatter stringFromNumber:absoluteValue];
    
    // Si 1 seul chiffre apres la virguel
    NSRange rangeDot = [amountString rangeOfString:@"."];
    if(rangeDot.location == amountString.length - 2){
        amountString = [amountString stringByAppendingString:@"0"];
    }
    
    return [NSString stringWithFormat:@"%@%@%@", prefix, amountString, suffix];
}

+ (NSString *)formatedDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"dd'/'MM'/'yy"];
    }
    
    if(date){
        return [dateFormatter stringFromDate:date];
    }
    
    return nil;
}

+ (NSString *)formatedPhone:(NSString *)phone{
    NSString *formatedPhone = [[[[phone stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]
        stringByReplacingOccurrencesOfString:@"." withString:@""]
        stringByReplacingOccurrencesOfString:@"-" withString:@""];

    if([formatedPhone hasPrefix:@"+33"]){
        formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"0"];
    }
    
    if([formatedPhone length] != 10){
        formatedPhone = nil;
    }

    if(![formatedPhone hasPrefix:@"06"] && ![formatedPhone hasPrefix:@"07"]){
        formatedPhone = nil;
    }
    
    return formatedPhone;
}

+ (NSString *)formatedPhoneForDisplay:(NSString *)phone
{
    if(!phone){
        return nil;
    }
    
    NSString *formattedPhone = [phone substringWithRange:NSMakeRange(0, 2)];
    
    for(int i = 2; i < phone.length; i += 2){
        formattedPhone = [NSString stringWithFormat:@"%@ %@", formattedPhone, [phone substringWithRange:NSMakeRange(i, 2)]];
    }
    
    return formattedPhone;
}

@end
