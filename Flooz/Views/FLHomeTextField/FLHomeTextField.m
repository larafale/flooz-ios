//
//  FLHomeTextField.m
//  Flooz
//
//  Created by Jonathan on 22/07/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLHomeTextField.h"

@implementation FLHomeTextField

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, SCREEN_WIDTH - 2 * position.x, 42)];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        
        [self createTextField:placeholder];
        [self createBottomBar];
    }
    return self;
}

- (void)createTextField:(NSString *)placeholder
{
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(7, 0, CGRectGetWidth(self.frame) - 14, CGRectGetHeight(self.frame))];
    
    _textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield.returnKeyType = UIReturnKeyNext;
    
    _textfield.delegate = self;
    
    _textfield.font = [UIFont customTitleThin:40];
    _textfield.textAlignment = NSTextAlignmentCenter;
    _textfield.textColor = [UIColor whiteColor];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(placeholder, nil)
                                          attributes:@{
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];
    
    _textfield.attributedPlaceholder = attributedText;
    
    [_textfield addTarget:self action:@selector(checkValueForCallAction) forControlEvents:UIControlEventEditingChanged];
    
    [self addSubview:_textfield];
}

- (void)createBottomBar
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) + 5, CGRectGetWidth(self.frame), 1)];
    bottomBar.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:bottomBar];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([string isEqualToString:@"\r"] && textField.text.length > 0){
        return YES;
    }
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    if([_textfield.text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound && newLength > 8){
        return NO;
    }
    
    return (newLength > 10) ? NO : YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if([textField.text isBlank]){
        [_dictionary setValue:nil forKey:_dictionaryKey];
    }else{
        [_dictionary setValue:textField.text forKey:_dictionaryKey];
    }
    [textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [_textfield becomeFirstResponder];
}

- (void)addForNextClickTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)checkValueForCallAction
{
    if(_textfield.text.length >= 10){
        SEL selector = _action;
        ((void (*)(id, SEL))[_target methodForSelector:selector])(_target, selector);
    }
    else if([_textfield.text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound && _textfield.text.length >= 8){
        SEL selector = _action;
        ((void (*)(id, SEL))[_target methodForSelector:selector])(_target, selector);
    }
    
}

@end
