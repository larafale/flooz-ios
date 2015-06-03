//
//  FLSwitchView.h
//  Flooz
//
//  Created by olivier on 2014-04-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLSwitchViewDelegate.h"
#import "FLSwitch.h"

@interface FLSwitchView : UIView {
	FLSwitch *switchView;
	BOOL alternativeStyle;
}

@property (strong, nonatomic) UILabel *title;

@property (weak) id <FLSwitchViewDelegate> delegate;

+ (CGFloat)height;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;
- (void)setAlternativeStyle;
- (void)setOn:(BOOL)on;

@end
