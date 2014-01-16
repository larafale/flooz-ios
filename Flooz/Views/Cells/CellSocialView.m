//
//  CellSocialView.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "CellSocialView.h"

@implementation CellSocialView

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

- (void)prepareView
{
    comment = [[self subviews] objectAtIndex:0];
    like = [[self subviews] objectAtIndex:1];
    separator = [[self subviews] objectAtIndex:2];
    
    comment.text = NSLocalizedString(@"CELL_SOCIAL_COMMENT", nil);
    comment.textColor = [UIColor customBlueLight];
    [comment setImage:[UIImage imageNamed:@"cell-social-comment"]];
    [comment setImageOffset:CGPointMake(-5, 0)];
    
    [comment setWidth];
    comment.frame = CGRectMakeSetWidth(comment.frame, CGRectGetWidth(comment.frame) + 18);
    
    separator.frame = CGRectMakeSetX(separator.frame, CGRectGetMaxX(comment.frame) + 12);
    
    like.frame = CGRectMakeSetX(like.frame, CGRectGetMaxX(separator.frame) + 12);
    like.text = NSLocalizedString(@"CELL_SOCIAL_LIKE", nil);
    like.textColor = [UIColor customBlueLight];
    [like setImage:[UIImage imageNamed:@"cell-social-like"]];
    [like setImageOffset:CGPointMake(-5, 0)];
    
    [like setWidth];
    like.frame = CGRectMakeSetWidth(like.frame, CGRectGetWidth(like.frame) + 18);
}

@end
