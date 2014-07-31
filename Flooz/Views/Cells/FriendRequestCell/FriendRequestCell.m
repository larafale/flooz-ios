//
//  FriendRequestCell.m
//  Flooz
//
//  Created by jonathan on 2/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendRequestCell.h"

@implementation FriendRequestCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeight{
    return 50;
}

- (void)setFriendRequest:(FLFriendRequest *)friendRequest{
    self->_friendRequest = friendRequest;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor customBackground];
    
    [self createAvatarView];
    [self createTextView];
    [self createPhoneView];
//    [self createSlideView];
//    [self createActionViews];
    
    [self createButtons];
}

- (void)createAvatarView{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(15, 5, 40, 40)];
    [self.contentView addSubview:view];
}

- (void)createTextView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, - 5, CGRectGetWidth(self.frame) - 75, [[self class] getHeight])];
    
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont customTitleLight:13];
    
    [self.contentView addSubview:view];
}

- (void)createPhoneView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, 28, CGRectGetWidth(self.frame) - 75, 9)];
    
    view.font = [UIFont customContentBold:11];
    view.textColor = [UIColor customPlaceholder];
    
    [self.contentView addSubview:view];
}

- (void)createSlideView{
    UIView *slideView = [[UIView alloc] initWithFrame:CGRectMakeSize(2, [[self class] getHeight])];
    slideView.backgroundColor = [UIColor customYellow];
    
    [self.contentView addSubview:slideView];
}

- (void)createActionViews{
    {
        actionView = [[UIView alloc] initWithFrame:CGRectMake(- CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), [[self class] getHeight])];
        
        actionView.backgroundColor = [UIColor customBackgroundHeader];
        
        [self.contentView addSubview:actionView];
    }
    
    {
        JTImageLabel *text = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(actionView.frame) - 30, CGRectGetHeight(actionView.frame))];
        
        [text setImageOffset:CGPointMake(-10, 0)];
        text.textAlignment = NSTextAlignmentRight;
        text.font = [UIFont customTitleExtraLight:14];
        
        [actionView addSubview:text];
    }
    
    {
        UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipe:)];
        swipeGesture.delegate = self;
        [self addGestureRecognizer:swipeGesture];
    }
}

- (void)createButtons
{
    {
        UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 100, 11, 37, 28)];
        [view setImage:[UIImage imageNamed:@"friend-decline"] forState:UIControlStateNormal];
        view.backgroundColor = [UIColor customBackgroundStatus];
        view.layer.cornerRadius = 14;
        
        [view addTarget:self action:@selector(refuse) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:view];
    }
    
    {
        UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 50, 11, 37, 28)];
        [view setImage:[UIImage imageNamed:@"friend-accept"] forState:UIControlStateNormal];
        view.backgroundColor = [UIColor customBackgroundStatus];
        view.layer.cornerRadius = 14;
        
        [view addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:view];
    }
}

#pragma mark - Prepare Views

- (void)prepareViews{
    [self prepareAvatarView];
    [self prepapreTextView];
}

- (void)prepareAvatarView{
    FLUserView *view = [[self.contentView subviews] objectAtIndex:0];
    [view setImageFromUser:[_friendRequest user]];
}

- (void)prepapreTextView{
    UILabel *view = [[self.contentView subviews] objectAtIndex:1];
    view.text = [[[_friendRequest user] fullname] uppercaseString];
    
    UILabel *view2 = [[self.contentView subviews] objectAtIndex:2];
    view2.text = [NSString stringWithFormat:@"@%@", [[_friendRequest user] username]];
}

#pragma mark - Swipe

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer class] == [UIPanGestureRecognizer class]){
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGPoint translation = [gesture translationInView:self];
        if(translation.x > 0.){
            return YES;
        }
    }
    
    NSLog(@"FriendRequestCell: gesture invalid");
    
    return NO;
}

- (void)respondToSwipe:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    CGFloat progress = fabs(translation.x / CGRectGetWidth(self.frame));
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            lastTranslation = CGPointZero;
            totalTranslation = CGPointZero;
            break;
        case UIGestureRecognizerStateChanged:{
            if(translation.x < 0.){
                return;
            }
            
            CGPoint diffTranslation = translation;
            diffTranslation.x -= lastTranslation.x;
            lastTranslation = translation;
            
            totalTranslation.x += diffTranslation.x;
            
            [self moveViews:diffTranslation.x];
            [self updateValidView:progress];
            break;
        }
        case UIGestureRecognizerStateEnded:
            [self completeTranslation:progress];
            break;
        default:
            break;
    }
}

- (void)moveViews:(CGFloat)offsetX
{
    for(UIView *view in self.contentView.subviews){
        view.frame = CGRectOffset(view.frame, offsetX, 0);
    }
}

- (void)completeTranslation:(CGFloat)progress
{
    if(progress >= 0.50){
        if(progress < 0.75){
            [self accept];
        }
        else{
            [self refuse];
        }
    }
    
    totalTranslation.x = - totalTranslation.x;
    
    [UIView animateWithDuration:.3 animations:^{
        [self moveViews:totalTranslation.x];
    }];
}

- (void)updateValidView:(CGFloat)progress
{
    JTImageLabel *text = [[actionView subviews] objectAtIndex:0];
    
    if(progress < 0.50){
        text.text = NSLocalizedString(@"TRANSACTION_ACTION_ACCEPT", nil);
        text.textColor = [UIColor whiteColor];
        [text setImage:[UIImage imageNamed:@"transaction-cell-check-white"]];
    }
    else if(progress < 0.75){
        text.text = NSLocalizedString(@"TRANSACTION_ACTION_ACCEPT", nil);
        text.textColor = [UIColor customGreen];
        [text setImage:[UIImage imageNamed:@"transaction-cell-check"]];
    }
    else{
        text.text = NSLocalizedString(@"TRANSACTION_ACTION_REFUSE", nil);
        text.textColor = [UIColor customRed];
        [text setImage:[UIImage imageNamed:@"transaction-cell-cross"]];
    }
    
    text.center = CGPointMake(text.center.x, actionView.center.y);
}

- (void)accept
{
    [[Flooz sharedInstance] updateFriendRequest:@{ @"id": [_friendRequest requestId], @"action": @"accept" } success:^{
        [_delegate didReloadData];
    }];
}

- (void)refuse
{
    [[Flooz sharedInstance] updateFriendRequest:@{ @"id": [_friendRequest requestId], @"action": @"decline" } success:^{
        [_delegate didReloadData];
    }];
}

@end
