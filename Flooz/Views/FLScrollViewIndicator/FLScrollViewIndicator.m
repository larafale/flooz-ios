//
//  FLScrollViewIndicator.m
//  Flooz
//
//  Created by jonathan on 2014-04-03.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLScrollViewIndicator.h"

#define WIDTH 265
#define MARGIN_RIGHT 5

#define LABEL_MARGIN 10.

@implementation FLScrollViewIndicator

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(SCREEN_WIDTH - (WIDTH + MARGIN_RIGHT), 0, WIDTH, 30);
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    {
        conainterView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame), 0, 0, CGRectGetHeight(self.frame))];
        
        conainterView.backgroundColor = [UIColor customBackgroundHeader:.5];
        conainterView.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.;
        conainterView.clipsToBounds = YES; // pour quand on anime que le texte ne depasse pas
        
        [self addSubview:conainterView];
    }
    
    {
        label = [[JTImageLabel alloc] initWithFrame:CGRectMake(LABEL_MARGIN, 0, 0, CGRectGetHeight(self.frame))];
        label.font = [UIFont customContentRegular:12];
        label.textColor = [UIColor whiteColor];
        
        [label setImage:[UIImage imageNamed:@"transaction-content-clock"]];
        [label setImageOffset:CGPointMake(-5, 0)];
        
        [conainterView addSubview:label];
    }
}

- (void)setText:(NSString *)text
{
    if([label.text isEqualToString:text]){
        return;
    }
    
    label.text = text;
    CGFloat newLabelWidth = [label widthToFit] + LABEL_MARGIN + 25; // 25 icone
    
    [UIView animateWithDuration:.5
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGRectSetWidth(label.frame, newLabelWidth);
                         CGRectSetWidth(conainterView.frame, newLabelWidth);
                         CGRectSetX(conainterView.frame,  CGRectGetWidth(self.frame) - newLabelWidth);
                     } completion:NULL];
}

@end
