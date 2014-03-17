//
//  TransactionAmount.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionAmountView.h"

#define HEIGHT 50

@implementation TransactionAmountView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, HEIGHT);
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
    [self createBottomBar];
}

- (void)createTitleView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];
    CGRectSetY(view.frame, - 3);
    
    view.backgroundColor = [UIColor clearColor];
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

- (void)setTransaction:(FLTransaction *)transaction{
    self->_transaction = transaction;
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
    
    if(![_transaction amount]){
        CGRectSetHeight(self.frame, 0);
    }
    
    view.text = [FLHelper formatedAmount:[_transaction amount]];
    CGRectSetHeight(self.frame, HEIGHT);
}

@end
