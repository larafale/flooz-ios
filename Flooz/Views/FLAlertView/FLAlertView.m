//
//  FLAlertView.m
//  Flooz
//
//  Created by jonathan on 2014-03-25.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLAlertView.h"

#import "AppDelegate.h"

#define STATUSBAR_HEIGHT 22.

#define MARGE_LEFT 78.
#define MARGE_RIGHT 20.
#define MARGE_BOTTOM 15.

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
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, 30, SCREEN_WIDTH - MARGE_LEFT - MARGE_RIGHT, 17)];
        titleView.font = [UIFont customTitleExtraLight:17];
        titleView.textColor = [UIColor whiteColor];
        
        [self addSubview:titleView];
    }
    
    {
        contentView = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, CGRectGetMaxY(titleView.frame) + 5, SCREEN_WIDTH - MARGE_LEFT - MARGE_RIGHT, 0)];
        contentView.font = [UIFont customContentRegular:12];
        contentView.textColor = [UIColor whiteColor];
        contentView.numberOfLines = 0;
        
        [self addSubview:contentView];
    }
    
    {
        iconView = [UIImageView imageNamed:@"alertview-success"];
        CGRectSetX(iconView.frame, 20);
        
        [self addSubview:iconView];
    }
}

- (void)show:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style
{
    [self show:title content:content style:style time:nil];
}

- (void)show:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time
{
    if(!time){
        time = @3;
    }
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:[time floatValue] target:self selector:@selector(hide) userInfo:nil repeats:NO];
    
    if(!self.superview){
        CGRectSetHeight(self.frame, 0);
        [appDelegate.window addSubview:self];
    }

    titleView.text = title;
    contentView.text = content;
    
    [contentView setHeightToFit];
    iconView.center = CGPointMake(iconView.center.x, (CGRectGetMaxY(contentView.frame) + MARGE_BOTTOM + STATUSBAR_HEIGHT) / 2.);
    
    [self setStyle:style];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.4 animations:^{
            CGRectSetHeight(self.frame, CGRectGetMaxY(contentView.frame) + MARGE_BOTTOM);
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
    NSString *imageName;
    
    switch (style) {
        case FLAlertViewStyleError:
            backgroundColor = [UIColor customRed];
            imageName = @"alertview-error";
            break;
        case FLAlertViewStyleSuccess:
            backgroundColor = [UIColor customGreen];
            imageName = @"alertview-success";
            break;
        case FLAlertViewStyleInfo:
            backgroundColor = [UIColor customBlue];
            imageName = @"alertview-info";
            break;
    }
    
    self.backgroundColor = backgroundColor;
    iconView.image = [UIImage imageNamed:imageName];
}

@end
