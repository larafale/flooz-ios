//
//  TransactionUsersView.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionUsersView.h"
#import "FLUserView.h"

@implementation TransactionUsersView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 155);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    [self createLeftUserView];
    [self createRightUserView];
    [self createSeparators];
}

- (void)createLeftUserView
{
    UIView *view = [self createUserView];
    [self addSubview:view];
}

- (void)createRightUserView
{
    UIView *view = [self createUserView];
    CGRectSetX(view.frame, CGRectGetWidth(self.frame) / 2);
    [self addSubview:view];
}

- (void)createSeparators
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    
    CGFloat x = CGRectGetWidth(self.frame) / 2;
    CGFloat offset = 15;
    CGFloat height = (CGRectGetHeight(self.frame) - offset) / 2.;
    
    UIView *middleTopBar = [[UIView alloc] initWithFrame:CGRectMake(x, 0, 1, height)];
    UIView *middleBottomBar = [[UIView alloc] initWithFrame:CGRectMake(x, height + offset, 1, height)];
    
    bottomBar.backgroundColor = middleTopBar.backgroundColor = middleBottomBar.backgroundColor = [UIColor customSeparator:0.5];
    
    [self addSubview:bottomBar];
    [self addSubview:middleTopBar];
    [self addSubview:middleBottomBar];
    
    UIImageView *arrow = [UIImageView imageNamed:@"transaction-users-arrow"];
    CGRectSetXY(arrow.frame, x - arrow.image.size.width / 2., height + arrow.image.size.height / 2.);
    [self addSubview:arrow];
}

- (UIView *)createUserView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];
    
    FLUserView *avatar = [[FLUserView alloc] initWithFrame:CGRectMakeSize(88, 88)];
    UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(30, 100, CGRectGetWidth(view.frame) - 60, 50)];
    
    [avatar setAlternativeStyle2];
    
    avatar.center = CGRectGetCenter(view.frame);
    avatar.frame = CGRectOffset(avatar.frame, 0, - 20);
        
    username.numberOfLines = 0;
    username.textAlignment = NSTextAlignmentCenter;
    username.textColor = [UIColor whiteColor];
    username.font = [UIFont customTitleExtraLight:12];
    
    [view addSubview:avatar];
    [view addSubview:username];
    
    return view;
}

#pragma mark -

- (void)setTransaction:(FLTransaction *)transaction{
    self->_transaction = transaction;
    [self prepareViews];
}

#pragma mark -

- (void)prepareViews
{
    [self prepareLeftUserView];
    [self prepareRightUserView];
}

- (void)prepareLeftUserView
{
    UIView *view = [[self subviews] objectAtIndex:0];
    FLUserView *avatar = [[view subviews] objectAtIndex:0];
    UILabel *username = [[view subviews] objectAtIndex:1];

    [avatar setImageFromUser:[_transaction from]];
    username.text = [[[_transaction from] fullname] uppercaseString];
}

- (void)prepareRightUserView
{
    UIView *view = [[self subviews] objectAtIndex:1];
    FLUserView *avatar = [[view subviews] objectAtIndex:0];
    UILabel *username = [[view subviews] objectAtIndex:1];
    
    [avatar setImageFromUser:[_transaction to]];
    username.text = [[[_transaction to] fullname] uppercaseString];
}

@end
