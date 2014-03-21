//
//  EventAmountView.m
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventAmountView.h"

#define MARGE_BOTTOM 24.
#define MARGE_LEFT_RIGHT 21.

#define AMOUNT_VIEW_HEIGHT 39.

@implementation EventAmountView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, AMOUNT_VIEW_HEIGHT + MARGE_BOTTOM);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    [self createAmountView];
    [self createSeparatorView];
    [self createDayVew];
    [self createProgressBarView];
    [self createSeparatorBottomView];
}

- (void)createAmountView
{
    amountView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 0, (CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT)) * 0.65, AMOUNT_VIEW_HEIGHT)];
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(amountView.frame), 20)];
        view.textColor = [UIColor customBlue];
        view.font = [UIFont customTitleExtraLight:26];
        
        [amountView addSubview:view];
    }
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(amountView.frame) - 11, CGRectGetWidth(amountView.frame), 11)];
        
        view.font = [UIFont customTitleExtraLight:10];
        
        [amountView addSubview:view];
    }
    
    [self addSubview:amountView];
}

- (void)createSeparatorView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(amountView.frame), 0, 1, AMOUNT_VIEW_HEIGHT)];
    
    {
        view.backgroundColor = [UIColor customSeparator];
    }
    
    [self addSubview:view];
}

- (void)createDayVew
{
    dayView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(amountView.frame) + MARGE_LEFT_RIGHT, 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(amountView.frame) - MARGE_LEFT_RIGHT - MARGE_LEFT_RIGHT, AMOUNT_VIEW_HEIGHT)];
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(dayView.frame), 20)];
        view.textColor = [UIColor whiteColor];
        view.font = [UIFont customTitleExtraLight:26];
        
        [dayView addSubview:view];
    }
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(dayView.frame) - 11, CGRectGetWidth(dayView.frame), 11)];
        
        view.textColor = [UIColor whiteColor];
        view.font = [UIFont customTitleExtraLight:10];
        
        view.text = NSLocalizedString(@"EVENT_HEADER_DAY_LEFT", nil);
        
        [dayView addSubview:view];
    }
    
    [self addSubview:dayView];
}

- (void)createProgressBarView
{
    progressBarView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, CGRectGetMaxY(amountView.frame) + MARGE_BOTTOM / 2., CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 2)];
    
    {
        progressBarView.backgroundColor = [UIColor customSeparator];
    }
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(progressBarView.frame))];
        view.backgroundColor = [UIColor customBlue];
        
        [progressBarView addSubview:view];
    }
    
    [self addSubview:progressBarView];
}

- (void)createSeparatorBottomView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    
    {
        view.backgroundColor = [UIColor customSeparator:0.5];
    }
    
    [self addSubview:view];
}

#pragma mark -

- (void)setEvent:(FLEvent *)event
{
    self->_event = event;
    [self prepareViews];
}

#pragma mark -

- (void)prepareViews
{
    height = AMOUNT_VIEW_HEIGHT + MARGE_BOTTOM;
    
    [self prepareAmountView];
    [self prepareDayView];
    
    [self prepareProgressBarView];
    [self prepareSeparatorBottomView];
    
    CGRectSetHeight(self.frame, height);
}

- (void)prepareAmountView
{
    {
        UILabel *view = [[amountView subviews] objectAtIndex:0];
        view.text = [FLHelper formatedAmount:[_event amountCollected]];
    }
    
    {
        UILabel *view = [[amountView subviews] objectAtIndex:1];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"EVENT_HEADER_MONEY_COLLECTED", nil) attributes:@{ NSForegroundColorAttributeName: [UIColor customBlue]}];
        
        if([_event amountExpected]){
            NSMutableAttributedString *attributedText2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" / %@",[FLHelper formatedAmount:[_event amountExpected] withSymbol:NO]] attributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor]}];
            
            [attributedText appendAttributedString:attributedText2];
        }
        
        view.attributedText = attributedText;
    }
}

- (void)prepareDayView
{
    UILabel *view = [[dayView subviews] objectAtIndex:0];
    view.text = [NSString stringWithFormat:@"%.2d", [[_event dayLeft] intValue]];
}

- (void)prepareProgressBarView
{
    UIView *view = [[progressBarView subviews] objectAtIndex:0];
    
    if(![_event amountExpected]){
        view.hidden = YES;
        return;
    }
    
    view.hidden = NO;
    CGRectSetWidth(view.frame, CGRectGetWidth(progressBarView.frame) * 0.4);
    
    height += MARGE_BOTTOM / 2.;
}

- (void)prepareSeparatorBottomView
{
    UIView *view = [[self subviews] lastObject];
    
    CGRectSetY(view.frame, height - 1);
}

@end
