//
//  FLTextFieldSignup.m
//  Flooz
//
//  Created by Arnaud on 2014-09-16.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTextFieldSignup.h"

#define MARGE_MIDDLE_BAR 10
#define MARGE_LEFT 10
#define MARGE_RIGHT 10

@implementation FLTextFieldSignup {
    NSString *_prefixPhone;
}

@synthesize bottomBar;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position {
    return [self initWithPlaceholder:placeholder for:dictionary key:dictionaryKey frame:CGRectMakeWithPosition(position) placeholder2:nil key2:nil];
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame {
    return [self initWithPlaceholder:placeholder for:dictionary key:dictionaryKey frame:frame placeholder2:nil key2:nil];
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2 {
    return [self initWithPlaceholder:placeholder for:dictionary key:dictionaryKey frame:CGRectMakeWithPosition(position) placeholder2:placeholder2 key2:dictionaryKey2];
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2 {
    if (frame.size.width == 0) {
        CGRectSetWidth(frame, PPScreenWidth() - (2 * frame.origin.x));
    }
    CGRectSetHeight(frame, 40);
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _prefixPhone = @"0";
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        _dictionaryKey2 = dictionaryKey2;
        
        [self createTextField:placeholder];
        [self createTextField2:placeholder2];
        [self createBottomBar];
        
        _readOnly = NO;
        
        _textfield.text = [_dictionary objectForKey:_dictionaryKey];
        _textfield2.text = [_dictionary objectForKey:_dictionaryKey2];
        
        [_textfield addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
        [_textfield2 addTarget:self
                        action:@selector(textFieldDidChange:)
              forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (void)updateTextFieldFrame:(CGRect)currentFrame {
    BOOL haveOneTextField = (_dictionaryKey2 == nil ? YES : NO);
    CGFloat width = CGRectGetWidth(currentFrame) - MARGE_LEFT - MARGE_RIGHT;
    if (!haveOneTextField) {
        width = (width / 2.) - MARGE_MIDDLE_BAR;
    }
    
    CGFloat maxHeight = CGRectGetHeight(currentFrame);
    
    CGFloat topMargin;
    CGFloat height;
    
    if (maxHeight > 32) {
        height = 32;
        if (maxHeight > 37)
            topMargin = 5;
        else
            topMargin = maxHeight - 32;
    } else {
        topMargin = 0;
        height = maxHeight;
    }
    
    
    if ([_dictionaryKey isEqualToString:@"iban"]) {
        [_textfield setFrame:CGRectMake(MARGE_LEFT, topMargin, width, height)];
    }
    else {
        [_textfield setFrame:CGRectMake(MARGE_LEFT, topMargin, width, height)];
    }
}

- (void)updateTextField2Frame:(CGRect)currentFrame {
    BOOL haveOneTextField = (_dictionaryKey2 == nil ? YES : NO);
    if (haveOneTextField) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(_textfield.frame);
    
    CGFloat maxHeight = CGRectGetHeight(currentFrame);
    
    CGFloat topMargin;
    CGFloat height;
    
    if (maxHeight > 32) {
        height = 32;
        if (maxHeight > 37)
            topMargin = 5;
        else
            topMargin = maxHeight - 32;
    } else {
        topMargin = 0;
        height = maxHeight;
    }
    
    if ([_dictionaryKey isEqualToString:@"iban"]) {
        [_textfield2 setFrame:CGRectMake(MARGE_LEFT, topMargin, width, height)];
    }
    else {
        [_textfield2 setFrame:CGRectMake(MARGE_LEFT, topMargin, width, height)];
    }
}

- (void)createTextField:(NSString *)placeholder {
    BOOL haveOneTextField = (_dictionaryKey2 == nil ? YES : NO);
    CGFloat width = CGRectGetWidth(self.frame) - MARGE_LEFT - MARGE_RIGHT;
    if (!haveOneTextField) {
        width = (width / 2.) - MARGE_MIDDLE_BAR;
    }
    
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(MARGE_LEFT, 5, width, 32)];
    
    _textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield.returnKeyType = UIReturnKeyNext;
    _textfield.keyboardAppearance = UIKeyboardAppearanceDark;
    
    _textfield.delegate = self;
    
    if ([_dictionaryKey isEqualToString:@"phone"]) {
        _textfield.keyboardType = UIKeyboardTypePhonePad;
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
    
    _textfield.attributedPlaceholder = [self placeHolderWithText:placeholder];
    
    [self addSubview:_textfield];
}

- (void)createTextField2:(NSString *)placeholder {
    BOOL haveOneTextField = (_dictionaryKey2 == nil ? YES : NO);
    if (haveOneTextField) {
        return;
    }
    
    CGFloat posXSeparator = CGRectGetMaxX(_textfield.frame) + MARGE_MIDDLE_BAR;
    UIView *middleBar = [[UIView alloc] initWithFrame:CGRectMake(posXSeparator, 10, 1, CGRectGetHeight(self.frame) - 10)];
    middleBar.backgroundColor = [UIColor customSeparator];
    
    CGFloat width = CGRectGetWidth(_textfield.frame);
    
    _textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(middleBar.frame) + MARGE_MIDDLE_BAR, 5, width, 32)];
    
    _textfield2.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield2.returnKeyType = UIReturnKeyNext;
    _textfield2.keyboardAppearance = UIKeyboardAppearanceDark;
    
    _textfield2.delegate = self;
    
    if ([_dictionaryKey2 isEqualToString:@"firstName"] || [_dictionaryKey2 isEqualToString:@"lastName"]) {
        _textfield2.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    _textfield2.font = [UIFont customContentLight:18];
    _textfield2.textColor = [UIColor whiteColor];
    
    _textfield2.attributedPlaceholder = [self placeHolderWithText:placeholder];
    
    [self addSubview:_textfield2];
}

- (NSAttributedString *)placeHolderWithText:(NSString *)placeholder {
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(placeholder, placeholder)
                                          attributes:@{
                                                       NSFontAttributeName: [UIFont customContentLight:18],
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];
    
    return attributedText;
}

- (void)setPlaceholder:(NSString *)placeholder forTextField:(NSInteger)textfieldID {
    if (textfieldID == 1) {
        _textfield.attributedPlaceholder = [self placeHolderWithText:placeholder];
    } else if (textfieldID == 2) {
        _textfield2.attributedPlaceholder = [self placeHolderWithText:placeholder];
    }
}

- (NSString *)dictionaryKey {
    return _dictionaryKey;
}

- (void)createBottomBar {
    bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 1.0f, CGRectGetWidth(self.frame), 1.0f)];
    bottomBar.backgroundColor = [UIColor customBackground];
    
    [self addSubview:bottomBar];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_textfield2) {
        if (textField == _textfield2) {
            [self callAction];
        }
        else {
            [_textfield2 becomeFirstResponder];
        }
    }
    else {
        [self callAction];
    }
    
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
    else {
        currentDictionaryKey = _dictionaryKey2;
    }
    
    if (textField.text.length == 0) {
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
    else {
        currentDictionaryKey = _dictionaryKey2;
    }
    
    if (textField.text.length == 0) {
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
    
    NSString *text2 = @"";
    text2 = [_dictionary objectForKey:_dictionaryKey2];
    _textfield2.text = text2;
}

#pragma mark - manage date textfield

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([_dictionaryKey isEqualToString:@"birthdate"]) {
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
        if ([string isEqualToString:@"\r"])
            return YES;
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        
        return (newLength > 27) ? NO : YES;
    }
    
    if ([_dictionaryKey isEqualToString:@"amount"]) {
        if ([string isEqualToString:@"\r"] && textField.text.length > 0) {
            return YES;
        }
        
        if (textField.text.length == 1 && [textField.text isEqualToString:@"0"] && [string isEqualToString:@"0"]) {
            return NO;
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
    if ([_textfield isFirstResponder] || [_textfield2 isFirstResponder]) {
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    return [_textfield resignFirstResponder];
}

- (void)callAction {
    [_target performSelector:_action];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [bottomBar setFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 1.0f, CGRectGetWidth(self.frame), 1.0f)];
    [self updateTextFieldFrame:frame];
    [self updateTextFieldFrame:frame];
}

- (void)setEnable:(BOOL)enable {
    [_textfield setEnabled:enable];
    [_textfield2 setEnabled:enable];
}

- (void)setDictionary:(NSMutableDictionary *)dic andKey:(NSString *)k {
    _dictionary = dic;
    _dictionaryKey = k;
    [self reloadTextField];
}

@end
