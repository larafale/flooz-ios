//
//  FLWaveAnimation.m
//  Flooz
//
//  Created by jonathan on 2014-04-28.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLWaveAnimation.h"

@implementation FLWaveAnimation

- (id)init {
	self = [super init];
	if (self) {
		[self commonInit];
	}

	return self;
}

- (void)commonInit {
	_backgroundColor = [UIColor colorWithWhite:1.0f alpha:.3];
	_foregroundColor = [UIColor whiteColor];

	_gradientWidth = 20;
	_repeatCount = 3;
	_duration = 2.0;
}

- (void)start {
	if (!_view) {
		return;
	}

	[self stop];

	CAGradientLayer *gradientMask = [CAGradientLayer layer];
	gradientMask.frame = _view.bounds;

	CGFloat gradientSize = _gradientWidth / _view.frame.size.width;

	NSArray *startLocations = @[
	        @0,
	        [NSNumber numberWithFloat:(gradientSize / 2)],
	        [NSNumber numberWithFloat:gradientSize]
	    ];
	NSArray *endLocations = @[
	        [NSNumber numberWithFloat:(1.0f - gradientSize)],
	        [NSNumber numberWithFloat:(1.0f - (gradientSize / 2))],
	        @1
	    ];


	gradientMask.colors = @[(id)_backgroundColor.CGColor, (id)_foregroundColor.CGColor, (id)_backgroundColor.CGColor];

	gradientMask.locations = startLocations;
	gradientMask.startPoint = CGPointMake(0 - (gradientSize * 2), .5);
	gradientMask.endPoint = CGPointMake(1 + gradientSize, .5);


	UIView *superview = _view.superview;
	[_view removeFromSuperview];
	_view.layer.mask = gradientMask;
	[superview addSubview:_view];


	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
	animation.fromValue = startLocations;
	animation.toValue = endLocations;
	animation.repeatCount = _repeatCount;
	animation.duration  = _duration;
	animation.delegate = self;

	[gradientMask addAnimation:animation forKey:@"FLWaveAnimation"];
}

- (void)stop {
	if (_view && _view.layer.mask) {
		UIView *superview = [_view superview];
		[_view removeFromSuperview];
		_view.layer.mask = nil;
		[superview addSubview:_view];
	}
}

// Appellé par le stop et par _view.layer.mask = gradientMask; quand il y avait deja une animation de lancé
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished {
	if (finished) {
		[self stop];
	}
}

@end
