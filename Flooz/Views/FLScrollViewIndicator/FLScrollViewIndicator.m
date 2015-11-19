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
        scopeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) / 2 - 7.5, 15, 15)];
        [containerView addSubview:scopeImage];
    }
    
    
	{
		label = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_MARGIN + 3, 0, 0, CGRectGetHeight(self.frame))];
		label.font = [UIFont customContentRegular:12];
		label.textColor = [UIColor whiteColor];

		[containerView addSubview:label];
	}
}

- (void)setTransaction:(FLTransaction *)transaction {
	if (currentScope != transaction.social.scope) {
        currentScope = transaction.social.scope;
        NSString *imageNamed = nil;
        
        if (transaction.social.scope == SocialScopeFriend) {
            imageNamed = @"transaction-scope-friend";
        }
        else if (transaction.social.scope == SocialScopePrivate) {
            imageNamed = @"transaction-scope-private";
        }
        else if (transaction.social.scope == SocialScopePublic) {
            imageNamed = @"transaction-scope-public";
        }
        
        [scopeImage setImage:[[UIImage imageNamed:imageNamed] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [scopeImage setTintColor:[UIColor whiteColor]];
	}

	if ([label.text isEqualToString:[transaction when]]) {
		return;
	}

	label.text = [NSString stringWithFormat:@"%@ ⋅", [transaction when]];
	CGFloat newLabelWidth = [label widthToFit] + 4 + LABEL_MARGIN;

	[UIView animateWithDuration:.2
	                      delay:0
	                    options:UIViewAnimationOptionBeginFromCurrentState
	                 animations: ^{
	    CGRectSetWidth(label.frame, newLabelWidth);
	    CGRectSetWidth(containerView.frame, newLabelWidth + 30);
	    CGRectSetX(containerView.frame,  CGRectGetWidth(self.frame) - CGRectGetWidth(containerView.frame));
        CGRectSetX(scopeImage.frame,  newLabelWidth);
	} completion:NULL];
}

@end
