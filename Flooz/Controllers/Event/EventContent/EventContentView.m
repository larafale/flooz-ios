//
//  EventContentView.m
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventContentView.h"

#import "FLSocialView.h"

#define MARGE_TOP 10.
#define MARGE_BOTTOM 10.
#define MARGE_LEFT_RIGHT 25.

@implementation EventContentView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 0);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    [self createContentView];
    [self createAttachmentView];
    [self createSocialView];
}

- (void)createContentView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 0, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 0)];
    
    view.textColor = [UIColor customPlaceholder];
    view.font = [UIFont customContentLight:12];
    view.numberOfLines = 0;
    
    [self addSubview:view];
}

- (void)createAttachmentView
{
    FLImageView *view = [[FLImageView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 0, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 80)];
    [self addSubview:view];
}

- (void)createSocialView
{
    FLSocialView *view = [[FLSocialView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 0, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 0)];
    [view addTargetForLike:self action:@selector(didLikeButtonTouch)];
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
    height = MARGE_TOP;
    
    [self prepareContentView];
    [self prepareAttachmentView];
    [self prepareSocialView];
    
    height += MARGE_BOTTOM;
    
    CGRectSetHeight(self.frame, height);
}

- (void)prepareContentView
{
    UILabel *view = [[self subviews] objectAtIndex:0];
    CGRectSetY(view.frame, height);
    
    view.text = [_event content];
    [view setHeightToFit];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView
{
    FLImageView *view = [[self subviews] objectAtIndex:1];
    CGRectSetY(view.frame, height + 10);
    
    if([_event attachmentThumbURL]){
        [view setImageWithURL:[NSURL URLWithString:[_event attachmentThumbURL]] fullScreenURL:[NSURL URLWithString:[_event attachmentURL]]];
        height = CGRectGetMaxY(view.frame);
    }
}

- (void)prepareSocialView
{
    FLSocialView *view = [[self subviews] objectAtIndex:2];
    CGRectSetY(view.frame, height + 8);
    
    [view prepareView:_event.social];
    
    height = CGRectGetMaxY(view.frame);
}

#pragma mark - Social action

- (void)didLikeButtonTouch
{
    [[_event social] setIsLiked:![[_event social] isLiked]];
    [[Flooz sharedInstance] createLikeOnEvent:_event success:^(id result) {
        [[_event social] setLikeText:[result objectForKey:@"item"]];
        
        FLSocialView *view = [[self subviews] objectAtIndex:2];
        [view prepareView:_event.social];
        
        [_target performSelector:_action];
    } failure:NULL];
}

- (void)addTargetForLike:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

@end
