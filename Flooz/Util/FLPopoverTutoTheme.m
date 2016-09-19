//
//  FLPopoverTutoTheme.m
//  Flooz
//
//  Created by Olivier on 2/26/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import "FLPopoverTutoTheme.h"

@implementation FLPopoverTutoTheme

+ (WYPopoverTheme *) theme {
    WYPopoverTheme *customTheme = [WYPopoverTheme theme];
    
    customTheme.tintColor = [UIColor customBlue];
    customTheme.fillTopColor = [UIColor customBlue];
    customTheme.fillBottomColor = [UIColor customBlue];
    
    customTheme.glossShadowColor = [UIColor clearColor];
    customTheme.glossShadowOffset = CGSizeMake(0, 0);
    customTheme.glossShadowBlurRadius = 0;
    
    customTheme.borderWidth = 10;
    customTheme.arrowBase = 20;
    customTheme.arrowHeight = 10;
    
    customTheme.outerShadowColor = [UIColor clearColor];
    customTheme.outerStrokeColor = [UIColor whiteColor];
    customTheme.outerShadowBlurRadius = 0;
    customTheme.outerShadowOffset = CGSizeMake(0, 0);
    customTheme.outerCornerRadius = 4;
    
    customTheme.innerShadowColor = [UIColor clearColor];
    customTheme.innerStrokeColor = [UIColor customBlue];
    customTheme.innerShadowBlurRadius = 0;
    customTheme.innerShadowOffset = CGSizeMake(0, 0);
    customTheme.innerCornerRadius = 4;
    
    customTheme.dimsBackgroundViewsTintColor = NO;

    return customTheme;
}

@end
