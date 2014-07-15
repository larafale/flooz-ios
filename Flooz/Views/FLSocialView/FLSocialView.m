//
//  FLSocialView.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLSocialView.h"

#define OFFSET 23.

@implementation FLSocialView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 15);
    self = [super initWithFrame:frame];
    if (self) {
        _isEvent = NO;
        _gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didLikeTouch)];
        [self createView];
    }
    return self;
}

- (void)createView
{
    comment = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(self.frame))];
    like = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(self.frame))];
    scope = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(self.frame))];
    
    comment.font = [UIFont customContentRegular:11];
    like.font = [UIFont customContentRegular:11];
    scope.font = [UIFont customContentRegular:11];
    

    like.userInteractionEnabled = YES;
    [like addGestureRecognizer:_gesture];
    
    scope.textColor = [UIColor customPlaceholder];
    
    [self addSubview:comment];
    [self addSubview:like];
    [self addSubview:scope];
}

- (void)prepareView:(FLSocial *)social
{
    CGFloat x = 0;
    
    if(_isEvent){
        scope.hidden = YES;
        scope.image = nil;
    }
    else{
        scope.hidden = NO;
        
        switch ([social scope]) {
            case SocialScopePrivate:
                scope.image = [UIImage imageNamed:@"scope-private"];
                break;
            case SocialScopeFriend:
                scope.image = [UIImage imageNamed:@"scope-friend"];
                break;
            case SocialScopePublic:
                scope.image = [UIImage imageNamed:@"scope-public"];
                break;
            default:
                scope.image = nil;
                break;
        }
        
        [scope setImageOffset:CGPointMake(-2.5, -1)];
        [scope setWidthToFit];
        CGRectSetWidth(scope.frame, CGRectGetWidth(scope.frame) + OFFSET);
        
        x = CGRectGetMaxX(scope.frame);
    }
    
    {
        if(social.likesCount == 0){
            like.text = NSLocalizedString(@"CELL_SOCIAL_LIKE", nil);
        }
        else{
            like.text = social.likeText;
        }
        
        if(social.isLiked){
            like.textColor = [UIColor customBlue];
            [like setImage:[UIImage imageNamed:@"social-like-selected"]];
        }
        else{
            like.textColor = [UIColor customPlaceholder];
            [like setImage:[UIImage imageNamed:@"social-like"]];
        }
        
        [like setImageOffset:CGPointMake(-2.5, -1)];
        [like setWidthToFit];
        
        CGRectSetX(like.frame, x);
        CGRectSetWidth(like.frame, CGRectGetWidth(like.frame) + OFFSET);
        x = CGRectGetMaxX(like.frame);
    }
    
    {
        if(social.commentsCount == 0){
            comment.hidden = YES;
        }
        else{
            comment.hidden = NO;
            
            comment.text = [NSString stringWithFormat:@"%.2ld", social.commentsCount];
            
            if(social.isCommented){
                comment.textColor = [UIColor customBlue];
                [comment setImage:[UIImage imageNamed:@"social-comment-selected"]];
            }
            else{
                comment.textColor = [UIColor customPlaceholder];
                [comment setImage:[UIImage imageNamed:@"social-comment"]];
            }
            
            [comment setImageOffset:CGPointMake(-2.5, -1)];
            [comment setWidthToFit];
            
            
            CGRectSetX(comment.frame, x);
            CGRectSetWidth(comment.frame, CGRectGetWidth(comment.frame) + OFFSET);
            x = CGRectGetMaxX(comment.frame);
        }
    }
    
    CGRectSetWidth(self.frame, x);
}

- (void)addTargetForLike:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)didLikeTouch
{
    if(![like.textColor isEqual:[UIColor customBlue]]){
        [UIView animateWithDuration:.1 animations:^{
            like.transform = CGAffineTransformMakeScale(1.2, 1.2);
        } completion:^(BOOL finished) {
            like.textColor = [UIColor customBlue];
            [like setImage:[UIImage imageNamed:@"social-like-selected"]];
            [UIView animateWithDuration:.1 animations:^{
                like.transform = CGAffineTransformIdentity;
            }];
        }];
    }
    
    [_target performSelector:_action withObject:nil];
}

@end
