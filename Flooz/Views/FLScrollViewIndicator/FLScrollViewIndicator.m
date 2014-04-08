//
//  FLScrollViewIndicator.m
//  Flooz
//
//  Created by jonathan on 2014-04-03.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLScrollViewIndicator.h"

#define MIN_WIDTH 65
#define MARGIN_RIGHT 5

@implementation FLScrollViewIndicator

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(SCREEN_WIDTH - (MIN_WIDTH + MARGIN_RIGHT), 0, MIN_WIDTH, 30);
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.clipsToBounds = YES;
    
    self.backgroundColor = [UIColor customBackgroundHeader:.5];
    self.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.;
//    self.layer.borderColor = [UIColor customBlue].CGColor;
//    self.layer.borderWidth = 1;
    
    {
        label = [[JTImageLabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.frame) - 10, CGRectGetHeight(self.frame))];
        label.font = [UIFont customContentRegular:12];
        label.textColor = [UIColor whiteColor];
        
        [label setImage:[UIImage imageNamed:@"transaction-content-clock"]];
        [label setImageOffset:CGPointMake(-5, 0)];
        
        [self addSubview:label];
    }
}

- (void)setText:(NSString *)text
{
    label.text = text;
    CGRectSetWidth(label.frame, [label widthToFit] + 25);
    CGRectSetWidth(self.frame, CGRectGetWidth(label.frame) + 10);
    CGRectSetX(self.frame, SCREEN_WIDTH - (CGRectGetWidth(self.frame) + MARGIN_RIGHT));
}

@end
