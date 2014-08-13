//
//  FLKeyboardView.h
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLKeyboardViewDelegate.h"

typedef enum
{
    CloseButtonTypeClose,
    CloseButtonTypeValidate,
    CloseButtonTypeABC
}CloseButtonType;

@interface FLKeyboardView : UIView{
    UIButton *closeButton;
    CloseButtonType closeButtonState;
    
    __weak id _target;
    SEL _action;
}

@property (weak, nonatomic) UITextField *textField;
@property (weak, nonatomic) id<FLKeyboardViewDelegate> delegate;

- (void)setKeyboardChangeable;
- (void)setKeyboardValidateWithTarget:(id)target action:(SEL)action;
- (void)setCloseButton;

@end
