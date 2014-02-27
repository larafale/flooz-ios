//
//  EventUsersView.m
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventUsersView.h"
#import "FLUserView.h"

@implementation EventUsersView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectSetHeight(frame, 155);
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
    view.frame = CGRectSetX(view.frame, CGRectGetWidth(self.frame) / 2);
    
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAddParticipantTouch)]];
    
    [self addSubview:view];
}

- (void)createSeparators
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    UIView *middleBar = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, 1, CGRectGetHeight(self.frame))];
    
    bottomBar.backgroundColor = middleBar.backgroundColor = [UIColor customSeparator:0.5];
    
    [self addSubview:bottomBar];
    [self addSubview:middleBar];
}

- (UIView *)createUserView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];
    
    FLUserView *avatar = [[FLUserView alloc] initWithFrame:CGRectMakeSize(88, 88)];
    UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(view.frame), 50)];
    
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

- (void)setEvent:(FLEvent *)event{
    self->_event = event;
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
    
    [avatar setImageFromUser:[_event creator]];
    username.text = [[[_event creator] fullname] uppercaseString];
}

- (void)prepareRightUserView
{
    UIView *view = [[self subviews] objectAtIndex:1];
//    FLUserView *avatar = [[view subviews] objectAtIndex:0];
    UILabel *username = [[view subviews] objectAtIndex:1];
    
    username.text = [NSLocalizedString(@"EVENT_INVITE_PARTICIPANT", nil) uppercaseString];
}

#pragma mark -

- (void)didAddParticipantTouch
{
    [_delegate presentEventParticipantsController];
}

@end
