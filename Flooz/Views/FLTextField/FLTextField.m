//
//  FLTextField.m
//  Flooz
//
//  Created by Olive on 1/5/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLTextField.h"
#import "JTHelper.h"

@interface FLTextField () {
    UIView *lineView;
    
    id _target;
    SEL _action;
    
    id _targetTextChange;
    SEL _actionTextChange;
    
    id _focusId;
    SEL _focusAction;
    
    NSString *_filterDate;
    
    UIImage *tintedClearImage;
}

@property (nonatomic) Boolean isValid;

@end

@implementation FLTextField

- (id)initWithPlaceholder:(nonnull NSString *)placeholder for:(nonnull NSMutableDictionary *)dictionary key:(nonnull NSString *)dictionaryKey frame:(CGRect)frame {
    if (frame.size.width == 0) {
        CGRectSetWidth(frame, PPScreenWidth() - (2 * frame.origin.x));
    }
    if (frame.size.height == 0) {
        CGRectSetHeight(frame, 40);
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        self.dictionary = dictionary;
        self.dictionaryKey = dictionaryKey;
        [self setPlaceholder:placeholder];
        [self setText:[self.dictionary objectForKey:self.dictionaryKey]];
        
        [self commonInit];
    }
    return self;
}

- (id)initWithPlaceholder:(nonnull NSString *)placeholder for:(nonnull NSMutableDictionary *)dictionary key:(nonnull NSString *)dictionaryKey position:(CGPoint)position {
    return [self initWithPlaceholder:placeholder for:dictionary key:dictionaryKey frame:CGRectMakeWithPosition(position)];
}

- (void)commonInit {
    self.readOnly = false;
    self.enableAllCaps = false;
    self.maxLenght = -1;
    self.isValid = YES;
    
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.returnKeyType = UIReturnKeyNext;
    self.keyboardAppearance = UIKeyboardAppearanceDark;
    
    self.delegate = self;
    
    self.font = [UIFont customContentLight:17];
    self.textColor = [UIColor whiteColor];
    
    self.floatLabelFont = [UIFont customContentBold:12];
    self.floatLabelActiveColor = [UIColor customBlue];
    self.floatLabelPassiveColor = [UIColor customPlaceholder];
    
    self.lineNormalColor = [UIColor customBackground];
    self.lineSelectedColor = [UIColor customBlue];
    self.lineDisableColor = [UIColor clearColor];
    self.lineErrorColor = [UIColor customRed];
    
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self setType:FLTextFieldTypeText];
    
    [self createBottomLine];
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    
    self.attributedPlaceholder = [self placeHolderWithText:placeholder];
}

- (NSAttributedString *)placeHolderWithText:(NSString *)placeholder {
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(placeholder, placeholder)
                                          attributes:@{
                                                       NSFontAttributeName: self.font,
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];
    
    return attributedText;
}

- (void)createBottomLine {
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 0.7, self.frame.size.width, 0.7)];
    [self updateBottomLine];
    [self addSubview:lineView];
}

- (void)reloadTextField {
    NSString *text = @"";
    text = [_dictionary objectForKey:_dictionaryKey];
    [self setText:text];
}

- (void)addForNextClickTarget:(id)target action:(SEL)action {
    _target = target;
    _action = action;
}

- (void)addForTextChangeTarget:(id)target action:(SEL)action {
    _targetTextChange = target;
    _actionTextChange = action;
}

- (void)addTextFocusTarget:(id)instance action:(SEL)action {
    _focusId = instance;
    _focusAction = action;
}

- (void)setDictionary:(nonnull NSMutableDictionary *)dic key:(nonnull NSString *)k {
    _dictionary = dic;
    _dictionaryKey = k;
    
    [self reloadTextField];
}

- (void)setType:(FLTextFieldType)t {
    if (type != t) {
        type = t;
        
        self.secureTextEntry = NO;
        
        switch (type) {
            case FLTextFieldTypeDate: {
                self.keyboardType = UIKeyboardTypeNumberPad;
                break;
            }
            case FLTextFieldTypeNumber: {
                self.keyboardType = UIKeyboardTypeNumberPad;
                break;
            }
            case FLTextFieldTypeFloatNumber: {
                self.keyboardType = UIKeyboardTypeDecimalPad;
                break;
            }
            case FLTextFieldTypeText: {
                self.keyboardType = UIKeyboardTypeDefault;
                break;
            }
            case FLTextFieldTypePassword: {
                self.keyboardType = UIKeyboardTypeDefault;
                self.secureTextEntry = YES;
                break;
            }
            case FLTextFieldTypeEmail: {
                self.keyboardType = UIKeyboardTypeEmailAddress;
                break;
            }
            case FLTextFieldTypeURL: {
                self.keyboardType = UIKeyboardTypeURL;
                break;
            }
        }
        
    }
}

-(void) setEnabled:(BOOL)enabled{
    super.enabled = enabled;
    
    [self updateBottomLine];
}

