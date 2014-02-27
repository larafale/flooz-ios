//
//  EventActionView.m
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventActionView.h"

@implementation EventActionView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectSetHeight(frame, 55);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    [self createRefuseView];
    [self createAcceptView];
    [self createBottomBar];
}

- (void)createRefuseView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
    [view setImage:[UIImage imageNamed:@"transaction-cell-cross"] forState:UIControlStateNormal];
    [view setTitle:NSLocalizedString(@"EVENT_ACTION_REFUSE", nil) forState:UIControlStateNormal];
    [view setTitleColor:[UIColor customRed] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didRefuseTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:view];
}

- (void)createAcceptView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
    [view setImage:[UIImage imageNamed:@"transaction-cell-check"] forState:UIControlStateNormal];
    [view setTitleColor:[UIColor customGreen] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didAcceptTouch) forControlEvents:UIControlEventTouchUpInside];
    
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
    UIView *refuseView = [[self subviews] objectAtIndex:0];
    UIButton *acceptView = [[self subviews] objectAtIndex:1];
    
    refuseView.hidden = acceptView.hidden = YES;
    
    if([_event isRefusable]){
        refuseView.hidden = acceptView.hidden = NO;
        acceptView.frame = CGRectMake(CGRectGetWidth(self.frame) / 2., 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame));
    }
    else if([_event isAcceptable]){
        acceptView.hidden = NO;
        acceptView.frame = CGRectMakeWithSize(self.frame.size);
    }
    
    NSString *textAccept = NSLocalizedString(@"EVENT_ACTION_ACCEPT", nil);
    if([_event amount] && [[_event amount] floatValue] > 0){
        textAccept = [NSString stringWithFormat:@"%@ : %@", textAccept, [FLHelper formatedAmount:[_event amount]]];
    }
    [acceptView setTitle:textAccept forState:UIControlStateNormal];
}

#pragma mark -

- (void)didAcceptTouch{
    [_delegate showPaymentField];
}

- (void)didRefuseTouch{
    [_delegate refuseEvent];
}

@end
