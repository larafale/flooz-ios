//
//  NewTransactionSelectTypeView.m
//  Flooz
//
//  Created by olivier on 2014-03-17.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "NewTransactionSelectTypeView.h"

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

@implementation NewTransactionSelectTypeView

- (id)initWithFrame:(CGRect)frame for:(NSMutableDictionary *)dictionary {
	self = [super initWithFrame:CGRectMake(0, frame.origin.y, SCREEN_WIDTH, 42)];
	if (self) {
		_dictionary = dictionary;

		[self createButtons];
		[self createSeparator];

		if ([[_dictionary objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypePayment]]) {
			[self didButtonLeftTouch];
		}
		else {
			[self didButtonRightTouch];
		}
	}
	return self;
}

- (void)createSeparator {
	{
		UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 1)];
		separator.backgroundColor = [UIColor customSeparator];

		[self addSubview:separator];
	}

	{
		UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, CGRectGetHeight(self.frame))];
		separator.backgroundColor = [UIColor customSeparator];

		[self addSubview:separator];
	}

	{
		UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 1, 0, 1, CGRectGetHeight(self.frame))];
		separator.backgroundColor = [UIColor customSeparator];

		[self addSubview:separator];
	}

	{
		UIView *square = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetHeight(self.frame) / 3., CGRectGetHeight(self.frame) / 3.)];

		square.backgroundColor = [UIColor customBackgroundStatus];

		square.transform = CGAffineTransformMakeRotation(RADIANS(45));

		square.center = CGRectGetFrameCenter(self.frame);

		[self addSubview:square];
	}
}

- (void)createButtons {
	buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];
	buttonRight = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(buttonLeft.frame), 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];

	[buttonLeft setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundStatus]] forState:UIControlStateNormal];
	[buttonRight setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundStatus]] forState:UIControlStateNormal];
	[buttonLeft setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateSelected];
	[buttonRight setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateSelected];

	buttonLeft.titleLabel.font = buttonRight.titleLabel.font = [UIFont customContentRegular:13];

	[buttonLeft setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
	[buttonRight setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
	[buttonLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[buttonRight setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

	[buttonLeft setTitle:NSLocalizedString(@"MENU_NEW_TRANSACTION_PAYMENT", nil) forState:UIControlStateNormal];
	[buttonRight setTitle:NSLocalizedString(@"MENU_NEW_TRANSACTION_COLLECT", nil) forState:UIControlStateNormal];

	[buttonLeft addTarget:self action:@selector(didButtonLeftTouch) forControlEvents:UIControlEventTouchUpInside];
	[buttonRight addTarget:self action:@selector(didButtonRightTouch) forControlEvents:UIControlEventTouchUpInside];

	[self addSubview:buttonLeft];
	[self addSubview:buttonRight];
}

- (void)didButtonLeftTouch {
	if (buttonLeft.selected) {
		return;
	}

	buttonLeft.selected = YES;
	buttonRight.selected = NO;

	[_dictionary setValue:[FLTransaction transactionTypeToParams:TransactionTypePayment] forKey:@"method"];
	[_delegate didTypePaymentelected];
}

- (void)didButtonRightTouch {
	if (buttonRight.selected) {
		return;
	}

	buttonLeft.selected = NO;
	buttonRight.selected = YES;

	[_dictionary setValue:[FLTransaction transactionTypeToParams:TransactionTypeCharge] forKey:@"method"];
	[_delegate didTypeCollectSelected];
}

@end
