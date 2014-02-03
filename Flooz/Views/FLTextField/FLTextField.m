//
//  FLTextField.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLTextField.h"

@implementation FLTextField

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, SCREEN_WIDTH - position.x, 39)];
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
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, CGRectGetWidth(self.frame) - 14, CGRectGetHeight(self.frame))];
    
    _textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield.returnKeyType = UIReturnKeyNext;
    
    _textfield.delegate = self;
    
    _textfield.font = [UIFont customContentLight:14];
    _textfield.textColor = [UIColor whiteColor];
        
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(placeholder, nil)
                                          attributes:@{
                                                       NSFontAttributeName: [UIFont customContentLight:14],
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];
    
    _textfield.attributedPlaceholder = attributedText;
    
    [self addSubview:_textfield];
}

- (void)createBottomBar
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    bottomBar.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:bottomBar];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

@end