//
//  EventAmountActionsView.m
//  Flooz
//
//  Created by jonathan on 2/28/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventAmountActionsView.h"

@implementation EventAmountActionsView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 58);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews{
    [self createLeftButton];
    [self createRightButton];
    [self createSeparatorView];
    [self createBottomBarView];
}

- (void)createLeftButton{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    
    view.titleLabel.font = [UIFont customContentRegular:12];
    [view setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
    
    [view setTitle:NSLocalizedString(@"EVENT_ACTION_COLLECT", nil) forState:UIControlStateNormal];
    [view setImage:[UIImage imageNamed:@"event-actions-collect"] forState:UIControlStateNormal];
    [view addTarget:self action:@selector(didCollectTouch) forControlEvents:UIControlEventTouchUpInside];
    [view setTitleEdgeInsets:UIEdgeInsetsMake(3, 15, 0, 0)];
    
    [self addSubview:view];
}

- (void)createRightButton{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, CGRectGetWidth(self.frame) / 2., CGRectGetHeight(self.frame))];
    
    view.titleLabel.font = [UIFont customContentRegular:12];
    [view setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
    
    [view setTitle:NSLocalizedString(@"EVENT_ACTION_OFFER", nil) forState:UIControlStateNormal];
    [view setImage:[UIImage imageNamed:@"event-actions-offer"] forState:UIControlStateNormal];
    [view addTarget:self action:@selector(didOfferTouch) forControlEvents:UIControlEventTouchUpInside];
    [view setTitleEdgeInsets:UIEdgeInsetsMake(3, 15, 0, 0)];
    
    [self addSubview:view];
}

- (void)createSeparatorView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, 1, CGRectGetHeight(self.frame))];
    
    view.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:view];
}

- (void)createBottomBarView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1,  CGRectGetWidth(self.frame), 0.5)];
    
    view.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:view];
}

#pragma mark -

- (void)setEvent:(FLEvent *)event{
    self->_event = event;
    [self prepareViews];
}

#pragma mark -

- (void)prepareViews
{

}

#pragma mark -

- (void)didCollectTouch{
    [_delegate collectEvent];
}

- (void)didOfferTouch{
    [_delegate offerEvent];
}

@end
