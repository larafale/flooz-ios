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
    return [self formatedAmount:amount withCurrency:YES];
}

+ (NSString *)formatedAmount:(NSNumber *)amount withCurrency:(BOOL)withCurrency
{
    static NSNumberFormatter *formatter = nil;
    static NSString *currency = nil;
    
    if(!formatter){
        formatter = [NSNumberFormatter new];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGroupingSeparator:@""];
        [formatter setDecimalSeparator:@"."];
        [formatter setMinimumFractionDigits:2];
        [formatter setMaximumFractionDigits:2];
        
        currency = NSLocalizedString(@"GLOBAL_EURO", nil);
    }
        
    if(amount){
        if(withCurrency){
            if([amount floatValue] == 0){
                return [NSString stringWithFormat:@"%@%@", [formatter stringFromNumber:amount], currency];
            }
            else if([amount floatValue] > 0){
                return [NSString stringWithFormat:@"+ %@%@", [formatter stringFromNumber:amount], currency];
            }
            else{
                return [NSString stringWithFormat:@"- %.2f%@", fabsf([amount floatValue]), currency];
            }
        }
        else{
            if([amount floatValue] == 0){
                return @"0.00";
            }
            else if([amount floatValue] >= 0){
                return [NSString stringWithFormat:@"+ %@", [formatter stringFromNumber:amount]];
            }
            else{
                return [NSString stringWithFormat:@"- %.2f", fabsf([amount floatValue])];
            }
        }
    }
    else{
        return nil;
    }
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
        
    return formatedPhone;
}

@end
