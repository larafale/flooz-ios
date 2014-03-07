//
//  EventHeaderView.m
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventHeaderView.h"

@implementation EventHeaderView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 46);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    [self createTitleView];
    [self createAcceptView];
    [self createBottomBar];
}

- (void)createTitleView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];
    
    view.textAlignment = NSTextAlignmentCenter;
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont customTitleExtraLight:14];
    
    [self addSubview:view];
}

- (void)createAcceptView
{
    
}

- (void)createBottomBar
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    bottomBar.backgroundColor = [UIColor customSeparator:0.5];
    
    [self addSubview:bottomBar];
}

#pragma mark -

- (void)setEvent:(FLEvent *)event{
    self->_event = event;
    [self prepareViews];
}

#pragma mark -

- (void)prepareViews
{
    [self prepareTitleView];
}

- (void)prepareTitleView
{
    UILabel *view = [[self subviews] objectAtIndex:0];
    
    view.text = [[_event title] uppercaseString];
}

@end
