//
//  FLSocialView.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLSocialView.h"

#define LINE_HEIGHT 15.
#define OFFSET 5

@implementation FLSocialView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 15);
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    return self;
}

+ (CGFloat)getHeight:(FLSocial *)social
{
    if(!social.likeText || [social.likeText isBlank]){
        return LINE_HEIGHT;
    }
    else{
        return (2 * LINE_HEIGHT) + OFFSET;
    }
}

- (void)createView
{
    {
        likeText = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame), LINE_HEIGHT)];
        [likeText setImage:[UIImage imageNamed:@"social-like"]];
        [likeText setImageOffset:CGPointMake(-2.5, -1)];
        
        [self addSubview:likeText];
    }
    
    {
        like = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(0, LINE_HEIGHT)];
        like.text = NSLocalizedString(@"CELL_SOCIAL_LIKE", nil);
        
        like.textAlignment = NSTextAlignmentCenter;
//        like.layer.borderColor = [UIColor customPlaceholder:.3].CGColor;
//        like.layer.cornerRadius = 3;
//        like.layer.borderWidth = 1.;
        
        [self addSubview:like];
    }
    
    {
        comment = [[JTImageLabel alloc] initWithFrame:CGRectMake(0, 0, 0, LINE_HEIGHT)];
        comment.text = NSLocalizedString(@"CELL_SOCIAL_COMMENT", nil);
        
        comment.textAlignment = NSTextAlignmentCenter;
//        comment.layer.borderColor = [UIColor customPlaceholder:.3].CGColor;
//        comment.layer.cornerRadius = 3;
//        comment.layer.borderWidth = 1.;
        
        [self addSubview:comment];
    }
    
    {
        commentText = [[JTImageLabel alloc] initWithFrame:CGRectMake(0, 0, 0, LINE_HEIGHT)];
        [commentText setImage:[UIImage imageNamed:@"social-comment"]];
        [commentText setImageOffset:CGPointMake(-2.5, -1)];
        
        [self addSubview:commentText];
    }
    
    
    {
        likeText.font = like.font = comment.font = [UIFont customContentRegular:11];
        commentText.font = [UIFont customContentRegular:13];
        
        likeText.textColor = like.textColor = commentText.textColor = comment.textColor = [UIColor customPlaceholder];
    }
    
    {
        like.userInteractionEnabled = YES;
        _gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didLikeTouch)];
        [like addGestureRecognizer:_gesture];
    }
    
    // Mise a jour de la largeur apres avoir mit la police
    
    CGRectSetWidth(like.frame, [like widthToFit] + 5);
    CGRectSetWidth(comment.frame, [comment widthToFit] + 5);
    
    CGRectSetX(comment.frame, CGRectGetMaxX(like.frame) + 10);
    CGRectSetX(commentText.frame, CGRectGetMaxX(comment.frame) + 10);
}

- (void)prepareView:(FLSocial *)social
{
    CGFloat y = 0;
    
    if(!social.likeText || [social.likeText isBlank]){
        likeText.hidden = YES;
    }
    else{
        likeText.hidden = NO;
        likeText.text = social.likeText;
        y = LINE_HEIGHT + OFFSET;
        
        CGRectSetWidth(likeText.frame, [likeText widthToFit] + 20);
    }
    
    CGRectSetY(like.frame, y);
    CGRectSetY(comment.frame, y);
    CGRectSetY(commentText.frame, y);
    
    if(social.commentsCount == 0){
        commentText.hidden = YES;
    }
    else{
        commentText.hidden = NO;
        commentText.text = [NSString stringWithFormat:@"%ld", (unsigned long)social.commentsCount];
        
        CGRectSetWidth(commentText.frame, [commentText widthToFit] + 20);
    }
    
    CGRectSetHeight(self.frame, CGRectGetMaxY(like.frame));
    
    
    if(social.isLiked){
        like.textColor = [UIColor customBlue];
    }
    else{
        like.textColor = [UIColor customPlaceholder];
    }
}

- (void)addTargetForLike:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)didLikeTouch
{
    UIColor *newColor = nil;
    
    if([like.textColor isEqual:[UIColor customBlue]]){
        newColor = [UIColor customPlaceholder];
    }
    else{
        newColor = [UIColor customBlue];
    }
    
    [UIView animateWithDuration:.1 animations:^{
        like.transform = CGAffineTransformMakeScale(1.2, 1.2);
    } completion:^(BOOL finished) {
        like.textColor = newColor;
        [UIView animateWithDuration:.1 animations:^{
            like.transform = CGAffineTransformIdentity;
        }];
    }];
    
    [_target performSelector:_action];
}

@end
