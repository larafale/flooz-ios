//
//  FLPopupInformation.m
//  Flooz
//
//  Created by Arnaud on 2014-09-10.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLPopupInformation.h"

#import "AppDelegate.h"

#define MARGE 20.
#define PADDING_TOP_BOTTOM 20.
#define PADDING_LEFT_RIGHT 20.
#define BUTTON_HEIGHT 40.
#define ANIMATION_DELAY 0.3

@implementation FLPopupInformation

- (id)initWithTitle:(NSString *)title andMessage:(NSAttributedString *)message ok:(void (^)())ok {
	CGRect frame = CGRectMake(MARGE, 150, SCREEN_WIDTH - 2 * MARGE, 0);
	self = [super initWithFrame:frame];
	if (self) {
		okBlock = ok;
		[self commmonInit:title andMessage:message];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoveWindowSubviews) name:kNotificationRemoveWindowSubviews object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commmonInit:(NSString *)title andMessage:(NSAttributedString *)message {
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
        
        view.text = title;
        [view setHeightToFit];
        
        [self addSubview:view];
        
        height += CGRectGetHeight(view.frame);
    }

    height += 10;
    
    {
		UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, height, CGRectGetWidth(self.frame) - 2 * PADDING_LEFT_RIGHT, 0)];

		view.font = [UIFont customContentRegular:14];
		view.textColor = [UIColor whiteColor];
		view.textAlignment = NSTextAlignmentCenter;
		view.numberOfLines = 0;

		view.attributedText = message;
		[view sizeToFit];

		[self addSubview:view];

		height += CGRectGetHeight(view.frame);
	}

	height += PADDING_TOP_BOTTOM;

	{
		UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(self.frame), BUTTON_HEIGHT)];

		[view setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
		[view setBackgroundColor:[UIColor whiteColor]];
		view.titleLabel.font = [UIFont customTitleBook:16];

		[view setTitle:[NSLocalizedString(@"OK", nil) uppercaseString] forState:UIControlStateNormal];
		[view addTarget:self action:@selector(okTouch) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:view];
	}

	height += BUTTON_HEIGHT;

	CGRectSetHeight(self.frame, height);
	self.center = appDelegate.window.center;
}

- (void)show {
    
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
}

- (void)dismiss:(void (^)())completion {
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

	    if (completion) {
	        completion();
		}
	}];
}

- (void)okTouch {
	[self dismiss:okBlock];
}

- (void)didReceiveRemoveWindowSubviews {
	[background removeFromSuperview];
	[self removeFromSuperview];
}

@end
