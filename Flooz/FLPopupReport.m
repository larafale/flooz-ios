//
//  FLPopupReport.m
//  Flooz
//
//  Created by Epitech on 11/21/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "FLPopupReport.h"

#define MARGE 30.
#define PADDING_TOP_BOTTOM 30.
#define PADDING_LEFT_RIGHT 30.
#define BUTTON_HEIGHT 50.
#define ANIMATION_DELAY 0.4

@implementation FLPopupReport

- (id)initWithReport:(FLReport*)rep {
    CGRect frame = CGRectMake(MARGE, 150, SCREEN_WIDTH - 2 * MARGE, 0);
    self = [super initWithFrame:frame];
    if (self) {
        self.report = rep;
        [self commmonInit];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoveWindowSubviews) name:kNotificationRemoveWindowSubviews object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commmonInit {
    [FLHelper addMotionEffect:self];
    
    CGFloat height = 15;
    
    {
        self.backgroundColor = [UIColor customBlue];
        self.layer.borderWidth = 1.;
        self.layer.borderColor = [UIColor customSeparator].CGColor;
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(-1, -1);
        self.layer.shadowOpacity = .5;
    }
    
    {
        UIImageView *view = [UIImageView imageNamed:@"white-logo"];
        view.contentMode = UIViewContentModeScaleAspectFit;
        
        CGRectSetHeight(view.frame, 40);
        CGRectSetXY(view.frame, (CGRectGetWidth(self.frame) - CGRectGetWidth(view.frame)) / 2., height);
        
        [self addSubview:view];
        
        height += CGRectGetHeight(view.frame);
    }
    
    height += 15;
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, height, CGRectGetWidth(self.frame) - 2 * PADDING_LEFT_RIGHT, 0)];
        
        view.font = [UIFont customContentBold:17];
        view.textColor = [UIColor whiteColor];
        view.textAlignment = NSTextAlignmentCenter;
        view.numberOfLines = 0;
        
        view.text = NSLocalizedString(@"", nil);
        [view setHeightToFit];
        
        [self addSubview:view];
        
        height += CGRectGetHeight(view.frame);
    }
    
    height += 10;
    
    {
        UITextView *view = [[UITextView alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, height, CGRectGetWidth(self.frame) - 2 * PADDING_LEFT_RIGHT, 50.0f)];
        
        view.font = [UIFont customContentRegular:14];
        view.textColor = [UIColor customBlue];
        view.delegate = self;
        view.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:view];
        
        height += CGRectGetHeight(view.frame);
    }
    
    height += PADDING_TOP_BOTTOM;
    
    {
        UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(self.frame) / 2., BUTTON_HEIGHT)];
        
        [view setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
        [view setBackgroundColor:[UIColor whiteColor]];
        view.titleLabel.font = [UIFont customContentRegular:17];
        
        [view setTitle:[NSLocalizedString(@"GLOBAL_CANCEL", nil) uppercaseString] forState:UIControlStateNormal];
        [view addTarget:self action:@selector(didRefuseTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:view];
    }
    
    {
        UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., height, CGRectGetWidth(self.frame) / 2., BUTTON_HEIGHT)];
        
        [view setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
        [view setBackgroundColor:[UIColor whiteColor]];
        view.titleLabel.font = [UIFont customContentBold:17];
        
        [view setTitle:[NSLocalizedString(@"MENU_REPORT", nil) uppercaseString] forState:UIControlStateNormal];
        [view addTarget:self action:@selector(didReportTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:view];
    }
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., height, 1, BUTTON_HEIGHT)];
        view.backgroundColor = [UIColor customBlue];
        [self addSubview:view];
    }
    
    height += BUTTON_HEIGHT;
    
    CGRectSetHeight(self.frame, height);
    self.center = appDelegate.window.center;
    if (IS_IPHONE4)
        CGRectSetY(self.frame, 30);
    else
        CGRectSetY(self.frame, 70);
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        background = [[UIView alloc] initWithFrame:CGRectMakeWithSize(appDelegate.window.frame.size)];
        background.backgroundColor = [UIColor customBackground:.6];
        
        CGAffineTransform tr = CGAffineTransformScale(self.transform, 1.1, 1.1);
        self.transform = CGAffineTransformScale(self.transform, 0, 0);
        
        background.layer.opacity = 0;
        
        [appDelegate.window addSubview:background];
        [appDelegate.window addSubview:self];
        
        [UIView animateWithDuration:0.1
                         animations: ^{
                             background.layer.opacity = 1;
                         }];
        
        
        [UIView animateWithDuration:ANIMATION_DELAY
                         animations: ^{
                             self.transform = tr;
                         } completion: ^(BOOL finished) {
                             [UIView animateWithDuration:.1
                                              animations: ^{
                                                  self.transform = CGAffineTransformIdentity;
                                              }];
                         }];
    });
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:ANIMATION_DELAY
                         animations: ^{
                             background.layer.opacity = 0;
                         }
                         completion: ^(BOOL finished) {
                             [background removeFromSuperview];
                         }];
        
        [UIView animateWithDuration:ANIMATION_DELAY
                         animations: ^{
                             self.transform = CGAffineTransformScale(self.transform, 0, 0);
                         }
                         completion: ^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    });
}

- (void)didReportTouch {
    [self dismiss];
}

- (void)didRefuseTouch {
    [self dismiss];
}

- (void)didReceiveRemoveWindowSubviews {
    [background removeFromSuperview];
    [self removeFromSuperview];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return textView.text.length + (text.length - range.length) <= 250;
}

@end
