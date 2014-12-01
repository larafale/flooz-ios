//
//  FLSocialView.h
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLSocialView : UIView {
	JTImageLabel *likeText;
	UILabel *like;
	UILabel *comment;
	JTImageLabel *commentText;

	__weak id _target;
	SEL _action;

	__weak id _target2;
	SEL _action2;
}

@property (strong, nonatomic) UITapGestureRecognizer *gesture;

+ (CGFloat)getHeight:(FLSocial *)social;

- (void)prepareView:(FLSocial *)social;
- (void)addTargetForLike:(id)target action:(SEL)action;
- (void)addTargetForComment:(id)target action:(SEL)action;

@end
