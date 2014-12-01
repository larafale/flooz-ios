//
//  CodePinView.m
//  Flooz
//
//  Created by Arnaud on 2014-09-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "CodePinView.h"

@implementation CodePinView {
	NSInteger _numberOfDigit;
	NSMutableArray *_digitArray;

	NSString *_pin;
}

- (id)initWithNumberOfDigit:(NSInteger)numberOfDigit andFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		_numberOfDigit = numberOfDigit;

		_pin = @"";
		self.digitON = @"";//@"●";
		self.digitOFF = @"";//@"-";

		[self createDigits];
	}
	return self;
}

- (void)createDigits {
	_digitArray = [NSMutableArray new];

    //Calculate space for pin depends on number of digit
    CGFloat numSpace = ((_numberOfDigit-2) * _numberOfDigit) + ((_numberOfDigit-1) * (_numberOfDigit-1));
    CGFloat widthBase = CGRectGetWidth(self.frame) / numSpace;
    CGFloat space = widthBase * (_numberOfDigit-1.0f);
    CGFloat width = widthBase * (_numberOfDigit-2.0f);
    CGFloat height = width;
    
    CGFloat x = 0.0f;
    CGFloat y = (CGRectGetHeight(self.frame) - height) / 4.0f;

	for (int i = 0; i < _numberOfDigit; i++) {
		UILabel *l = [UILabel newWithFrame:CGRectMake(x, y, width, height)];

		[l setTextAlignment:NSTextAlignmentCenter];
		[l setTextColor:[UIColor customBlue]];
		[l setFont:[UIFont customTitleBook:40]];
		[l setText:self.digitOFF];

        [l.layer setBorderWidth:1];
        [l.layer setBorderColor:[UIColor customBlue].CGColor];
        [l.layer setCornerRadius:height / 2.0f];
        [l.layer setMasksToBounds:YES];
        
        [self addSubview:l];
		[_digitArray addObject:l];

		x += width + space;
	}
}

#pragma mark - methods

- (void)setPin:(NSString *)pin {
	_pin = pin;
	BOOL pinStarts = NO;
	for (int i = 0; i < _digitArray.count; i++) {
		UILabel *l = [_digitArray objectAtIndex:i];
		if (i < pin.length) {
            [l setBackgroundColor:[UIColor customBlue]];
			[l setText:self.digitON];

			pinStarts = YES;
		}
        else {
            [l setBackgroundColor:[UIColor clearColor]];
			[l setText:self.digitOFF];
		}
	}

	if ([self.delegate respondsToSelector:@selector(pinChange:)]) {
		[_delegate pinChange:pinStarts];
	}

	if (_pin.length >= _digitArray.count) {
		[_delegate pinEnd:_pin];
	}
}

- (void)animationBadPin {
	[self clean];
	CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
	anim.values = @[
	        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5., 0., 0.)],
	        [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5., 0., 0.)]
	    ];
	anim.autoreverses = YES;
	anim.repeatCount = 2.;
	anim.delegate = self;
	anim.duration = 0.08;
	[self.layer addAnimation:anim forKey:nil];
}

- (void)clean {
	[self setPin:@""];
}

#pragma mark - setters

- (void)setDigitON:(NSString *)digitON {
	_digitON = digitON;
	[self setPin:_pin];
}

- (void)setDigitOFF:(NSString *)digitOFF {
	_digitOFF = digitOFF;
	[self setPin:_pin];
}

#pragma mark - FLKeyboardViewDelegate

- (void)keyboardPress:(NSString *)touch {
	if (_pin.length < _digitArray.count) {
		_pin = [_pin stringByAppendingString:touch];
		[self setPin:_pin];
	}
}

- (void)keyboardBackwardTouch {
	if (_pin.length > 0) {
		_pin = [_pin substringToIndex:[_pin length] - 1];
		[self setPin:_pin];
	}
}

@end
