//
//  EventAmountView.m
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventAmountView.h"

#define MARGE_BOTTOM 20.
#define MARGE_LEFT_RIGHT 0.

#define AMOUNT_VIEW_HEIGHT 39.

@implementation EventAmountView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeightForEvent:(FLEvent *)event
{
    CGFloat _height = AMOUNT_VIEW_HEIGHT + MARGE_BOTTOM;
    
    return _height;
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
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(amountView.frame), 27)];
        view.textColor = [UIColor customBlue];
        view.font = [UIFont customTitleExtraLight:35];
        
        [amountView addSubview:view];
    }
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, CGRectGetWidth(amountView.frame), 12)];
        view.textColor = [UIColor customBlue];
        view.font = [UIFont customContentRegular:13];
        
        [amountView addSubview:view];
    }
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 17.5, CGRectGetWidth(amountView.frame), 11)];
        
        view.font = [UIFont customContentRegular:11];
        
        [amountView addSubview:view];
    }
    
    [self addSubview:amountView];
}

- (void)createSeparatorView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(amountView.frame), 0, 1, AMOUNT_VIEW_HEIGHT + 5)];
    
    {
        view.backgroundColor = [UIColor customSeparator];
    }
    
    [self addSubview:view];
}

- (void)createDayVew
{
    dayView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(amountView.frame) + 20, 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(amountView.frame) - MARGE_LEFT_RIGHT - MARGE_LEFT_RIGHT, AMOUNT_VIEW_HEIGHT)];
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(dayView.frame), 27)];
        view.textColor = [UIColor whiteColor];
        view.font = [UIFont customTitleExtraLight:35];
        
        [dayView addSubview:view];
    }
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(dayView.frame) - 6, CGRectGetWidth(dayView.frame), 11)];
        
        view.textColor = [UIColor whiteColor];
        view.font = [UIFont customContentRegular:11];
        
        view.text = NSLocalizedString(@"EVENT_HEADER_DAY_LEFT", nil);
        
        [dayView addSubview:view];
    }
    
    {
        UIImageView *view = [UIImageView imageNamed:@"alertview-success"];
        CGRectSetXY(view.frame, 0, -3);
        CGRectSetWidthHeight(view.frame, CGRectGetWidth(view.frame) * .75, CGRectGetWidth(view.frame) * .75);
        [dayView addSubview:view];
    }
    
    [self addSubview:dayView];
}

- (void)createProgressBarView
{
    progressBarView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, CGRectGetMaxY(amountView.frame), CGRectGetWidth(amountView.frame) - 15, 2)];
    
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(- self.frame.origin.x, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame) + 2 * (self.frame.origin.x), 1)];
    
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
        UILabel *integral = [[amountView subviews] objectAtIndex:0];
        UILabel *decimal = [[amountView subviews] objectAtIndex:1];

        integral.text = [NSString stringWithFormat:@"%ld", (long)[[_event amountCollected] integerValue]];
        
        if([[_event amountCollected] integerValue] == [[_event amountCollected] floatValue]){
            decimal.text = NSLocalizedString(@"GLOBAL_EURO", nil);
        }
        else{
            double integralDouble;
            decimal.text = [[NSString stringWithFormat:@"%.2f%@", modf([[_event amountCollected] floatValue], &integralDouble), NSLocalizedString(@"GLOBAL_EURO", nil)] substringFromIndex:1];
        }
        
        
        [integral setWidthToFit];
        [decimal setWidthToFit];
        CGRectSetX(decimal.frame, CGRectGetMaxX(integral.frame) + 2);
   
        
        
        UILabel *collectText = [[amountView subviews] objectAtIndex:2];
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"EVENT_HEADER_MONEY_COLLECTED", nil) attributes:@{ NSForegroundColorAttributeName: [UIColor customBlue]}];
        
        if([_event amountExpected]){
            NSMutableAttributedString *attributedText2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" / %@",[FLHelper formatedAmount:[_event amountExpected] withSymbol:NO]] attributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor]}];
            
            [attributedText appendAttributedString:attributedText2];
        }
        
        collectText.attributedText = attributedText;
        CGRectSetX(collectText.frame, CGRectGetMaxX(integral.frame) + 2);
    }
}

- (void)prepareDayView
{
    UILabel *dayTextView = [[dayView subviews] objectAtIndex:0];
    UILabel *labelTextView = [[dayView subviews] objectAtIndex:1];
    UIImageView *imageView = [[dayView subviews] objectAtIndex:2];
    
    if([_event isClosed]){
        dayTextView.text = @"";
        labelTextView.text = NSLocalizedString(@"EVENT_HEADER_DAY_LEFT_CLOSED", nil);
        imageView.hidden = NO;
    }
    else{
        dayTextView.text = [NSString stringWithFormat:@"%.2d", [[_event dayLeft] intValue]];
        labelTextView.text = NSLocalizedString(@"EVENT_HEADER_DAY_LEFT", nil);
        imageView.hidden = YES;
    }
}

- (void)prepareProgressBarView
{
    UIView *view = [[progressBarView subviews] objectAtIndex:0];
        
    if(![_event amountExpected]){
        progressBarView.hidden = YES;
        return;
    }
    
    progressBarView.hidden = NO;
    CGRectSetWidth(view.frame, CGRectGetWidth(progressBarView.frame) * [[_event pourcentage] floatValue] / 100.0);
}

- (void)prepareSeparatorBottomView
{
    UIView *view = [[self subviews] lastObject];
    
    CGRectSetY(view.frame, height - 1);
}

- (void)hideBottomBar
{
    UIView *view = [[self subviews] lastObject];
    view.hidden = YES;
}

@end
