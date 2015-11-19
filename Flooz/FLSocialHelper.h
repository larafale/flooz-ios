//
//  FLSocialHelper.h
//  Flooz
//
//  Created by Epitech on 9/22/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "FLActionButton.h"
#import "FLBorderedActionButton.h"

@interface FLSocialHelper : NSObject

// UNFRIEND / UNFOLLOW

+ (FLActionButton *) createMiniUnfriendButton:(id)target action:(SEL)action;
+ (FLActionButton *) createMiniUnfriendButton:(id)target action:(SEL)action size:(CGSize)size;
+ (FLActionButton *) createMiniUnfriendButton:(id)target action:(SEL)action frame:(CGRect)frame;
+ (FLActionButton *) createMiniUnfriendButton:(id)target action:(SEL)action position:(CGPoint)position;

+ (FLActionButton *) createFullUnfriendButton:(id)target action:(SEL)action;
+ (FLActionButton *) createFullUnfriendButton:(id)target action:(SEL)action size:(CGSize)size;
+ (FLActionButton *) createFullUnfriendButton:(id)target action:(SEL)action position:(CGPoint)position;
+ (FLActionButton *) createFullUnfriendButton:(id)target action:(SEL)action frame:(CGRect)frame;

+ (FLActionButton *) createFullUnfollowButton:(id)target action:(SEL)action;
+ (FLActionButton *) createFullUnfollowButton:(id)target action:(SEL)action size:(CGSize)size;
+ (FLActionButton *) createFullUnfollowButton:(id)target action:(SEL)action position:(CGPoint)position;
+ (FLActionButton *) createFullUnfollowButton:(id)target action:(SEL)action frame:(CGRect)frame;

+ (FLActionButton *) createRequestPendingButton:(id)target action:(SEL)action;
+ (FLActionButton *) createRequestPendingButton:(id)target action:(SEL)action size:(CGSize)size;
+ (FLActionButton *) createRequestPendingButton:(id)target action:(SEL)action position:(CGPoint)position;
+ (FLActionButton *) createRequestPendingButton:(id)target action:(SEL)action frame:(CGRect)frame;

+ (FLActionButton *) generateFullUnfriendButton:(FLActionButton*)button text:(NSString *)text;

// FRIEND / FOLLOW

+ (FLBorderedActionButton *) createMiniFriendButton:(id)target action:(SEL)action;
+ (FLBorderedActionButton *) createMiniFriendButton:(id)target action:(SEL)action size:(CGSize)size;
+ (FLBorderedActionButton *) createMiniFriendButton:(id)target action:(SEL)action frame:(CGRect)frame;
+ (FLBorderedActionButton *) createMiniFriendButton:(id)target action:(SEL)action position:(CGPoint)position;

+ (FLBorderedActionButton *) createFullFriendButton:(id)target action:(SEL)action;
+ (FLBorderedActionButton *) createFullFriendButton:(id)target action:(SEL)action size:(CGSize)size;
+ (FLBorderedActionButton *) createFullFriendButton:(id)target action:(SEL)action position:(CGPoint)position;
+ (FLBorderedActionButton *) createFullFriendButton:(id)target action:(SEL)action frame:(CGRect)frame;

+ (FLBorderedActionButton *) createFullFollowButton:(id)target action:(SEL)action;
+ (FLBorderedActionButton *) createFullFollowButton:(id)target action:(SEL)action size:(CGSize)size;
+ (FLBorderedActionButton *) createFullFollowButton:(id)target action:(SEL)action position:(CGPoint)position;
+ (FLBorderedActionButton *) createFullFollowButton:(id)target action:(SEL)action frame:(CGRect)frame;

+ (FLBorderedActionButton *) createFriendRequestButton:(id)target action:(SEL)action;
+ (FLBorderedActionButton *) createFriendRequestButton:(id)target action:(SEL)action size:(CGSize)size;
+ (FLBorderedActionButton *) createFriendRequestButton:(id)target action:(SEL)action position:(CGPoint)position;
+ (FLBorderedActionButton *) createFriendRequestButton:(id)target action:(SEL)action frame:(CGRect)frame;

+ (FLBorderedActionButton *) generateFullFriendButton:(FLBorderedActionButton*)button  text:(NSString *)text;

@end
