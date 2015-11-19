//
//  FLSocialButton.m
//  Flooz
//
//  Created by Arnaud on 2014-09-29.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLSocialButton.h"

@implementation FLSocialButton {
	UIButton *_button;
}

- (instancetype)initWithImageName:(NSString *)imageNamed imageSelected:(NSString *)imageNamedSelected title:(NSString *)title andHeight:(CGFloat)height {
	self = [super initWithFrame:CGRectMake(0, 0, 0, height)];
	if (self) {
		_imageNamedNormal = imageNamed;
		_imageNamedSelected = imageNamedSelected;
		_title = title;

		[self setBackgroundColor:[UIColor customBackgroundSocial]];
		[self createViews];
	}
	return self;
}

- (void)createViews {
	CGRectSetHeight(self.frame, 22.5);
	[self.layer setCornerRadius:5];
	[self createImage];
	[self createTitle];

	_button = [UIButton newWithFrame:self.frame];
	[self addSubview:_button];
}

- (void)createImage {
	_image = [UIImageView newWithFrame:CGRectMake(0, (CGRectGetHeight(self.frame) - 16) / 2, 16, 16)];
	[_image setImage:[UIImage imageNamed:_imageNamedNormal]];
	[self addSubview:_image];
	CGRectSetX(_image.frame, 3.0f);
	[_image setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)createTitle {
	_titleButton = [UILabel newWithFrame:CGRectMake(CGRectGetMaxX(_image.frame), 0.0f, 10.0f, CGRectGetHeight(self.frame))];
	[_titleButton setFont:[UIFont customContentRegular:11]];
	[_titleButton setTextColor:[UIColor customSocialColor]];

	[_titleButton setText:_title];
	CGRectSetWidth(_titleButton.frame, [_titleButton widthToFit]);
	[self addSubview:_titleButton];

	CGRectSetWidth(self.frame, CGRectGetMaxX(_titleButton.frame) + 5.0f);
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
	[super addTarget:target action:action forControlEvents:controlEvents];
	[_button addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	if (!selected) {
		[self setBackgroundColor:[UIColor customBackgroundSocial]];
		[_image setImage:[[UIImage imageNamed:_imageNamedNormal] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_image setTintColor:[UIColor customSocialColor]];
		[_titleButton setTextColor:[UIColor customSocialColor]];
	}
	else {
		[self setBackgroundColor:[UIColor customBlue]];
		[_image setImage:[[UIImage imageNamed:_imageNamedSelected] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_image setTintColor:[UIColor whiteColor]];
		[_titleButton setTextColor:[UIColor whiteColor]];
	}
}

@end
