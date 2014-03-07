//
//  FLTextFieldTitle2.m
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLTextFieldTitle2.h"

@implementation FLTextFieldTitle2

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, SCREEN_WIDTH - (2 * position.x), 48)];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        
        [self createTitle:title];
        [self createTextField:placeholder];
        [self createBottomBar];
        
        _textfield.text = [_dictionary objectForKey:_dictionaryKey];
        
        _maxLength = 50;
    }
    return self;
}

- (void)reloadData
{
    _textfield.text = [_dictionary objectForKey:_dictionaryKey];
}

- (void)createTitle:(NSString *)title
{
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 21)];
    
    _title.textColor = [UIColor customBlueLight];
    _title.text = NSLocalizedString(title, nil);
    _title.font = [UIFont customContentRegular:12];
    
    [_title setWidthToFit];
    
    [self addSubview:_title];
}

- (void)createTextField:(NSString *)placeholder
{
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_title.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(_title.frame))];
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > _maxLength) ? NO : YES;
}

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

- (BOOL)becomeFirstResponder{
    return [_textfield becomeFirstResponder];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType{
    _textfield.keyboardType = keyboardType;
}

@end
