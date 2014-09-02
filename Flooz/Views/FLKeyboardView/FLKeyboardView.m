//
//  FLKeyboardView.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLKeyboardView.h"

#define BUTTON_WIDTH (SCREEN_WIDTH / 3.)
#define BUTTON_HEIGHT 54

@implementation FLKeyboardView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetWidthHeight(frame, SCREEN_WIDTH, (BUTTON_HEIGHT * 4));
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor customBackgroundHeader];
    
    for(int i = 1; i <= 3; ++i){
        for(int j = 1; j <= 3; ++j){
            UIButton *button = [self createButtonWithPosition:CGPointMake(j, i) title:[NSString stringWithFormat:@"%d", j + (3 * (i - 1))]];
            [button addTarget:self action:@selector(didButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    {
        UIButton *button = [self createButtonWithPosition:CGPointMake(2, 4) title:@"0"];
        [button addTarget:self action:@selector(didButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UIButton *button = [self createButtonWithPosition:CGPointMake(1, 4) title:@""];
        [button setImage:[UIImage imageNamed:@"keyboard-close"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didButtonCloseTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        closeButton = button;
        closeButtonState = CloseButtonTypeClose;
    }
    
    {
        UIButton *button = [self createButtonWithPosition:CGPointMake(3, 4) title:@""];
        [button setImage:[UIImage imageNamed:@"keyboard-backward"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didButtonReturnTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        bottomRightButton = button;
    }
}

- (void)setKeyboardChangeable
{
    [closeButton setTitle:@"ABC" forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont customTitleThin:20]];
    [closeButton setImage:nil forState:UIControlStateNormal];
    [closeButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [closeButton addTarget:self action:@selector(didNormalKeyboardTouch) forControlEvents:UIControlEventTouchUpInside];
    closeButtonState = CloseButtonTypeABC;
}

- (FLKeyboardView *)setKeyboardValidateWithTarget:(id)target action:(SEL)action
{
    [closeButton setTitle:NSLocalizedString(@"Send_Button_Mobile", @"") forState:UIControlStateNormal];
    [closeButton.titleLabel setFont: [UIFont customTitleThin:26]];
    [closeButton setImage:nil forState:UIControlStateNormal];
    [closeButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [closeButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    closeButtonState = CloseButtonTypeValidate;
    return self;
}

- (void)setCloseButton {
    [closeButton setTitle:@"" forState:UIControlStateNormal];
    [closeButton setImage:[UIImage imageNamed:@"keyboard-close"] forState:UIControlStateNormal];
    [closeButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [closeButton addTarget:self action:@selector(didButtonCloseTouch:) forControlEvents:UIControlEventTouchUpInside];
    closeButtonState = CloseButtonTypeClose;
}

- (void)setKeyboardDecimal {
    [closeButton setTitle:@"." forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont customTitleThin:100];
    closeButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 70, 0);
    closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [closeButton setImage:nil forState:UIControlStateNormal];
    [closeButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [closeButton addTarget:self action:@selector(didButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    closeButton.backgroundColor = [UIColor customBackgroundHeader];
    [closeButton setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundHeader]] forState:UIControlStateNormal];
    [closeButton setBackgroundImage:[UIImage imageWithColor:[UIColor customBackground]] forState:UIControlStateHighlighted];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    closeButtonState = CloseButtonTypeDecimal;
}

- (void) addDecimal {
    
}

- (FLKeyboardView *)setKeyboardPhoneLoginWithTarget:(id)target action:(SEL)action {
    [bottomRightButton setTitle:NSLocalizedString(@"Send_Button_Mobile", @"") forState:UIControlStateNormal];
    [bottomRightButton.titleLabel setFont: [UIFont customTitleThin:26]];
    [bottomRightButton setImage:nil forState:UIControlStateNormal];
    [bottomRightButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [bottomRightButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [closeButton setImage:[UIImage imageNamed:@"keyboard-backward"] forState:UIControlStateNormal];
    [closeButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [closeButton addTarget:self action:@selector(didButtonReturnTouch:) forControlEvents:UIControlEventTouchUpInside];
    closeButtonState = CloseButtonTypeBackward;
    return self;
}

- (void)enableValidateButton:(BOOL)enable {
    [bottomRightButton setEnabled:enable];
}

- (UIButton *)createButtonWithPosition:(CGPoint)position title:(NSString *)title
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((position.x - 1) * BUTTON_WIDTH, (position.y - 1) * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT)];
    
    button.backgroundColor = [UIColor customBackgroundHeader];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundHeader]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor customBackground]] forState:UIControlStateHighlighted];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    button.titleLabel.font = [UIFont customTitleThin:40];
    
    //    button.layer.borderWidth = .5;
    //    button.layer.borderColor = [UIColor customSeparator].CGColor;
    
    [self addSubview:button];
    
    return button;
}

- (void)didButtonTouch:(UIButton *)sender
{
    [_delegate keyboardPress:sender.titleLabel.text];
    
    NSInteger startOffset = [_textField offsetFromPosition:_textField.beginningOfDocument toPosition:_textField.selectedTextRange.start];
    NSInteger endOffset = [_textField offsetFromPosition:_textField.beginningOfDocument toPosition:_textField.selectedTextRange.end];
    
    NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
    
    
    if(
       ([_textField delegate] &&
        [[_textField delegate] respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] &&
        [[_textField delegate] textField:_textField shouldChangeCharactersInRange:offsetRange replacementString:sender.titleLabel.text]) ||
       [_textField delegate] == nil ||
       ![[_textField delegate] respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]
       ){
        [_textField insertText:sender.titleLabel.text];
         if ([_textField.text length] < 10 && closeButtonState == CloseButtonTypeValidate) {
            [self setCloseButton];
        }
    }
}

- (void)didButtonCloseTouch:(UIButton *)sender
{
    [_textField resignFirstResponder];
}

- (void)didButtonReturnTouch:(UIButton *)sender
{
    [_delegate keyboardBackwardTouch];
    
    NSInteger startOffset = [_textField offsetFromPosition:_textField.beginningOfDocument toPosition:_textField.selectedTextRange.start];
    NSInteger endOffset = [_textField offsetFromPosition:_textField.beginningOfDocument toPosition:_textField.selectedTextRange.end];
    
    NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
    
    if(
       ([_textField delegate] &&
        [[_textField delegate] respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] &&
        [[_textField delegate] textField:_textField shouldChangeCharactersInRange:offsetRange replacementString:@"\r"]) ||
       [_textField delegate] == nil ||
       ![[_textField delegate] respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]
       ){
        [_textField deleteBackward];
        if ([_textField.text length] < 10 && closeButtonState == CloseButtonTypeValidate) {
            [self setCloseButton];
        }
    }
}

- (void)didNormalKeyboardTouch
{
    _textField.inputView = nil;
    [_textField resignFirstResponder];
    [_textField becomeFirstResponder];
    _textField.inputView = self;
}

@end
