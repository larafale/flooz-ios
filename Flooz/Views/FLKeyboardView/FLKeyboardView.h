//
//  FLKeyboardView.h
//  Flooz
//
//  Created by olivier on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLKeyboardViewDelegate.h"

typedef enum {
	CloseButtonTypeClose,
	CloseButtonTypeValidate,
	CloseButtonTypeABC,
	CloseButtonTypeBackward,
	CloseButtonTypeDecimal,
	CloseButtonTypeNone
}CloseButtonType;

@interface FLKeyboardView : UIView {
	UIButton *closeButton;
	UIButton *bottomRightButton;
	CloseButtonType closeButtonState;

	__weak id _target;
	SEL _action;
}

@property (weak, nonatomic) UITextField *textField;
@property (weak, nonatomic) id <FLKeyboardViewDelegate> delegate;

- (void)setKeyboardChangeable;
- (FLKeyboardView *)setKeyboardValidateWithTarget:(id)target action:(SEL)action;
- (void)setCloseButton;
- (FLKeyboardView *)setKeyboardPhoneLoginWithTarget:(id)target action:(SEL)action;
- (void)enableValidateButton:(BOOL)enable;
- (void)setKeyboardDecimal;
- (void)noneCloseButton;

@end
