//
//  FLStartButton.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLStartButton.h"

@implementation FLStartButton

- (id)initWithFrame:(CGRect)frame title:(NSString *)title {
	self = [super initWithFrame:frame];
	if (self) {
		self.layer.borderWidth = 1;
		self.layer.borderColor = [UIColor customSeparator].CGColor;

		[self createViewWithTitle:title];
	}
	return self;
}

- (void)createViewWithTitle:(NSString *)title {
	self.layer.borderWidth = 1;
	self.layer.borderColor = [UIColor customSeparator].CGColor;

	[self setBackgroundImage:[UIImage imageWithColor:[UIColor customBlue]] forState:UIControlStateNormal];
	[self setBackgroundImage:[UIImage imageWithColor:[UIColor customBlueHover]] forState:UIControlStateHighlighted];

	{
		UILabel *textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];

		textView.textColor = [UIColor whiteColor];
		textView.textAlignment = NSTextAlignmentCenter;
		textView.font = [UIFont customTitleExtraLight:14];

		textView.text = title;

		[self addSubview:textView];
	}
}

@end
