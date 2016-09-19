//
//  FLSocialHelper.m
//  Flooz
//
//  Created by Epitech on 9/22/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FLSocialHelper.h"

#define actionButtonMargin 10
#define actionButtonHeight 30

@implementation FLSocialHelper

+ (FLBorderedActionButton *) createMiniFloozButton:(id)target action:(SEL)action {
    return [[self class] createMiniFloozButton:target action:action frame:CGRectMake(0, 0, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createMiniFloozButton:(id)target action:(SEL)action size:(CGSize)size {
    return [[self class] createMiniFloozButton:target action:action frame:CGRectMake(0, 0, size.width, size.height)];
}

+ (FLBorderedActionButton *) createMiniFloozButton:(id)target action:(SEL)action position:(CGPoint)position {
    return [[self class] createMiniFloozButton:target action:action frame:CGRectMake(position.x, position.y, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createMiniFloozButton:(id)target action:(SEL)action frame:(CGRect)frame {
    FLBorderedActionButton *button;
    
    button = [[FLBorderedActionButton alloc] initWithFrame:frame];
    button.layer.cornerRadius = 5;
    [button setImage:[UIImage imageNamed:@"flooz-mini"] size:CGSizeMake(CGRectGetHeight(frame) - actionButtonMargin, CGRectGetHeight(frame) - actionButtonMargin)];
    [button centerImage];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (FLActionButton *) createMiniUnfriendButton:(id)target action:(SEL)action  {
    return [[self class] createMiniUnfriendButton:target action:action frame:CGRectMake(0, 0, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLActionButton *) createMiniUnfriendButton:(id)target action:(SEL)action size:(CGSize)size  {
    return [[self class] createMiniUnfriendButton:target action:action frame:CGRectMake(0, 0, size.width, size.height)];
}

+ (FLActionButton *) createMiniUnfriendButton:(id)target action:(SEL)action position:(CGPoint)position  {
    return [[self class] createMiniUnfriendButton:target action:action frame:CGRectMake(position.x, position.y, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLActionButton *) createMiniUnfriendButton:(id)target action:(SEL)action frame:(CGRect)frame  {
    FLActionButton *button;
    
    button = [[FLActionButton alloc] initWithFrame:frame];
    button.layer.cornerRadius = 5;
    [button setImage:[UIImage imageNamed:@"unfollow"] size:CGSizeMake(CGRectGetHeight(frame) - actionButtonMargin, CGRectGetHeight(frame) - actionButtonMargin)];
    [button centerImage];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];

    return button;
}

+ (FLActionButton *) createFullUnfriendButton:(id)target action:(SEL)action {
    return  [[self class] createFullUnfriendButton:target action:action frame:CGRectMake(0, 0, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLActionButton *) createFullUnfriendButton:(id)target action:(SEL)action size:(CGSize)size {
    return  [[self class] createFullUnfriendButton:target action:action frame:CGRectMake(0, 0, size.width, size.height)];
}

+ (FLActionButton *) createFullUnfriendButton:(id)target action:(SEL)action position:(CGPoint)position {
    return  [[self class] createFullUnfriendButton:target action:action frame:CGRectMake(position.x, position.y, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLActionButton *) createFullUnfriendButton:(id)target action:(SEL)action frame:(CGRect)frame {
    return  [[self class] generateFullUnfriendButton:[[self class] createMiniUnfriendButton:target action:action frame:frame] text:NSLocalizedString(@"FRIENDS", nil)];
}

+ (FLActionButton *) createFullUnfollowButton:(id)target action:(SEL)action {
    return  [[self class] createFullUnfollowButton:target action:action frame:CGRectMake(0, 0, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLActionButton *) createFullUnfollowButton:(id)target action:(SEL)action size:(CGSize)size {
    return  [[self class] createFullUnfollowButton:target action:action frame:CGRectMake(0, 0, size.width, size.height)];
}

+ (FLActionButton *) createFullUnfollowButton:(id)target action:(SEL)action position:(CGPoint)position {
    return  [[self class] createFullUnfollowButton:target action:action frame:CGRectMake(position.x, position.y, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLActionButton *) createFullUnfollowButton:(id)target action:(SEL)action frame:(CGRect)frame  {
    return  [[self class] generateFullUnfriendButton:[[self class] createMiniUnfriendButton:target action:action frame:frame] text:NSLocalizedString(@"FOLLOWED", nil)];
}

+ (FLActionButton *) createRequestPendingButton:(id)target action:(SEL)action {
    return  [[self class] createRequestPendingButton:target action:action frame:CGRectMake(0, 0, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLActionButton *) createRequestPendingButton:(id)target action:(SEL)action size:(CGSize)size {
    return  [[self class] createRequestPendingButton:target action:action frame:CGRectMake(0, 0, size.width, size.height)];
}

+ (FLActionButton *) createRequestPendingButton:(id)target action:(SEL)action position:(CGPoint)position {
    return  [[self class] createRequestPendingButton:target action:action frame:CGRectMake(position.x, position.y, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLActionButton *) createRequestPendingButton:(id)target action:(SEL)action frame:(CGRect)frame  {
    FLActionButton *button;
    
    button = [[FLActionButton alloc] initWithFrame:frame];
    button.layer.cornerRadius = 5;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont customContentBold:14]];
    [button setTitle:NSLocalizedString(@"FRIENDS_PENDING", nil) forState:UIControlStateNormal];
    
    CGFloat textWidth = [button.titleLabel.text widthOfString:button.titleLabel.font];
    CGFloat fullWidth = textWidth + (2 * actionButtonMargin);
    
    CGRectSetWidth(button.frame, fullWidth);
    return button;
}

+ (FLActionButton *) generateFullUnfriendButton:(FLActionButton*)button text:(NSString *)text {
   
    [button.titleLabel setFont:[UIFont customContentBold:15]];
    [button setTitle:text forState:UIControlStateNormal];
    
    CGFloat textWidth = [text widthOfString:button.titleLabel.font];
    CGFloat imgWidth = CGRectGetHeight(button.frame) - actionButtonMargin;
    CGFloat fullWidth = textWidth + imgWidth + (3.5 * actionButtonMargin);
    
    CGRectSetWidth(button.frame, fullWidth);
    [button centerImage:actionButtonMargin / 2];
    return button;
}

+ (FLBorderedActionButton *) createMiniFriendButton:(id)target action:(SEL)action {
    return [[self class] createMiniFriendButton:target action:action frame:CGRectMake(0, 0, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createMiniFriendButton:(id)target action:(SEL)action size:(CGSize)size {
    return [[self class] createMiniFriendButton:target action:action frame:CGRectMake(0, 0, size.width, size.height)];
}

+ (FLBorderedActionButton *) createMiniFriendButton:(id)target action:(SEL)action position:(CGPoint)position {
    return [[self class] createMiniFriendButton:target action:action frame:CGRectMake(position.x, position.y, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createMiniFriendButton:(id)target action:(SEL)action frame:(CGRect)frame {
    FLBorderedActionButton *button;
    
    button = [[FLBorderedActionButton alloc] initWithFrame:frame];
    button.layer.cornerRadius = 5;
    [button setImage:[UIImage imageNamed:@"follow"] size:CGSizeMake(CGRectGetHeight(frame) - actionButtonMargin, CGRectGetHeight(frame) - actionButtonMargin)];
    [button centerImage];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (FLBorderedActionButton *) createFullFriendButton:(id)target action:(SEL)action {
    return [[self class] createFullFriendButton:target action:action frame:CGRectMake(0, 0, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createFullFriendButton:(id)target action:(SEL)action size:(CGSize)size {
    return [[self class] createFullFriendButton:target action:action frame:CGRectMake(0, 0, size.width, size.height)];
}

+ (FLBorderedActionButton *) createFullFriendButton:(id)target action:(SEL)action position:(CGPoint)position {
    return [[self class] createFullFriendButton:target action:action frame:CGRectMake(position.x, position.y, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createFullFriendButton:(id)target action:(SEL)action frame:(CGRect)frame {
    return  [[self class] generateFullFriendButton:[[self class] createMiniFriendButton:target action:action frame:frame] text:NSLocalizedString(@"FRIEND_ADD", nil)];
}

+ (FLBorderedActionButton *) createFullFollowButton:(id)target action:(SEL)action {
    return [[self class] createFullFollowButton:target action:action frame:CGRectMake(0, 0, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createFullFollowButton:(id)target action:(SEL)action size:(CGSize)size {
    return [[self class] createFullFollowButton:target action:action frame:CGRectMake(0, 0, size.width, size.height)];
}

+ (FLBorderedActionButton *) createFullFollowButton:(id)target action:(SEL)action position:(CGPoint)position {
    return [[self class] createFullFollowButton:target action:action frame:CGRectMake(position.x, position.y, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createFullFollowButton:(id)target action:(SEL)action frame:(CGRect)frame {
    return  [[self class] generateFullFriendButton:[[self class] createMiniFriendButton:target action:action frame:frame] text:NSLocalizedString(@"FOLLOW", nil)];
}

+ (FLBorderedActionButton *) createFriendRequestButton:(id)target action:(SEL)action {
    return [[self class] createFriendRequestButton:target action:action frame:CGRectMake(0, 0, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createFriendRequestButton:(id)target action:(SEL)action size:(CGSize)size {
    return [[self class] createFriendRequestButton:target action:action frame:CGRectMake(0, 0, size.width, size.height)];
}

+ (FLBorderedActionButton *) createFriendRequestButton:(id)target action:(SEL)action position:(CGPoint)position {
    return [[self class] createFriendRequestButton:target action:action frame:CGRectMake(position.x, position.y, actionButtonHeight + actionButtonMargin, actionButtonHeight)];
}

+ (FLBorderedActionButton *) createFriendRequestButton:(id)target action:(SEL)action frame:(CGRect)frame {
    FLBorderedActionButton *button;
    
    button = [[FLBorderedActionButton alloc] initWithFrame:frame];
    button.layer.cornerRadius = 5;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont customContentBold:13]];
    [button setTitle:NSLocalizedString(@"FRIENDS_REQUEST", nil) forState:UIControlStateNormal];
    
    CGFloat textWidth = [button.titleLabel.text widthOfString:button.titleLabel.font];
    CGFloat fullWidth = textWidth + (2 * actionButtonMargin);
    
    CGRectSetWidth(button.frame, fullWidth);
    
    return button;
}

+ (FLBorderedActionButton *) generateFullFriendButton:(FLBorderedActionButton*)button  text:(NSString *)text {
    [button.titleLabel setFont:[UIFont customContentBold:15]];
    [button setTitle:text forState:UIControlStateNormal];

    CGFloat textWidth = [text widthOfString:button.titleLabel.font];
    CGFloat imgWidth = CGRectGetHeight(button.frame) - actionButtonMargin;
    CGFloat fullWidth = textWidth + imgWidth + (3.5 * actionButtonMargin);
    
    CGRectSetWidth(button.frame, fullWidth);
    [button centerImage:actionButtonMargin / 2];
    
    return button;
}

@end
