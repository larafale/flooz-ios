//
//  FLAlertView.m
//  Flooz
//
//  Created by jonathan on 2014-03-25.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLAlertView.h"

#import "AppDelegate.h"

#define HEIGHT 84.

@implementation FLAlertView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.clipsToBounds = YES;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [self addGestureRecognizer:gesture];
    
    {
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 25)];
        
        [self addSubview:titleView];
    }
    
    {
        contentView = [[UILabel alloc] initWithFrame:CGRectMake(0, 20 + 25, SCREEN_WIDTH, 25)];
        
        [self addSubview:contentView];
    }
}

- (void)show:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style;
{
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hide) userInfo:nil repeats:NO];
    
    if(!self.superview){
        CGRectSetHeight(self.frame, 0);
        [appDelegate.window addSubview:self];
    }

    titleView.text = title;
    contentView.text = content;
    
    [self setStyle:style];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.4 animations:^{
            CGRectSetHeight(self.frame, HEIGHT);
        }];
    });
}

- (void)hide
{
    [timer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.4
                         animations:^{
                             CGRectSetHeight(self.frame, 0);
                         } completion:^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    });
}

- (void)setStyle:(FLAlertViewStyle)style
{
    UIColor *backgroundColor;
    UIColor *fontColor;
    
    switch (style) {
        case FLAlertViewStyleError:
            backgroundColor = [UIColor customRed];
            fontColor = [UIColor whiteColor];
            break;
        case FLAlertViewStyleSuccess:
            backgroundColor = [UIColor customGreen];
            fontColor = [UIColor whiteColor];
            break;
    }
    
    self.backgroundColor = backgroundColor;
    titleView.textColor = contentView.textColor = fontColor;
}

@end