- (void)updateBottomLine {
    if (!self.enabled)
        lineView.backgroundColor = self.lineDisableColor;
    else if (!self.isValid)
        lineView.backgroundColor = self.lineErrorColor;
    else if (self.isSelected)
        lineView.backgroundColor = self.lineSelectedColor;
    else
        lineView.backgroundColor = self.lineNormalColor;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self callAction];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return !_readOnly;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self setSelected:YES];
    [self updateBottomLine];
    
    if (_focusId) {
        if ([_focusId respondsToSelector:_focusAction]) {
            [_focusId performSelector:_focusAction];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField.text.length == 0)
        [_dictionary setValue:nil forKey:_dictionaryKey];
    else
        [_dictionary setValue:textField.text forKey:_dictionaryKey];
    
    if ([textField isFirstResponder])
        [textField resignFirstResponder];
    
    [self setSelected:NO];
    
    [self updateBottomLine];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.length == 0)
        [_dictionary setValue:nil forKey:_dictionaryKey];
    else
        [_dictionary setValue:textField.text forKey:_dictionaryKey];
    
    if ([_targetTextChange respondsToSelector:_actionTextChange]) {
        [_targetTextChange performSelector:_actionTextChange withObject:self];
    }
}

- (void)callAction {
    if ([_target respondsToSelector:_action]) {
        [_target performSelector:_action];
    }
}

- (void)checkBirthdateValue {
    if ([self.text length] == [_filterDate length]) {
        [self callAction];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (type == FLTextFieldTypeDate) {
        _filterDate = @"## / ## / ##";
        
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
    } else if (type == FLTextFieldTypeNumber || type == FLTextFieldTypeFloatNumber) {
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        BOOL isBackSpace = strcmp(_char, "\b") == -8;

        if ((isBackSpace || [string isEqualToString:@"\r"]) && textField.text.length > 0) {
            return YES;
        }
        
        if (textField.text.length == 1 && [textField.text isEqualToString:@"0"] && [string isEqualToString:@"0"]) {
            return NO;
        }
        
        NSRange symbolRange = [textField.text rangeOfString:@"."];
        NSRange symbolRange2 = [textField.text rangeOfString:@","];
        if (symbolRange.location == NSNotFound && symbolRange2.location == NSNotFound) {
            if ([string isEqualToString:@"."]) {
                if (textField.text.length > 0) {
                    return YES;
                }
                else {
                    textField.text = @"0";
                    return YES;
                }
            }
            if ([string isEqualToString:@","]) {
                if (textField.text.length > 0) {
                    return YES;
                }
                else {
                    textField.text = @"0";
                    return YES;
                }
            }
            
            if (textField.text.length == 4) {
                return NO;
            }
        }
        else if (symbolRange.location != NSNotFound) {
            NSString *decimals = [textField.text substringFromIndex:symbolRange.location];
            if (decimals.length > 2) {
                return NO;
            }
        } else if (symbolRange2.location != NSNotFound) {
            NSString *decimals = [textField.text substringFromIndex:symbolRange2.location];
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
    
    if ([string isEqualToString:@"\r"])
        return YES;
    
    if (self.maxLenght > 0) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        if (newLength > self.maxLenght)
            return NO;
        else if (self.enableAllCaps) {
            NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
            
            if (lowercaseCharRange.location != NSNotFound) {
                textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
                return NO;
            }
        }
        return YES;
    }
    
    if (self.enableAllCaps) {
        NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        
        if (lowercaseCharRange.location != NSNotFound) {
            textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
            return NO;
        }
    }
    
    return YES;
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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self tintClearImage];
}

- (void)setValid:(Boolean)isValid {
    self.isValid = isValid;
    
    [self updateBottomLine];
}

- (void)setLineNormalColor:(UIColor *)lineNormalColor {
    self->_lineNormalColor = lineNormalColor;
    
    [self updateBottomLine];
}

- (void)setLineSelectedColor:(UIColor *)lineSelectedColor {
    self->_lineSelectedColor = lineSelectedColor;
    
    [self updateBottomLine];
}

- (void)setLineErrorColor:(UIColor *)lineErrorColor {
    self->_lineErrorColor = lineErrorColor;
    
    [self updateBottomLine];
}

- (void)setLineDisableColor:(UIColor *)lineDisableColor {
    self->_lineDisableColor = lineDisableColor;
    
    [self updateBottomLine];
}

- (void)tintClearImage {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            UIImage *buttonImage = [button imageForState:UIControlStateHighlighted];
            if (buttonImage) {
                if (tintedClearImage == nil) {
                    tintedClearImage = [FLHelper colorImage:buttonImage color:[UIColor customPlaceholder]];
                }
                [button setImage:tintedClearImage forState:UIControlStateNormal];
                [button setImage:tintedClearImage forState:UIControlStateHighlighted];
            }
        }
    }
}

@end
