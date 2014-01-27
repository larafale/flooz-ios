//
//  FLAccountButton.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLAccountButton.h"

@implementation FLAccountButton

- (id)initWithFrame:(CGRect)frame title:(NSString *)title imageNamed:(NSString *)imageNamed
{
    frame = CGRectSetWidthHeight(frame, (SCREEN_WIDTH / 2.) + 2, 130);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViewWithTitle:title imageNamed:imageNamed];
    }
    return self;
}

- (void)createViewWithTitle:(NSString *)title imageNamed:(NSString *)imageNamed
{
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor customSeparator].CGColor;

    [self setBackgroundImage:[UIImage imageWithColor:[UIColor customBackground]] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor customBlueHover]] forState:UIControlStateHighlighted];
    
    [self setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateHighlighted];
    
    self.imageEdgeInsets = UIEdgeInsetsMake(- 17, 0, 0, 0);
    
    {
        UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        
        textView.textColor = [UIColor whiteColor];
        textView.textAlignment = NSTextAlignmentCenter;
        textView.font = [UIFont customTitleExtraLight:14];
        
        textView.text = title;
        
        [self addSubview:textView];
    }
}

@end
