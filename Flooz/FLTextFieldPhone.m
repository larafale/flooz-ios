//
//  FLTextFieldPhone.m
//  Flooz
//
//  Created by Olivier on 2/16/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import "FLTextFieldPhone.h"

#define MARGE_MIDDLE_BAR 10
#define MARGE_LEFT 10
#define MARGE_RIGHT 10

@implementation FLTextFieldPhone {
    NSString *_prefixPhone;
}

@synthesize bottomBar;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey countryKey:(NSString *)dictionaryKeyCountry position:(CGPoint)position {
    return [self initWithPlaceholder:placeholder for:dictionary key:dictionaryKey countryKey:dictionaryKeyCountry frame:CGRectMakeWithPosition(position)];
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey  countryKey:(NSString *)dictionaryKeyCountry frame:(CGRect)frame {
    if (frame.size.width == 0) {
        CGRectSetWidth(frame, PPScreenWidth() - (2 * frame.origin.x));
    }
    CGRectSetHeight(frame, 40);
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        _dictionaryKeyCountry = dictionaryKeyCountry;
        
        [self createCountryZone];
        [self createTextField:placeholder];
        [self createBottomBar];
        
        _readOnly = NO;
        
        _textfield.text = [_dictionary objectForKey:_dictionaryKey];
        
        [_textfield addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)createCountryZone {
    
}

- (void)createTextField:(NSString *)placeholder {
    CGFloat width = CGRectGetWidth(self.frame) - MARGE_LEFT - MARGE_RIGHT;
    
    width = (width / 2.) - MARGE_MIDDLE_BAR;
    
    
    if ([_dictionaryKey isEqualToString:@"iban"]) {
        _textfield = [[FLTextFieldIBAN alloc] initWithFrame:CGRectMake(MARGE_LEFT, 5, width, 32)];
    }
    else {
        _textfield = [[UITextField alloc] initWithFrame:CGRectMake(MARGE_LEFT, 5, width, 32)];
    }
    
    _textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield.returnKeyType = UIReturnKeyNext;
    _textfield.keyboardAppearance = UIKeyboardAppearanceDark;
    
    _textfield.delegate = self;
    
    if ([_dictionaryKey isEqualToString:@"phone"]) {
        _textfield.keyboardType = UIKeyboardTypePhonePad;
        [_textfield addTarget:self action:@selector(checkPhoneValue) forControlEvents:UIControlEventEditingChanged];
    }
    else if ([_dictionaryKey isEqualToString:@"email"]) {
        _textfield.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else if ([_dictionaryKey isEqualToString:@"firstName"] || [_dictionaryKey isEqualToString:@"lastName"] || [_dictionaryKey isEqualToString:@"name"]) {
        _textfield.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    else if ([_dictionaryKey isEqualToString:@"birthdate"]) {
        _textfield.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    _textfield.font = [UIFont customContentLight:18];
    _textfield.textColor = [UIColor whiteColor];
        
    [self addSubview:_textfield];
}

- (void)createBottomBar {
    bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 1.0f, CGRectGetWidth(self.frame), 1.0f)];
    bottomBar.backgroundColor = [UIColor customBackground];
    
    [self addSubview:bottomBar];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self callAction];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return !_readOnly;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *currentDictionaryKey;
    if (textField == _textfield) {
        currentDictionaryKey = _dictionaryKey;
    }
    
    if ([textField.text isBlank]) {
        [_dictionary setValue:nil forKey:currentDictionaryKey];
    }
    else {
        [_dictionary setValue:textField.text forKey:currentDictionaryKey];
    }
    
    if ([textField isFirstResponder])
        [textField resignFirstResponder];
}

- (void)seTsecureTextEntry:(BOOL)secureTextEntry {
    _textfield.secureTextEntry = secureTextEntry;
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSString *currentDictionaryKey;
    if (textField == _textfield) {
        currentDictionaryKey = _dictionaryKey;
    }
    
    if ([textField.text isBlank]) {
        [_dictionary setValue:nil forKey:currentDictionaryKey];
    }
    else {
        [_dictionary setValue:textField.text forKey:currentDictionaryKey];
    }
    [_targetTextChange performSelector:_actionTextChange withObject:self];
}

#pragma mark -

- (BOOL)becomeFirstResponder {
    return [_textfield becomeFirstResponder];
}

- (void)addForNextClickTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}

- (void)addForTextChangeTarget:(id)target action:(SEL)action {
    _targetTextChange = target;
    _actionTextChange = action;
}

- (void)checkPhoneValue {
    if ([FLHelper formatedPhone2:_textfield.text].length == 12) {
        [self callAction];
    }
}

- (void)checkBirthdateValue {
    if ([_textfield.text length] == [_filterDate length]) {
        [self callAction];
    }
}

#pragma mark - reload

- (void)reloadTextField {
    NSString *text = @"";
    text = [_dictionary objectForKey:_dictionaryKey];
    _textfield.text = text;
}

#pragma mark - manage date textfield

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([_dictionaryKey isEqualToString:@"phone"]) {
        if ([string isEqualToString:@"\r"]) {
            if (textField.text.length > 0) {
                if ([textField.text isEqualToString:@"+33"]) {
                    [self setTextOfTextField:@""];
                    return NO;
                }
                return YES;
            }
            else {
                return NO;
            }
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        if ([_textfield.text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location != NSNotFound && newLength > 8) {
            return NO;
        }
        if (textField.text.length == 0) {
            if ([string isEqualToString:@"0"]) {
                [self setTextOfTextField:_prefixPhone];
                return NO;
            }
            else {
                [self setTextOfTextField:[NSString stringWithFormat:@"%@%@", _prefixPhone, string]];
                return NO;
            }
        }
        
        int size = 12;
        
        if (_textfield.text.UTF8String[0] == '0')
            size = 10;
        
        return (newLength > size) ? NO : YES;
    }
    else if ([_dictionaryKey isEqualToString:@"birthdate"]) {
        if ([string isEqualToString:@"\r"] && textField.text.length > 0) {
            if ([textField.text hasSuffix:@" / "]) {
                textField.text = [textField.text substringToIndex:textField.text.length - 4];
            }
            else {
                textField.text = [textField.text substringToIndex:textField.text.length - 1];
            }
            [self textFieldDidChange:textField];
            [self checkBirthdateValue];
            return NO;
        }
        _filterDate = @"## / ## / ##";
        
        if (!_filterDate) return YES; // No filter provided, allow anything
        
        NSArray *strings = [textField.text componentsSeparatedByString:@" / "];
        if (strings.count == 1) {
            string = [self getModifiedDay:string forTextDay:strings[0]];
        }
        else if (strings.count == 2) {
            string = [self getModifiedMonth:string forTextMonth:strings[1]];
        }
        else if (strings.count == 3) {
            if ([strings[2] hasPrefix:@"19"] || [strings[2] hasPrefix:@"20"]) {
                _filterDate = @"## / ## / ####";
            }
        }
        
        if ([string isEqualToString:@"-1"]) {
            return NO;
        }
        NSString *changedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (range.length == 1 && // Only do for single deletes
            string.length < range.length &&
            [[textField.text substringWithRange:range] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]].location == NSNotFound) {
            // Something was deleted.  Delete past the previous number
            NSInteger location = changedString.length - 1;
            if (location > 0) {
                for (; location > 0; location--) {
                    if (isdigit([changedString characterAtIndex:location])) {
                        break;
                    }
                }
                changedString = [changedString substringToIndex:location];
            }
        }
        
        textField.text = [self filteredTextFromStringWithFilter:changedString andFilter:_filterDate];
        
        strings = [textField.text componentsSeparatedByString:@" / "];
        if (strings.count == 3) {
            if ([strings[2] hasPrefix:@"19"] || [strings[2] hasPrefix:@"20"]) {
                _filterDate = @"## / ## / ####";
            }
        }
        [self textFieldDidChange:textField];
        [self checkBirthdateValue];
        
        return NO;
    }
    else if ([_dictionaryKey isEqualToString:@"iban"]) {
        if ([string isEqualToString:@"\r"]) {
            if (textField.text.length > 2) {
                return YES;
            }
            else {
                return NO;
            }
        }
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        if (textField.text.length == 0) {
            [self setTextOfTextField:[NSString stringWithFormat:@"FR%@", string]];
            return NO;
        }
        
        return (newLength > 27) ? NO : YES;
    }
    else if ([_dictionaryKey isEqualToString:@"smscode"]) {
        if ([string isEqualToString:@"\r"] && textField.text.length > 0) {
            return YES;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 4) ? NO : YES;
    }
    if ([_dictionaryKey isEqualToString:@"amount"]) {
        if ([string isEqualToString:@"\r"] && textField.text.length > 0) {
            return YES;
        }
        
        if (textField.text.length == 1 && [textField.text isEqualToString:@"0"] && [string isEqualToString:@"0"]) {
            return 0;
        }
        
        NSRange symbolRange = [textField.text rangeOfString:@"."];
        if (symbolRange.location == NSNotFound) {
            if ([string isEqualToString:@"."]) {
                if (textField.text.length > 0) {
                    return YES;
                }
                else {
                    textField.text = @"0";
                    return YES;
                }
            }
            if (_textfield.text.length == 4) {
                return NO;
            }
        }
        else {
            NSString *decimals = [_textfield.text substringFromIndex:symbolRange.location];
            if (decimals.length > 2) {
                return NO;
            }
        }
        
        NSCharacterSet *nonNumbers = [NSCharacterSet decimalDigitCharacterSet];
        NSRange r = [string rangeOfCharacterFromSet:nonNumbers];
        
        // Si n est pas un nombre
        if (r.location == NSNotFound) {
            return NO;
        }
        else {
            if (textField.text.length == 1 && [textField.text isEqualToString:@"0"]) {
                textField.text = @"";
            }
        }
        
        return YES;
    }
    return YES;
}

- (void)setTextOfTextField:(NSString *)text {
    [_textfield setText:text];
    [_dictionary setValue:_textfield.text forKey:_dictionaryKey];
}

- (NSString *)getModifiedDay:(NSString *)string forTextDay:(NSString *)textDay {
    if (textDay.length == 1) {
        if ([textDay isEqualToString:@"3"] && [string intValue] > 1) {
            return @"-1";
        }
        return string;
    }
    
    if ([string intValue] > 3) {
        return [NSString stringWithFormat:@"0%@", string];
    }
    
    return string;
}

- (NSString *)getModifiedMonth:(NSString *)string forTextMonth:(NSString *)textMonth {
    if (textMonth.length == 1) {
        if ([textMonth isEqualToString:@"1"] && [string intValue] > 2) {
            return @"-1";
        }
        return string;
    }
    
    if ([string intValue] > 1) {
        return [NSString stringWithFormat:@"0%@", string];
    }
    
    return string;
}

- (NSMutableString *)filteredTextFromStringWithFilter:(NSString *)string andFilter:(NSString *)filter {
    NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
    char outputString[([filter length])];
    BOOL done = NO;
    
    while (onFilter < [filter length] && !done) {
        char filterChar = [filter characterAtIndex:onFilter];
        char originalChar = onOriginal >= string.length ? '\0' : [string characterAtIndex:onOriginal];
        switch (filterChar) {
            case '#':
                if (originalChar == '\0') {
                    // We have no more input numbers for the filter.  We're done.
                    done = YES;
                    break;
                }
                if (isdigit(originalChar)) {
                    outputString[onOutput] = originalChar;
                    onOriginal++;
                    onFilter++;
                    onOutput++;
                }
                else {
                    onOriginal++;
                }
                break;
                
            default:
                // Any other character will automatically be inserted for the user as they type (spaces, - etc..) or deleted as they delete if there are more numbers to come.
                outputString[onOutput] = filterChar;
                onOutput++;
                onFilter++;
                if (originalChar == filterChar)
                    onOriginal++;
                break;
        }
    }
    outputString[onOutput] = '\0'; // Cap the output string
    return [[NSString stringWithUTF8String:outputString] mutableCopy];
}

- (BOOL)isFirstResponder {
    if ([_textfield isFirstResponder]) {
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder {
    return [_textfield resignFirstResponder];
}

- (void)callAction {
    [_target performSelector:_action];
}

- (void)setEnable:(BOOL)enable {
    [_textfield setEnabled:enable];
}

- (void)setDictionary:(NSMutableDictionary *)dic key:(NSString *)k andCountryKey:(NSString*)k2 {
    _dictionary = dic;
    _dictionaryKey = k;
    [self reloadTextField];
}

@end
