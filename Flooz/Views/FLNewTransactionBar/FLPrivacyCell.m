//
//  FLPrivacyCell.m
//  Flooz
//
//  Created by Olivier on 2/19/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import "FLPrivacyCell.h"

@implementation FLPrivacyCell

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect imgFrame = [[self imageView] frame];
    imgFrame.origin.x = 10;
    imgFrame.size.height = 15;
    imgFrame.size.width = 15;
    imgFrame.origin.y = 5;
    [[self imageView] setFrame:imgFrame];
    
    CGRect textFrame = [[self textLabel] frame];
    textFrame.origin.x = 35;
    [[self textLabel] setFrame:textFrame];
}

@end
