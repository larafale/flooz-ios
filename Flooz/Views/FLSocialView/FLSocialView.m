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
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
    }
    return self;
}

- (void)createView
{
    comment = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(self.frame))];
    like = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(self.frame))];
    separator = [[UIView alloc] initWithFrame:CGRectMakeSize(1, CGRectGetHeight(self.frame))];
    
    comment.font = [UIFont customContentRegular:11];
    like.font = [UIFont customContentRegular:11];

    separator.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:comment];
    [self addSubview:like];
    [self addSubview:separator];
}

- (void)prepareView:(FLSocial *)social
{
    {
        if(social.commentsCount == 0){
            comment.text = NSLocalizedString(@"CELL_SOCIAL_COMMENT", nil);
        }
        else{
            comment.text = [NSString stringWithFormat:@"%.2ld", social.commentsCount];
        }
        
        if(social.isCommented){
            comment.textColor = [UIColor whiteColor];
            [comment setImage:[UIImage imageNamed:@"social-comment-selected"]];
        }
        else{
            comment.textColor = [UIColor customBlueLight];
            [comment setImage:[UIImage imageNamed:@"social-comment"]];
        }
        
        [comment setImageOffset:CGPointMake(-5, 0)];
        
        [comment setWidthToFit];
        comment.frame = CGRectSetWidth(comment.frame, CGRectGetWidth(comment.frame) + 18);
    }

    separator.frame = CGRectSetX(separator.frame, CGRectGetMaxX(comment.frame) + 12);
    
    {
        if(social.likesCount == 0){
            like.text = NSLocalizedString(@"CELL_SOCIAL_LIKE", nil);
        }
        else{
            like.text = [NSString stringWithFormat:@"%.2ld", social.likesCount];
            if(![social.likeText isBlank]){
                like.text = [like.text stringByAppendingFormat:@" - %@", social.likeText];
            }
        }
        
        if(social.isLiked){
            like.textColor = [UIColor whiteColor];
            [like setImage:[UIImage imageNamed:@"social-like-selected"]];
        }
        else{
            like.textColor = [UIColor customBlueLight];
            [like setImage:[UIImage imageNamed:@"social-like"]];
        }
        
        like.frame = CGRectSetX(like.frame, CGRectGetMaxX(separator.frame) + 12);
        [like setImageOffset:CGPointMake(-5, 0)];
        
        [like setWidthToFit];
        like.frame = CGRectSetWidth(like.frame, CGRectGetWidth(like.frame) + 18);
    }
}

@end
