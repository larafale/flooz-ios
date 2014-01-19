//
//  RoundButton.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "RoundButton.h"

@implementation RoundButton

- (id)initWithPosition:(CGFloat)positionY imageName:(NSString *)imageName text:(NSString *)text;
{
    self = [super initWithFrame:CGRectMake((SCREEN_WIDTH - 101) / 2., positionY, 101, 101)];
    if (self) {
        [self createViewWithImageName:imageName text:text];
    }
    return self;
}

- (void)createViewWithImageName:(NSString *)imageName text:(NSString *)text
{
    self.hidden = YES;
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 50.;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 1.;
    
    UIImageView *image = [UIImageView imageNamed:imageName];
    image.center = CGRectGetCenter(self.frame);
    [self addSubview:image];
    
    UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    textView.textColor = [UIColor whiteColor];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.font = [UIFont customContentLight:13];
    
    textView.text = NSLocalizedString(text, nil);
    
    [self addSubview:textView];
}

- (void)startAnimationWithDelay:(NSTimeInterval)delay
{
    self.hidden = NO;
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0., 0.);
    
    [UIView animateWithDuration:0.2
                          delay:delay
                        options:0
                     animations:^{
                        self.transform =  CGAffineTransformIdentity;
    } completion:NULL];
}

@end
