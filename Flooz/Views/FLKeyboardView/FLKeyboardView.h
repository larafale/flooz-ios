//
//  FLKeyboardView.h
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLKeyboardViewDelegate.h"

@interface FLKeyboardView : UIView{
    UIButton *closeButton;
}

@property (weak, nonatomic) UITextField *textField;
@property (weak, nonatomic) id<FLKeyboardViewDelegate> delegate;

- (void)setKeyboardChangeable;

@end
