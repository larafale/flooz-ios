//
//  TransactionUsersView.m
//  Flooz
//
//  Created by olivier on 2/7/2014.
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

    UIImageView *arrow  = [[UIImageView alloc] initWithFrame:CGRectMake(x - (35/2), 35, 35, 35)];
    arrow.image = [[UIImage imageNamed:@"transaction-users-arrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    arrow.tintColor = [UIColor colorWithIntegerRed:54 green:70 blue:86 alpha:1.0f];
    arrow.contentMode = UIViewContentModeScaleAspectFit;

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
		UILabel *fullname = [[UILabel alloc] initWithFrame:CGRectMake(5, 88, CGRectGetWidth(view.frame) - 10, 20)];

		fullname.numberOfLines = 1;
		fullname.textAlignment = NSTextAlignmentCenter;
		fullname.textColor = [UIColor whiteColor];
		fullname.font = [UIFont customTitleExtraLight:14];
        fullname.adjustsFontSizeToFitWidth = YES;
        fullname.minimumScaleFactor = 8. / fullname.font.pointSize;

        [view addSubview:fullname];
	}

	{
		UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(0, 118, CGRectGetWidth(view.frame), 20)];

		username.font = [UIFont customContentBold:12];
		username.textAlignment = NSTextAlignmentCenter;
		username.textColor = [UIColor customBlue];

		[view addSubview:username];
	}

    {
        UIImageView *star = [[UIImageView alloc] initWithFrame:CGRectMake(0, 95, 12, 12)];
        [star setImage:[UIImage imageNamed:@"certified"]];
        [star setContentMode:UIViewContentModeScaleAspectFit];

        [view addSubview:star];
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
    UIImageView *star = [[view subviews] objectAtIndex:3];
    
    [avatar setImageFromUser:user];
    
    fullname.text = [[user fullname] uppercaseString];
//    [fullname setHeightToFit];
//    [fullname setWidthToFit];

    CGRectSetY(fullname.frame, CGRectGetMaxY(avatar.frame) + 8.0f);
    CGRectSetX(fullname.frame, CGRectGetWidth(view.frame) / 2 - CGRectGetWidth(fullname.frame) / 2);
    
    if (user.isCertified) {
        [star setHidden:NO];
        star.center = fullname.center;
        CGRectSetX(star.frame, CGRectGetMaxX(fullname.frame) - CGRectGetWidth(fullname.frame) / 2 + [fullname widthToFit] / 2 + 5);
    } else {
        [star setHidden:YES];
    }
    
    if ([user username]) {
        username.text = [@"@" stringByAppendingString :[user username]];
    }
    else {
        username.text = @"";
    }
    CGRectSetY(username.frame, CGRectGetMaxY(fullname.frame) + 2);
    [username setHeightToFit];
}

#pragma mark -

- (void)didUserLeftViewTouch {
    [[_transaction from] setSelectedCanal:TimelineCanal];
    [appDelegate showUser:[_transaction from] inController:self.parentViewController];
}

- (void)didUserRightViewTouch {
    [[_transaction to] setSelectedCanal:TimelineCanal];
    [appDelegate showUser:[_transaction to] inController:self.parentViewController];
}

@end
