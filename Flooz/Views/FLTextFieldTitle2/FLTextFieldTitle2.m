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
        
        _style = FLTextFieldTitle2StyleNormal;
        [self createTitle:title];
        [self createTextField:placeholder];
        [self createBottomBar];
        
        _textfield.text = [_dictionary objectForKey:_dictionaryKey];
    }
    return self;
}

- (void)reloadData
{
    [self setTextFieldValueForStyle];
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
    
    [_textfield addTarget:self action:@selector(setDictionaryValueForStyle) forControlEvents:UIControlEventEditingChanged];
    
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
    // Si backward
    if((!string || [string isBlank]) && range.length == 1){
        return YES;
    }
    
    NSUInteger length = [_textfield.text length];
    
    if(_style == FLTextFieldTitle2StyleCardNumber && length >= 19){
        return NO;
    }
    else if(_style == FLTextFieldTitle2StyleCardExpire && length >= 5){
        return NO;
    }
    else if(_style == FLTextFieldTitle2StyleCVV && length >= 3){
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [_target performSelector:_action];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setDictionaryValueForStyle];
    [textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [_textfield becomeFirstResponder];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType{
    _textfield.keyboardType = keyboardType;
}

- (void)seTsecureTextEntry:(BOOL)secureTextEntry
{
    _textfield.secureTextEntry = secureTextEntry;
}

#pragma mark -

- (void)addForNextClickTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)setDictionaryValueForStyle
{
    if([_textfield.text isBlank]){
        [_dictionary setValue:nil forKey:_dictionaryKey];
    }
    else if(_style == FLTextFieldTitle2StyleCardNumber){
        [_dictionary setValue:[_textfield.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:_dictionaryKey];
    }
    else{
        [_dictionary setValue:_textfield.text forKey:_dictionaryKey];
    }
    
    [self setTextFieldValueForStyle];
    
    if([_textfield isFirstResponder]){
        if(_style == FLTextFieldTitle2StyleCardNumber && [[_dictionary objectForKey:_dictionaryKey] length] == 16){
            [_textfield resignFirstResponder];
            [_target performSelector:_action];
        }
        else if(_style == FLTextFieldTitle2StyleCardExpire && [[_dictionary objectForKey:_dictionaryKey] length] == 5){
            [_textfield resignFirstResponder];
            [_target performSelector:_action];
        }
        else if(_style == FLTextFieldTitle2StyleCVV && [[_dictionary objectForKey:_dictionaryKey] length] == 3){
            [_textfield resignFirstResponder];
            [_target performSelector:_action];
        }
    }
}

- (void)setTextFieldValueForStyle
{
    NSString *text = @"";
    
    if(_style == FLTextFieldTitle2StyleCardNumber){
        for(int i = 0; i < [[_dictionary objectForKey:_dictionaryKey] length]; ++i){
            text = [text stringByAppendingString:[[_dictionary objectForKey:_dictionaryKey] substringWithRange:NSMakeRange(i, 1)]];
            
            if(i % 4 == 3 && i != [[_dictionary objectForKey:_dictionaryKey] length] - 1){
                text = [text stringByAppendingString:@" "];
            }
        }
    }
    else if(_style == FLTextFieldTitle2StyleCardExpire){
        for(int i = 0; i < [[_dictionary objectForKey:_dictionaryKey] length]; ++i){
            text = [text stringByAppendingString:[[_dictionary objectForKey:_dictionaryKey] substringWithRange:NSMakeRange(i, 1)]];
            
            if(i == 1
               &&
               i != [[_dictionary objectForKey:_dictionaryKey] length] - 1
               &&
               (
               ([[_dictionary objectForKey:_dictionaryKey] length] == 2)
               ||
               
               ([[_dictionary objectForKey:_dictionaryKey] length] > 2 && ![[[_dictionary objectForKey:_dictionaryKey] substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"-"])
               )
               )
            {
                text = [text stringByAppendingString:@"-"];
            }
        }
    }
    else{
        text = [_dictionary objectForKey:_dictionaryKey];
    }

    _textfield.text = text;
}

@end