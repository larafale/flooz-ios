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
    CGRectSetHeight(frame, 55);
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
    [view setTitleColor:[UIColor customRed] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didRefuseTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:view];
}

- (void)createAcceptView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    
    view.backgroundColor = [UIColor customBlue];
    
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    view.titleLabel.font = [UIFont customTitleExtraLight:14];
    [view setImageEdgeInsets:UIEdgeInsetsMake(2, -10, 0, 0)];
    
    [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [view addTarget:self action:@selector(didAcceptTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    {
        arrow = [UIImageView imageNamed:@"arrow-white-right"];
        CGRectSetXY(arrow.frame, CGRectGetWidth(self.frame) - 20, (CGRectGetHeight(view.frame) - arrow.image.size.height) / 2.);
        [view addSubview:arrow];
    }
    
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
    UIButton *refuseView = [[self subviews] objectAtIndex:0];
    UIButton *acceptView = [[self subviews] objectAtIndex:1];
    
    NSString *textAccept = nil;
    NSString *textRefuse = nil;
    
    if([_event canParticipate]){
        textAccept = NSLocalizedString(@"EVENT_ACTION_PARTICIPATE", nil);
        if([_event amount] && [[_event amount] floatValue] > 0){
            textAccept = [NSString stringWithFormat:@"%@ : %@", textAccept, [FLHelper formatedAmount:[_event amount]]];
        }
        
        if([_event canDeclineInvite]){
            textRefuse = NSLocalizedString(@"EVENT_ACTION_REFUSE", nil);
        }
    }
    else if([_event canAcceptOrDeclineOffer]){
        textAccept = NSLocalizedString(@"EVENT_ACTION_ACCEPT", nil);
        textRefuse = NSLocalizedString(@"EVENT_ACTION_DECLINE", nil);
    }
    else if([_event canCancelOffer]){
        textRefuse = NSLocalizedString(@"EVENT_ACTION_CANCEL", nil);
    }
    
    if(textAccept && textRefuse){
        acceptView.frame = CGRectMake(CGRectGetWidth(self.frame) / 2., 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame));
        refuseView.frame = CGRectMakeSize(CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame));
        refuseView.hidden = NO;
        acceptView.hidden = NO;
    }
    else if(textAccept){
        acceptView.frame = CGRectMakeWithSize(self.frame.size);
        refuseView.hidden = YES;
        acceptView.hidden = NO;
    }
    else if(textRefuse){
        refuseView.frame = CGRectMakeWithSize(self.frame.size);
        refuseView.hidden = NO;
        acceptView.hidden = YES;
    }
    
    [acceptView setTitle:textAccept forState:UIControlStateNormal];
    [refuseView setTitle:textRefuse forState:UIControlStateNormal];
}

#pragma mark -

- (void)didAcceptTouch:(UIButton *)button
{
    if([_event canParticipate]){
        if(button.selected){
            button.selected = NO;
            [UIView animateWithDuration:.5 animations:^{
                [_delegate hidePaymentField];
                arrow.transform = CGAffineTransformMakeRotation(0);
            }];
        }
        else{
            button.selected = YES;
            [UIView animateWithDuration:.5 animations:^{
                [_delegate showPaymentField];
                arrow.transform = CGAffineTransformMakeRotation(M_PI_2);
            }];
        }
    }
    else if([_event canAcceptOrDeclineOffer]){
        [_delegate didUpdateEventWithAction:EventActionAcceptOffer];
    }
}

- (void)didRefuseTouch{
    if([_event canParticipate]){
        [_delegate didUpdateEventWithAction:EventActionDeclineInvite];
    }
    else if([_event canAcceptOrDeclineOffer]){
        [_delegate didUpdateEventWithAction:EventActionDeclineOffer];
    }
    else if([_event canCancelOffer]){
        [_delegate didUpdateEventWithAction:EventActionCancelOffer];
    }
}

- (void)setSelected:(BOOL)selected
{
    UIButton *acceptView = [[self subviews] objectAtIndex:1];
    acceptView.selected = selected;
    
    if(selected){
        arrow.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else{
        arrow.transform = CGAffineTransformMakeRotation(0);
    }
}

@end
