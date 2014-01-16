//
//  UIImageView+custom.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "UIImageView+custom.h"

@implementation UIImageView (custom)

+ (instancetype)imageNamed:(NSString *)name
{
    return  [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
}

@end
