//
//  FLSocialView.h
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLSocialView : UIView{
    JTImageLabel *comment;
    JTImageLabel *like;
    UIImageView *scope;
    UIView *separator;
    
    __weak id _target;
    SEL _action;
}

@property (strong, nonatomic) UITapGestureRecognizer *gesture;

- (void)prepareView:(FLSocial *)social;
- (void)addTargetForLike:(id)target action:(SEL)action;

@end
