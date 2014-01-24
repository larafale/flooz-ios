//
//  FLMenuNewTransactionButton.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLMenuNewTransactionButton.h"

@implementation FLMenuNewTransactionButton

- (id)initWithPosition:(CGFloat)positionY imageNamed:(NSString *)imageNamed title:(NSString *)title;
{
    self = [super initWithFrame:CGRectMake((SCREEN_WIDTH - 101) / 2., positionY, 101, 101)];
    if (self) {
        [self createViewWithImageNamed:imageNamed title:title];
    }
    return self;
}

- (void)createViewWithImageNamed:(NSString *)imageNamed title:(NSString *)title
{
    self.hidden = YES;
        
    self.backgroundColor = [UIColor customBackgroundHeader];
    
    self.layer.cornerRadius = 50.;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 1.;
        
    [self setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:imageNamed] forState:UIControlStateHighlighted];
    [self setImageEdgeInsets:UIEdgeInsetsMake(- 10, 0, 0, 0)];
    
    {
        UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        
        textView.textColor = [UIColor whiteColor];
        textView.textAlignment = NSTextAlignmentCenter;
        textView.font = [UIFont customContentLight:13];
        
        textView.text = NSLocalizedString(title, nil);
        
        [self addSubview:textView];
    }
}

- (void)startAnimationWithDelay:(NSTimeInterval)delay
{
    self.hidden = NO;

    CGPoint originalCenter = self.center;
    self.center = CGPointMake(self.center.x, self.center.y + 200);
    
    self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0., 0.);
    
    [UIView animateWithDuration:0.2
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.center = originalCenter;
                        self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.transform =  CGAffineTransformIdentity;
                         } completion:NULL];
    }];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if(highlighted){
        self.backgroundColor = [UIColor customBlueHover];
    }
    else{
        self.backgroundColor = [UIColor customBackgroundHeader];
    }
}

@end
