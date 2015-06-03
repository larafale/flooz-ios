//
//  TransactionUsersCollectView.m
//  Flooz
//
//  Created by olivier on 02/08/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "TransactionUsersCollectView.h"

#import "FLUserView.h"

@implementation TransactionUsersCollectView

- (id)initWithFrame:(CGRect)frame {
	CGRectSetHeight(frame, 155);
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor customBackgroundHeader];
		[self createViews];
	}
	return self;
}

- (void)createViews {
	[self createLeftUserView];
	[self createRightUserView];
	[self createSeparators];
}

- (void)createLeftUserView {
	UIView *view = [self createUserView];
	[self addSubview:view];
}

- (void)createRightUserView {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) / 2), 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];

	[view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didParticipantsTouch)]];

	[self addSubview:view];
}

- (void)createSeparators {
	UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
	UIView *middleBar = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, 1, CGRectGetHeight(self.frame))];

	bottomBar.backgroundColor = middleBar.backgroundColor = [UIColor customSeparator:0.5];

	[self addSubview:bottomBar];
	[self addSubview:middleBar];
}

- (UIView *)createUserView {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];

	{
		FLUserView *avatar = [[FLUserView alloc] initWithFrame:CGRectMakeSize(88, 88)];

		avatar.center = CGRectGetFrameCenter(view.frame);
		avatar.frame = CGRectOffset(avatar.frame, 0, -20);

		[view addSubview:avatar];
	}

	{
		UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(view.frame), 50)];

		username.numberOfLines = 0;
		username.textAlignment = NSTextAlignmentCenter;
		username.textColor = [UIColor whiteColor];
		username.font = [UIFont customTitleExtraLight:12];

		[view addSubview:username];
	}

	{
		UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(0, 124, CGRectGetWidth(view.frame), 30)];

		username.font = [UIFont customContentRegular:10];
		username.textAlignment = NSTextAlignmentCenter;
		username.textColor = [UIColor customBlue];

		[view addSubview:username];
	}

	return view;
}

- (UIView *)createMiniUserView {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 2, 45)];

	{
		FLUserView *avatar = [[FLUserView alloc] initWithFrame:CGRectMakeSize(40, 40)];
		avatar.frame = CGRectOffset(avatar.frame, 16, 2.5);

		[view addSubview:avatar];
	}

	{
		UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(62, 0, CGRectGetWidth(view.frame) - 62, CGRectGetHeight(view.frame))];

		username.numberOfLines = 0;
		username.textColor = [UIColor whiteColor];
		username.font = [UIFont customTitleExtraLight:10];

		[view addSubview:username];
	}

	return view;
}

#pragma mark -

- (void)setTransaction:(FLTransaction *)transaction {
	self->_transaction = transaction;
	[self prepareViews];
}

#pragma mark -

- (void)prepareViews {
	[self prepareLeftUserView];
	[self prepareRightUserView];
}

- (void)prepareLeftUserView {
	UIView *view = [[self subviews] objectAtIndex:0];
	FLUserView *avatar = [[view subviews] objectAtIndex:0];
	UILabel *fullname = [[view subviews] objectAtIndex:1];
	UILabel *username = [[view subviews] objectAtIndex:2];

	[avatar setImageFromUser:[_transaction to]];
	fullname.text = [[[_transaction to] fullname] uppercaseString];

	if ([[_transaction to] username]) {
		username.text = [@"@" stringByAppendingString :[[_transaction to] username]];
	}
	else {
		username.text = @"";
	}
}

- (void)prepareRightUserView {
	UIView *view = [[self subviews] objectAtIndex:1];

	for (UIView *subview in[view subviews]) {
		[subview removeFromSuperview];
	}

	if ([[_transaction collectUsers] count] > 0) {
		CGFloat MARGE_TOP_BOTTOM = 9.;
		CGFloat height = 0;

		UIView *firstUserView = [self createMiniUserView];
		UIView *secondUserView = nil;
		UIView *lastUserView = nil;

		if ([[_transaction collectUsers] count] == 1) {
			CGRectSetY(firstUserView.frame, MARGE_TOP_BOTTOM);
			FLUser *user = [[_transaction collectUsers] objectAtIndex:0];

			FLUserView *avatar = [[firstUserView subviews] objectAtIndex:0];
			UILabel *username = [[firstUserView subviews] objectAtIndex:1];

			[avatar setImageFromUser:user];
			username.text = [[user fullname] uppercaseString];

			height = CGRectGetMaxY(firstUserView.frame);
		}

		if ([[_transaction collectUsers] count] == 2) {
			secondUserView = [self createMiniUserView];
			CGRectSetY(secondUserView.frame, height);

			FLUser *user = [[_transaction collectUsers] objectAtIndex:1];

			FLUserView *avatar = [[secondUserView subviews] objectAtIndex:0];
			UILabel *username = [[secondUserView subviews] objectAtIndex:1];

			[avatar setImageFromUser:user];
			username.text = [[user fullname] uppercaseString];

			height = CGRectGetMaxY(secondUserView.frame);
		}

		if ([[_transaction collectUsers] count] == 3) {
			lastUserView = [self createMiniUserView];
			CGRectSetY(lastUserView.frame, height);

			FLUser *user = [[_transaction collectUsers] objectAtIndex:2];

			FLUserView *avatar = [[lastUserView subviews] objectAtIndex:0];
			UILabel *username = [[lastUserView subviews] objectAtIndex:1];

			[avatar setImageFromUser:user];
			username.text = [[user fullname] uppercaseString];

			height = CGRectGetMaxY(lastUserView.frame);
		}
		else if ([[_transaction collectUsers] count] > 3) {
			lastUserView = [self createMiniUserView];
			CGRectSetY(lastUserView.frame, height);

			FLUserView *avatar = [[lastUserView subviews] objectAtIndex:0];
			UILabel *username = [[lastUserView subviews] objectAtIndex:1];

			[avatar setImageFromData:UIImagePNGRepresentation([UIImage imageNamed:@"avatar-participants-thumb"])];
			username.text = [NSLocalizedString(@"EVENT_PARTICIPANTS", nil) uppercaseString];

			height = CGRectGetMaxY(lastUserView.frame);
		}

		[view addSubview:firstUserView];
		[view addSubview:secondUserView];
		[view addSubview:lastUserView];
	}
}

#pragma mark -

@end
