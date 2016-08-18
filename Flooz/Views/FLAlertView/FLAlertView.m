//
//  FLAlertView.m
//  Flooz
//
//  Created by Olivier on 2014-03-25.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLAlertView.h"
#import "FLTrigger.h"
#import "AppDelegate.h"

#define MARGE_LEFT 78.
#define MARGE_RIGHT 20.
#define MARGE_BOTTOM 15.
#define MARGE 5.

@implementation FLAlertView {
    NSDictionary *_infoAlert;
    FLAlert *_alert;
}

- (id)initWithFrame:(CGRect)frame {
	frame = CGRectMake(MARGE, STATUSBAR_HEIGHT, SCREEN_WIDTH - 2 * MARGE, 0);
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoveWindowSubviews) name:kNotificationRemoveWindowSubviews object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit {
	self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 3;

	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touch)];
	[self addGestureRecognizer:gesture];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUp];

	{
		titleView = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, MARGE_BOTTOM, SCREEN_WIDTH - MARGE_LEFT - MARGE_RIGHT, 17)];
		titleView.font = [UIFont customTitleExtraLight:17];
		titleView.textColor = [UIColor whiteColor];

		[self addSubview:titleView];
	}

	{
		contentView = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, CGRectGetMaxY(titleView.frame) + 5, SCREEN_WIDTH - MARGE_LEFT - MARGE_RIGHT, 0)];
		contentView.font = [UIFont customContentRegular:14];
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

- (void)show:(FLAlert *)alert completion:(dispatch_block_t)completion {
    if (alert.visible) {
        
        _alert = alert;
        _infoAlert = nil;
        
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [_alert.delay integerValue] * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:[_alert.duration floatValue] target:self selector:@selector(hide) userInfo:nil repeats:NO];
        
        CGRectSetHeight(self.frame, 0);
        [[[UIApplication sharedApplication] keyWindow] addSubview:self];
        
        titleView.text = _alert.title;
        contentView.text = _alert.content;
        
        [contentView setHeightToFit];
        iconView.center = CGPointMake(iconView.center.x, (CGRectGetMaxY(contentView.frame) + MARGE_BOTTOM) / 2.);
        
        [self setType:_alert.type];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:.4 animations: ^{
                CGRectSetHeight(self.frame, CGRectGetMaxY(contentView.frame) + MARGE_BOTTOM);
            } completion:^(BOOL finished) {
                if (completion)
                    completion();
            }];
        });
    });
    }
}

- (void)show:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style {
    _alert = nil;
	[self show:title content:content style:style time:nil delay:nil];
}

- (void)show:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time delay:(NSNumber *)delay andDictionnary:(NSDictionary *)info {
    _alert = nil;
//    _infoAlert = info;
    [self show:title content:content style:style time:time delay:delay];
}

- (void)show:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time delay:(NSNumber *)delay {
	if (!time) {
		time = @3;
	}

	if (!delay) {
		delay = @0;
	}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, [delay integerValue] * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
	    [timer invalidate];
	    timer = [NSTimer scheduledTimerWithTimeInterval:[time floatValue] target:self selector:@selector(hide) userInfo:nil repeats:NO];
        
        CGRectSetHeight(self.frame, 0);
        [[appDelegate topWindow] addSubview:self];
        
	    titleView.text = title;
	    contentView.text = content;

	    [contentView setHeightToFit];
	    iconView.center = CGPointMake(iconView.center.x, (CGRectGetMaxY(contentView.frame) + MARGE_BOTTOM) / 2.);

	    [self setStyle:style];

	    dispatch_async(dispatch_get_main_queue(), ^{
	        [UIView animateWithDuration:.4 animations: ^{
	            CGRectSetHeight(self.frame, CGRectGetMaxY(contentView.frame) + MARGE_BOTTOM);
			}];
		});
	});
}

- (void)hide {
	[timer invalidate];
	dispatch_async(dispatch_get_main_queue(), ^{
	    [UIView animateWithDuration:.4
	                     animations: ^{
	        CGRectSetHeight(self.frame, 0);
		} completion: ^(BOOL finished) {
	        [self removeFromSuperview];
		}];
	});
}

- (void)setStyle:(FLAlertViewStyle)style {
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

- (void)setType:(FLAlertType)type {
    UIColor *backgroundColor;
    NSString *imageName;
    
    switch (type) {
        case AlertTypeError:
            backgroundColor = [UIColor customRed];
            imageName = @"alertview-error";
            break;
            
        case AlertTypeSuccess:
            backgroundColor = [UIColor customGreen];
            imageName = @"alertview-success";
            break;
            
        case AlertTypeWarning:
            backgroundColor = [UIColor customBlue];
            imageName = @"alertview-info";
            break;
    }
    
    self.backgroundColor = backgroundColor;
    iconView.image = [UIImage imageNamed:imageName];
}

- (void)didReceiveRemoveWindowSubviews {
	[self removeFromSuperview];
}

- (void)touch {
    [self hide];
    if (_infoAlert && _infoAlert[@"type"]) {
        for (NSString *key in _infoAlert[@"type"]) {
            if ([key isEqualToString:@"line"] && _infoAlert[@"lineId"]) {
                [[Flooz sharedInstance] showLoadView];
                [[Flooz sharedInstance] transactionWithId:_infoAlert[@"lineId"] success: ^(id result) {
                    FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
                    [appDelegate showTransaction:transaction inController:nil withIndexPath:nil focusOnComment:NO];
                }];
            }
            else if ([key isEqualToString:@"friend"]) {
                [appDelegate showFriendsController];
            }
        }
    }
    else if (_alert) {
        [[FLTriggerManager sharedInstance] executeTriggerList:_alert.triggers];
    }
}

@end
