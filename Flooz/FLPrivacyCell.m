//
//  FLPrivacyCell.m
//  Flooz
//
//  Created by Epitech on 2/19/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLPrivacyCell.h"

@implementation FLPrivacyCell

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect imgFrame = [[self imageView] frame];
    imgFrame.origin.x = 10;
    [[self imageView] setFrame:imgFrame];
    
    CGRect textFrame = [[self textLabel] frame];
    textFrame.origin.x = 40;
    [[self textLabel] setFrame:textFrame];
}

@end
