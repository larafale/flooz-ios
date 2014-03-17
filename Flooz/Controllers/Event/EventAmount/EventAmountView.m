//
//  EventAmountView.m
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventAmountView.h"

@implementation EventAmountView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 50);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    self.backgroundColor = [UIColor customBackground:0.4];
    
    [self createTitleView];
    [self createAmountView];
    [self createBottomBar];
}

- (void)createTitleView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMakeSize(self.frame.size.width, 30)];
    
    view.textAlignment = NSTextAlignmentCenter;
    view.textColor = [UIColor customBlue];
    view.font = [UIFont customContentRegular:12];
    
    view.text = NSLocalizedString(@"EVENT_AMOUNT", nil);
    
    [self addSubview:view];
}

- (void)createAmountView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 10)];
    
    view.textAlignment = NSTextAlignmentCenter;
    view.textColor = [UIColor customBlue];
    view.font = [UIFont customTitleExtraLight:24];
    
    [self addSubview:view];
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
    height = 0;
    
    [self prepareAmountView];
    
    CGRectSetHeight(self.frame, height);
}

- (void)prepareAmountView
{
    UILabel *view = [[self subviews] objectAtIndex:1];
    view.text = [FLHelper formatedAmount:[_event amountCollect] withSymbol:NO];
    height = CGRectGetMaxY(view.frame);
}

@end
