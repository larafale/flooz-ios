//
//  TransactionAmount.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionAmountView.h"

@implementation TransactionAmountView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectSetHeight(frame, 50);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    [self createTitleView];
    [self createBottomBar];
}

- (void)createTitleView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];
    
    view.backgroundColor = [UIColor customBackground:0.4];
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
    height = 0;

    [self prepareTitleView];
    
    self.frame = CGRectSetHeight(self.frame, height);
}

- (void)prepareTitleView
{
    UILabel *view = [[self subviews] objectAtIndex:0];
    
    if(![_transaction amount]){
        return;
    }
    
    view.text = [FLHelper formatedAmount:[_transaction amount]];
    height = CGRectGetMaxY(view.frame);
}

@end
