//
//  NSString+custom.m
//  Flooz
//
//  Created by jonathan on 1/21/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "NSString+custom.h"

@implementation NSString (custom)

- (BOOL)isBlank
{
    return ([self isEqualToString:@""]);
}

@end
