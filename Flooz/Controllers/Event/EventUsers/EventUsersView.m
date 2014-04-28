//
//  EventUsersView.m
//  Flooz
//
//  Created by jonathan on 2/26/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventUsersView.h"
#import "FLUserView.h"

@implementation EventUsersView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 155);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    [self createLeftUserView];
    [self createRightUserView];
    [self createSeparators];
}

- (void)createLeftUserView
{
    UIView *view = [self createUserView];
    [self addSubview:view];
}

- (void)createRightUserView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) / 2), 0, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];

    [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didParticipantsTouch)]];
    
    [self addSubview:view];
}

- (void)createSeparators
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    UIView *middleBar = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2., 0, 1, CGRectGetHeight(self.frame))];
    
    bottomBar.backgroundColor = middleBar.backgroundColor = [UIColor customSeparator:0.5];
    
    [self addSubview:bottomBar];
    [self addSubview:middleBar];
}

- (UIView *)createUserView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame))];
    
    {
        FLUserView *avatar = [[FLUserView alloc] initWithFrame:CGRectMakeSize(88, 88)];

        avatar.center = CGRectGetFrameCenter(view.frame);
        avatar.frame = CGRectOffset(avatar.frame, 0, - 20);
        
        [view addSubview:avatar];
    }
    
    {
        UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, CGRectGetWidth(view.frame), 50)];
        
        username.numberOfLines = 0;
        username.textAlignment = NSTextAlignmentCenter;
        username.textColor = [UIColor whiteColor];
        username.font = [UIFont customTitleExtraLight:12];
        
        [view addSubview:username];
    }
    
    return view;
}

- (UIView *)createMiniUserView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 2, 45)];
    
    {
        FLUserView *avatar = [[FLUserView alloc] initWithFrame:CGRectMakeSize(40, 40)];
        avatar.frame = CGRectOffset(avatar.frame, 16, 2.5);
                
        [view addSubview:avatar];
    }
    
    {
        UILabel *username = [[UILabel alloc] initWithFrame:CGRectMake(62, 0, CGRectGetWidth(view.frame) - 62, CGRectGetHeight(view.frame))];
        
        username.numberOfLines = 0;
        username.textColor = [UIColor whiteColor];
        username.font = [UIFont customTitleExtraLight:10];
        
        [view addSubview:username];
    }
    
    return view;
}

#pragma mark -

- (void)setEvent:(FLEvent *)event{
    self->_event = event;
    [self prepareViews];
}

#pragma mark -

- (void)prepareViews
{
    [self prepareLeftUserView];
    [self prepareRightUserView];
}

- (void)prepareLeftUserView
{
    UIView *view = [[self subviews] objectAtIndex:0];
    FLUserView *avatar = [[view subviews] objectAtIndex:0];
    UILabel *username = [[view subviews] objectAtIndex:1];
    
    [avatar setImageFromUser:[_event creator]];
    username.text = [[[_event creator] fullname] uppercaseString];
}

- (void)prepareRightUserView
{
    UIView *view = [[self subviews] objectAtIndex:1];
    
    for(UIView *subview in [view subviews]){
        [subview removeFromSuperview];
    }
    
    if([[_event participants] count] > 0){
        CGFloat MARGE_TOP_BOTTOM = 9.;
        CGFloat height = 0;
        
        UIView *firstUserView = [self createMiniUserView];
        UIView *secondUserView = nil;
        UIView *lastUserView = [self createMiniUserView];
        
        {
            CGRectSetY(firstUserView.frame, MARGE_TOP_BOTTOM);
            FLUser *user = [[_event participants] objectAtIndex:0];
            
            FLUserView *avatar = [[firstUserView subviews] objectAtIndex:0];
            UILabel *username = [[firstUserView subviews] objectAtIndex:1];
            
            [avatar setImageFromUser:user];
            username.text = [[user fullname] uppercaseString];
            
            height = CGRectGetMaxY(firstUserView.frame);
        }
        
        if([[_event participants] count] > 1){
            secondUserView = [self createMiniUserView];
            CGRectSetY(secondUserView.frame, height);
            
            FLUser *user = [[_event participants] objectAtIndex:1];
            
            FLUserView *avatar = [[secondUserView subviews] objectAtIndex:0];
            UILabel *username = [[secondUserView subviews] objectAtIndex:1];
            
            [avatar setImageFromUser:user];
            username.text = [[user fullname] uppercaseString];
            
            height = CGRectGetMaxY(secondUserView.frame);
        }
        
        {
            CGRectSetY(lastUserView.frame, height);
            FLUserView *avatar = [[lastUserView subviews] objectAtIndex:0];
            UILabel *username = [[lastUserView subviews] objectAtIndex:1];
            
            [avatar setImageFromData:UIImagePNGRepresentation([UIImage imageNamed:@"avatar-participants-thumb"])];
            
            if([[_event participants] count] > 2){
                 username.text = [NSString stringWithFormat:[NSLocalizedString(@"EVENT_PARTICIPANTS_INVITED", nil) uppercaseString], [[_event participants] count] - 2];
            }
            else{
                username.text = [NSLocalizedString(@"EVENT_INVITE_PARTICIPANT", nil) uppercaseString];
            }
        }
        
        
        [view addSubview:firstUserView];
        [view addSubview:secondUserView];
        [view addSubview:lastUserView];
    }
    else{
        UIView *contentView = [self createUserView];
        FLUserView *avatar = [[contentView subviews] objectAtIndex:0];
        UILabel *username = [[contentView subviews] objectAtIndex:1];
        
        [avatar setImageFromData:UIImagePNGRepresentation([UIImage imageNamed:@"avatar-participants"])];
    
        username.text = [NSLocalizedString(@"EVENT_INVITE_PARTICIPANT", nil) uppercaseString];
        
        [view addSubview:contentView];
        
        
        {
            CGFloat gradientWidth = 20;
            CAGradientLayer *gradientMask = [CAGradientLayer layer];
            gradientMask.frame = username.bounds;
            CGFloat gradientSize = gradientWidth / username.frame.size.width;
            UIColor *gradient = [UIColor colorWithWhite:1.0f alpha:.3];
            UIView *superview = username.superview;
            NSArray *startLocations = @[[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:(gradientSize / 2)], [NSNumber numberWithFloat:gradientSize]];
            NSArray *endLocations = @[[NSNumber numberWithFloat:(1.0f - gradientSize)], [NSNumber numberWithFloat:(1.0f -(gradientSize / 2))], [NSNumber numberWithFloat:1.0f]];
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
            
            gradientMask.colors = @[(id)gradient.CGColor, (id)[UIColor whiteColor].CGColor, (id)gradient.CGColor];
            gradientMask.locations = startLocations;
            gradientMask.startPoint = CGPointMake(0 - (gradientSize * 2), .5);
            gradientMask.endPoint = CGPointMake(1 + gradientSize, .5);
            
            [username removeFromSuperview];
            username.layer.mask = gradientMask;
            [superview addSubview:username];
            
            animation.fromValue = startLocations;
            animation.toValue = endLocations;
            animation.repeatCount = HUGE_VALF;
            animation.duration  = 2.0f;
            
            [gradientMask addAnimation:animation forKey:@"animateGradient"];
        }
    }
}

#pragma mark -

- (void)didParticipantsTouch
{
    [_delegate presentEventParticipantsController];
}

@end
