//
//  FLTextFieldIcon.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLTextFieldIcon.h"

#define MARGE_MIDDLE_BAR 10

@implementation FLTextFieldIcon

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position
{
    return [self initWithIcon:iconName placeholder:placeholder for:dictionary key:dictionaryKey frame:CGRectMakeWithPosition(position) placeholder2:nil key2:nil];
}

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame
{
    return [self initWithIcon:iconName placeholder:placeholder for:dictionary key:dictionaryKey frame:frame placeholder2:nil key2:nil];
}

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2
{
    return [self initWithIcon:iconName placeholder:placeholder for:dictionary key:dictionaryKey frame:CGRectMakeWithPosition(position) placeholder2:placeholder2 key2:dictionaryKey2];
}

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2
{
    if(frame.size.width == 0){
        CGRectSetWidth(frame, SCREEN_WIDTH - (2 * frame.origin.x));
    }
    CGRectSetHeight(frame, 37);
    
    self = [super initWithFrame:frame];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        _dictionaryKey2 = dictionaryKey2;
        
        [self createIcon:iconName];
        [self createTextField:placeholder];
        [self createTextField2:placeholder2];
        [self createBottomBar];
        
        _textfield.text = [_dictionary objectForKey:_dictionaryKey];
        _textfield2.text = [_dictionary objectForKey:_dictionaryKey2];
    }
    return self;
}

- (void)createIcon:(NSString *)iconName
{
    icon = [UIImageView imageNamed:iconName];
    CGRectSetXY(icon.frame, 6, 17);
    
    [self addSubview:icon];
}

- (void)createTextField:(NSString *)placeholder
{
    BOOL haveOneTextField = (_dictionaryKey2 == nil ? YES : NO);
    CGFloat width = CGRectGetWidth(self.frame) - CGRectGetMaxX(icon.frame) - 18;
    if(!haveOneTextField){
        width = (width / 2.) - MARGE_MIDDLE_BAR;
    }
    
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 18, 8, width, 30)];
    
    _textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield.returnKeyType = UIReturnKeyNext;
    
    _textfield.delegate = self;
    
    if([_dictionaryKey isEqualToString:@"phone"]){
        _textfield.keyboardType = UIKeyboardTypeNumberPad;
        [_textfield addTarget:self action:@selector(checkPhoneValue) forControlEvents:UIControlEventEditingChanged];
    }
    
    _textfield.font = [UIFont customContentLight:12];
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

- (void)createTextField2:(NSString *)placeholder
{
    BOOL haveOneTextField = (_dictionaryKey2 == nil ? YES : NO);
    if(haveOneTextField){
        return;
    }
    
    {
        UIView *middleBar = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_textfield.frame) + MARGE_MIDDLE_BAR, 10, 1, CGRectGetHeight(self.frame) - 10)];
        middleBar.backgroundColor = [UIColor customSeparator];
        
        [self addSubview:middleBar];
    }
    
    
    CGFloat width = ((CGRectGetWidth(self.frame) - CGRectGetMaxX(icon.frame) - 18) / 2.) - MARGE_MIDDLE_BAR;
    
    _textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_textfield.frame) + MARGE_MIDDLE_BAR + MARGE_MIDDLE_BAR, 8, width, 30)];
    
    _textfield2.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield2.returnKeyType = UIReturnKeyNext;
    
    _textfield2.delegate = self;
    
    _textfield2.font = [UIFont customContentLight:12];
    _textfield2.textColor = [UIColor whiteColor];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(placeholder, nil)
                                          attributes:@{
                                                       NSFontAttributeName: [UIFont customContentLight:14],
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];
    
    _textfield2.attributedPlaceholder = attributedText;
    
    [self addSubview:_textfield2];
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
    
    if(_textfield2){
        if(textField == _textfield2){
            [_target performSelector:_action];
        }
        else{
            [_textfield2 becomeFirstResponder];
        }
    }
    else{
        [_target performSelector:_action];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *currentDictionaryKey;
    if(textField == _textfield){
        currentDictionaryKey = _dictionaryKey;
    }
    else{
        currentDictionaryKey = _dictionaryKey2;
    }
    
    if([textField.text isBlank]){
        [_dictionary setValue:nil forKey:currentDictionaryKey];
    }else{
        [_dictionary setValue:textField.text forKey:currentDictionaryKey];
    }
    
    [textField resignFirstResponder];
 }

- (void)seTsecureTextEntry:(BOOL)secureTextEntry
{
    _textfield.secureTextEntry = secureTextEntry;
}

#pragma mark -

- (BOOL)becomeFirstResponder
{
    return [_textfield becomeFirstResponder];
}

- (void)addForNextClickTarget:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

- (void)checkPhoneValue
{
    if([_textfield.text length] == 10){
        [_textfield resignFirstResponder];
        [_target performSelector:_action];
    }
}

@end
