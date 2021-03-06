//
//  SecureCodeField.m
//  Flooz
//
//  Created by Olivier on 2014-03-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SecureCodeField.h"

#define WIDTH 62.

@implementation SecureCodeField

- (id)initWithFrame:(CGRect)frame {
	frame = CGRectMake(0, frame.origin.y, 320, 70);
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	for (int i = 0; i < 4; ++i) {
		UILabel *label = [self createLabel];
		CGRectSetX(label.frame, i * (WIDTH + 14) + 14);
		[self addSubview:label];
	}

	[self createDots];
	[self clean];
}

- (UILabel *)createLabel {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMakeSize(WIDTH, WIDTH)];

//    label.layer.borderWidth = 1.;
	label.layer.cornerRadius = 3;
	label.clipsToBounds = YES;
//    label.layer.borderColor = [[UIColor customSeparator] CGColor];
	label.backgroundColor = [UIColor customBackgroundHeader];
	label.font = [UIFont customTitleThin:44];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = NSTextAlignmentCenter;

	return label;
}

- (void)createDots {
	dotViews = @[
	        [UIView new],
	        [UIView new],
	        [UIView new],
	        [UIView new]
	    ];

	CGFloat space = 14.;

	for (int i = 0; i < [dotViews count]; ++i) {
		UIView *dot = dotViews[i];
		dot.frame = CGRectMake(i * (WIDTH + space) + space + (WIDTH / 2.) - (10 / 2), CGRectGetHeight(self.frame) / 2. - 8, 10, 10);
		dot.layer.cornerRadius = CGRectGetHeight(dot.frame) / 2.;
		dot.backgroundColor = [UIColor whiteColor];
		[self addSubview:dot];
	}
}

#pragma mark - FLKeyboardViewDelegate

- (void)keyboardPress:(NSString *)touch {
	currentValue = [currentValue stringByAppendingString:touch];
	[self reformatLabel];

	if (currentLabel < 3) { // 4 labels - 1
		currentLabel++;
	}
	else {
		[_delegate didSecureCodeEnter:currentValue];
	}
}

- (void)keyboardBackwardTouch {
	if ([dotViews[currentLabel] isHidden]) {
		if (currentLabel > 0) {
			currentLabel--;
			[self keyboardBackwardTouch];
		}
	}
	else {
		currentValue = [currentValue stringByReplacingCharactersInRange:NSMakeRange(currentLabel, 1) withString:@""];
		[self reformatLabel];
	}
}

- (void)reformatLabel {
	for (int i = 0; i < 4; ++i) {
		UILabel *label = [[self subviews] objectAtIndex:i];

		if (currentValue.length > 0 && i <= currentValue.length - 1) {
			label.text = @"";
			[dotViews[i] setHidden:NO];
		}
		else {
			label.text = @"";
			[dotViews[i] setHidden:YES];
		}
	}
	if ([self.delegate respondsToSelector:@selector(didPressTouch:)]) {
		[_delegate didPressTouch:currentValue];
	}
}

- (void)clean {
	for (UILabel *subview in self.subviews) {
		if ([subview respondsToSelector:@selector(setText:)]) {
			subview.text = @"";
		}
		else {
			subview.hidden = YES;
		}
	}
	currentValue = @"";
	currentLabel = 0;
	if ([self.delegate respondsToSelector:@selector(didPressTouch:)]) {
		[_delegate didPressTouch:currentValue];
	}
}

@end
