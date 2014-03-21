//
//  FLKeyboardView.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLKeyboardView.h"

#define BUTTON_WIDTH (SCREEN_WIDTH / 3.)
#define BUTTON_HEIGHT 62.5

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
    }
    
    {
        UIButton *button = [self createButtonWithPosition:CGPointMake(3, 4) title:@""];
        [button setImage:[UIImage imageNamed:@"keyboard-backward"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(didButtonReturnTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (UIButton *)createButtonWithPosition:(CGPoint)position title:(NSString *)title
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((position.x - 1) * BUTTON_WIDTH, (position.y - 1) * BUTTON_HEIGHT, BUTTON_WIDTH, BUTTON_HEIGHT)];
    
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundHeader]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor customBackground]] forState:UIControlStateHighlighted];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    button.titleLabel.font = [UIFont customTitleThin:40];
    
    button.layer.borderWidth = .5;
    button.layer.borderColor = [UIColor customSeparator].CGColor;
    
    [self addSubview:button];
    
    return button;
}

- (void)didButtonTouch:(UIButton *)sender
{
    [_delegate keyboardPress:sender.titleLabel.text];
    
    NSInteger startOffset = [_textField offsetFromPosition:_textField.beginningOfDocument toPosition:_textField.selectedTextRange.start];
    NSInteger endOffset = [_textField offsetFromPosition:_textField.beginningOfDocument toPosition:_textField.selectedTextRange.end];
    
    NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
    
    if([[_textField delegate] textField:_textField shouldChangeCharactersInRange:offsetRange replacementString:sender.titleLabel.text]){
        [_textField insertText:sender.titleLabel.text];
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
    
    if([[_textField delegate] textField:_textField shouldChangeCharactersInRange:offsetRange replacementString:@"\r"]){
        [_textField deleteBackward];
    }
}


@end
