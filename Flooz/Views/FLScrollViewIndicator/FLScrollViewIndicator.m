//
//  FLScrollViewIndicator.m
//  Flooz
//
//  Created by olivier on 2014-04-03.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLScrollViewIndicator.h"

#define WIDTH 265
#define MARGIN_RIGHT 5

#define LABEL_MARGIN 10.

@implementation FLScrollViewIndicator

- (id)initWithFrame:(CGRect)frame {
	frame = CGRectMake(SCREEN_WIDTH - (WIDTH + MARGIN_RIGHT), 0, WIDTH, 30);
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	{
		containerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame), 0, 0, CGRectGetHeight(self.frame))];

		containerView.backgroundColor = [UIColor customBackgroundHeader:.5];
		containerView.layer.cornerRadius = CGRectGetHeight(self.frame) / 2.;
		containerView.clipsToBounds = YES; // pour quand on anime que le texte ne depasse pas

		[self addSubview:containerView];
	}

	{
		label = [[JTImageLabel alloc] initWithFrame:CGRectMake(LABEL_MARGIN, 0, 0, CGRectGetHeight(self.frame))];
		label.font = [UIFont customContentRegular:12];
		label.textColor = [UIColor whiteColor];

		[label setImageOffset:CGPointMake(-5, 0)];

		[containerView addSubview:label];
	}
}

- (void)setTransaction:(FLTransaction *)transaction {
	if (currentScope != transaction.social.scope) {

	}

	if ([label.text isEqualToString:[transaction when]]) {
		return;
	}

	label.text = [transaction when];
	CGFloat newLabelWidth = [label widthToFit] + LABEL_MARGIN + 8;

	[UIView animateWithDuration:.5
	                      delay:0
	                    options:UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
	    CGRectSetWidth(label.frame, newLabelWidth);
	    CGRectSetWidth(containerView.frame, newLabelWidth);
	    CGRectSetX(containerView.frame,  CGRectGetWidth(self.frame) - newLabelWidth);
	} completion:NULL];
}

@end
