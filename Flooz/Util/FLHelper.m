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
    static NSNumberFormatter *formatter = nil;
    
    if(!formatter){
        formatter = [NSNumberFormatter new];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setGroupingSeparator:@""];
        [formatter setDecimalSeparator:@"."];
        [formatter setMinimumFractionDigits:2];
        [formatter setMaximumFractionDigits:2];
    }
    
    if(amount){
        return [NSString stringWithFormat:@"+ %@€", [formatter stringFromNumber:amount]];
    }
    else{
        return nil;
    }
}

@end
