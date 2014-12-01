//
//  FLPopup.m
//  Flooz
//
//  Created by Jonathan on 23/07/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLPopup.h"

#import "AppDelegate.h"


#define MARGE 30.
#define PADDING_TOP_BOTTOM 30.
#define PADDING_LEFT_RIGHT 30.
#define BUTTON_HEIGHT 50.
#define ANIMATION_DELAY 0.4

@implementation FLPopup

- (id)initWithMessage:(NSString *)message accept:(void (^)())accept refuse:(void (^)())refuse;
{
	CGRect frame = CGRectMake(MARGE, 150, SCREEN_WIDTH - 2 * MARGE, 0);
	self = [super initWithFrame:frame];
	if (self) {
		acceptBlock = accept;
		refuseBlock = refuse;
		[self commmonInit:message];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoveWindowSubviews) name:kNotificationRemoveWindowSubviews object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commmonInit:(NSString *)message {
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

        CGRectSetHeight(view.frame, 50);
		CGRectSetXY(view.frame, (CGRectGetWidth(self.frame) - CGRectGetWidth(view.frame)) / 2., height);

		[self addSubview:view];

		height += CGRectGetHeight(view.frame);
	}

	height += 15;

	{
		UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, height, CGRectGetWidth(self.frame) - 2 * PADDING_LEFT_RIGHT, 0)];

		view.font = [UIFont customContentRegular:18];
		view.textColor = [UIColor whiteColor];
		view.textAlignment = NSTextAlignmentCenter;
		view.numberOfLines = 0;

		view.text = message;
		[view setHeightToFit];

		[self addSubview:view];

		height += CGRectGetHeight(view.frame);
	}

	height += PADDING_TOP_BOTTOM;

	{
		UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(self.frame) / 2., BUTTON_HEIGHT)];

		[view setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
		[view setBackgroundColor:[UIColor whiteColor]];
		view.titleLabel.font = [UIFont customContentRegular:17];

		[view setTitle:[NSLocalizedString(@"GLOBAL_NO", nil) uppercaseString] forState:UIControlStateNormal];
		[view addTarget:self action:@selector(didRefuseTouch) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:view];
	}

	{
		UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., height, CGRectGetWidth(self.frame) / 2., BUTTON_HEIGHT)];

		[view setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
		[view setBackgroundColor:[UIColor whiteColor]];
		view.titleLabel.font = [UIFont customContentBold:17];

		[view setTitle:[NSLocalizedString(@"GLOBAL_YES", nil) uppercaseString] forState:UIControlStateNormal];
		[view addTarget:self action:@selector(didAcceptTouch) forControlEvents:UIControlEventTouchUpInside];

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
}

- (void)show {
	background = [[UIView alloc] initWithFrame:CGRectMakeWithSize(appDelegate.window.frame.size)];
	background.backgroundColor = [UIColor customBackground:.6];

	UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
	[tap addTarget:self action:@selector(dismiss)];
	[background addGestureRecognizer:tap];

	CGAffineTransform tr = CGAffineTransformScale(self.transform, 1.1, 1.1);
	self.transform = CGAffineTransformScale(self.transform, 0, 0);

	background.layer.opacity = 0;
    
    [appDelegate.topWindow addSubview:background];
    [appDelegate.topWindow addSubview:self];
    
	[UIView animateWithDuration:ANIMATION_DELAY
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

- (void)dismiss {
	[self dismiss:NULL];
}

- (void)didAcceptTouch {
	[self dismiss:acceptBlock];
}

- (void)didRefuseTouch {
	[self dismiss:refuseBlock];
}

- (void)didReceiveRemoveWindowSubviews {
	[background removeFromSuperview];
	[self removeFromSuperview];
}

@end
