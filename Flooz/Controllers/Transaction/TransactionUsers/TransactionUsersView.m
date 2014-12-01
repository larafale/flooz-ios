//
//  TransactionUsersView.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "TransactionUsersView.h"
#import "FLUserView.h"
#import "AppDelegate.h"

@implementation TransactionUsersView

- (id)initWithFrame:(CGRect)frame {
	CGRectSetHeight(frame, 140);
	self = [super initWithFrame:frame];
	if (self) {
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
	leftUserView = [self createUserView];
	[self addSubview:leftUserView];

	UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didUserLeftViewTouch)];
	[leftUserView addGestureRecognizer:touch];
}

- (void)createRightUserView {
	rightUserView = [self createUserView];
	CGRectSetX(rightUserView.frame, CGRectGetWidth(self.frame) / 2);
	[self addSubview:rightUserView];

	UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didUserRightViewTouch)];
	[rightUserView addGestureRecognizer:touch];
}

- (void)createSeparators {
	CGFloat x = CGRectGetWidth(self.frame) / 2;
	CGFloat offset = 15;
	CGFloat height = (CGRectGetHeight(self.frame) - offset) / 2.;

	UIImageView *arrow = [UIImageView imageNamed:@"transaction-users-arrow"];
	CGRectSetXY(arrow.frame, x - arrow.image.size.width / 2., height + arrow.image.size.height / 2.);
	[self addSubview:arrow];
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
		UILabel *fullname = [[UILabel alloc] initWithFrame:CGRectMake(0, 88, CGRectGetWidth(view.frame), 30)];

		fullname.numberOfLines = 0;
		fullname.textAlignment = NSTextAlignmentCenter;
		fullname.textColor = [UIColor whiteColor];
		fullname.font = [UIFont customTitleExtraLight:12];

        [view addSubview:fullname];
	}

	{
		UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(0, 118, CGRectGetWidth(view.frame), 20)];

		username.font = [UIFont customContentBold:11];
		username.textAlignment = NSTextAlignmentCenter;
		username.textColor = [UIColor customBlue];

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
    [self modifyUserView:0 withUser:[_transaction from]];
}

- (void)prepareRightUserView {
    [self modifyUserView:1 withUser:[_transaction to]];
}

- (void)modifyUserView:(NSInteger)side withUser:(FLUser *)user {
    UIView *view = [[self subviews] objectAtIndex:side];
    FLUserView *avatar = [[view subviews] objectAtIndex:0];
    UILabel *fullname = [[view subviews] objectAtIndex:1];
    UILabel *username = [[view subviews] objectAtIndex:2];
    
    [avatar setImageFromUser:user];
    
    CGRectSetY(fullname.frame, CGRectGetMaxY(avatar.frame) + 8.0f);
    fullname.text = [[user fullname] uppercaseString];
    [fullname setHeightToFit];
    
    if ([user username]) {
        username.text = [@"@" stringByAppendingString :[user username]];
    }
    else {
        username.text = @"";
    }
    CGRectSetY(username.frame, CGRectGetMaxY(fullname.frame));
    [username setHeightToFit];
}

#pragma mark -

- (void)didUserLeftViewTouch {
	if ([[[_transaction from] userId] isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]) {
		return;
	}

	[appDelegate showMenuForUser:[_transaction from] imageView:[[leftUserView subviews] firstObject]];
}

- (void)didUserRightViewTouch {
	if ([[[_transaction to] userId] isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]) {
		return;
	}

	[appDelegate showMenuForUser:[_transaction to] imageView:[[rightUserView subviews] firstObject]];
}

@end
