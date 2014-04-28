//
//  FLSocialView.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLSocialView.h"

@implementation FLSocialView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 15);
    self = [super initWithFrame:frame];
    if (self) {
        _gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didLikeTouch)];
        [self createView];
    }
    return self;
}

- (void)createView
{
    comment = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(self.frame))];
    like = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(self.frame))];
    separator = [[UIView alloc] initWithFrame:CGRectMakeSize(1, CGRectGetHeight(self.frame))];
    scope = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 13, 10)];
    
    comment.font = [UIFont customContentRegular:11];
    like.font = [UIFont customContentRegular:11];
    
    separator.backgroundColor = [UIColor customSeparator];
    
    like.userInteractionEnabled = YES;
    [like addGestureRecognizer:_gesture];
    
    
    [self addSubview:comment];
    [self addSubview:like];
//    [self addSubview:separator];
    [self addSubview:scope];
}

- (void)prepareView:(FLSocial *)social
{
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
        
        CGRectSetWidth(like.frame, CGRectGetWidth(like.frame) + 18);
    }
    
    {
        if(social.commentsCount == 0){
            comment.hidden = YES;
            
            CGRectSetWidth(comment.frame, 0);
            CGRectSetX(comment.frame, CGRectGetMaxX(like.frame));
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
            
            CGRectSetWidth(comment.frame, CGRectGetWidth(comment.frame) + 18);
            CGRectSetX(comment.frame, CGRectGetMaxX(like.frame) + 5);
        }
    }
    
    {
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
        
        CGRectSetX(scope.frame, CGRectGetMaxX(comment.frame) + 7);
    }
    
    CGRectSetWidth(self.frame, CGRectGetMaxX(scope.frame));
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
