//
//  FLPhoneField.m
//  Flooz
//
//  Created by Epitech on 9/9/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLPhoneField.h"
#import "NBPhoneNumber.h"
#import "NBPhoneNumberUtil.h"

#define MARGE_MIDDLE_BAR 10
#define MARGE_LEFT 10
#define MARGE_RIGHT 10

@interface FLPhoneField () {
    UIView *_countryView;
    FLCountryPicker *_countryPicker;
    UIImageView *_countryFlag;
    UILabel *_countryLabel;
    UITextField *_countryPickerViewTextField;
    
    UITextView *_fakeTextfield;
    
    NSString *_placeholder;
}

@end

@implementation FLPhoneField

@synthesize bottomBar;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary position:(CGPoint)position {
    return [self initWithPlaceholder:placeholder for:dictionary frame:CGRectMake(position.x, position.y, PPScreenWidth() - 2 * position.x, 40)];
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        _placeholder = placeholder;
        _dictionary = dictionary;

        if (!_dictionary[@"country"] || [_dictionary[@"country"] isBlank]) {
            NSLocale *currentLocale = [NSLocale currentLocale];
            NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
            
            if ([Flooz sharedInstance].currentTexts) {
                self.currentCountry = [FLCountry countryFromCode:countryCode];
                if (!self.currentCountry)
                    self.currentCountry = [FLCountry defaultCountry];
                
                [_dictionary setValue:self.currentCountry.code forKey:@"country"];
            } else {
                [[Flooz sharedInstance] textObjectFromApi:^(id result) {
                    self.currentCountry = [FLCountry countryFromCode:countryCode];
                    if (!self.currentCountry)
                        self.currentCountry = [FLCountry defaultCountry];
                    
                    [_dictionary setValue:self.currentCountry.code forKey:@"country"];
                    [self reloadTextField];
                } failure:^(NSError *error) {
                    self.currentCountry = [FLCountry defaultCountry];
                    [_dictionary setValue:self.currentCountry.code forKey:@"country"];
                    
                    [self reloadTextField];
                }];
            }
        }
        
        [self createCoutryView];
        [self createTextfield];
        [self createBottomBar];
        
        [self reloadTextField];
    }
    return self;
}

- (void)createCoutryView {
    CGFloat viewSize = (CGRectGetWidth(self.frame) / 100) * 30;
    CGFloat marginH = (viewSize / 100) * 10;
    CGFloat marginV = (CGRectGetHeight(self.frame) / 100) * 25;
    CGFloat childWidth = (viewSize - (3 * marginH)) / 2;
    CGFloat childHeight = CGRectGetHeight(self.frame) - (2 * marginV);
    
    _countryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewSize, CGRectGetHeight(self.frame))];
    
    _countryFlag = [[UIImageView alloc] initWithFrame:CGRectMake(marginH, marginV, childWidth, childHeight)];
    _countryFlag.contentMode = UIViewContentModeScaleAspectFit;
    
    _countryLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_countryFlag.frame) + marginH, marginV, childWidth, childHeight)];
    _countryLabel.textColor = [UIColor whiteColor];
    _countryLabel.font = [UIFont customContentRegular:15];
    _countryLabel.minimumScaleFactor = 8./_countryLabel.font.pointSize;
    _countryLabel.adjustsFontSizeToFitWidth = YES;
    _countryLabel.numberOfLines = 1;
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(viewSize - 1, marginV / 2, 1, CGRectGetHeight(self.frame) - (2 * (marginV / 2)))];
    separator.backgroundColor = [UIColor customBackground];
    
    _countryPickerViewTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    
    _countryPicker = [[FLCountryPicker alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _countryPicker.showsSelectionIndicator = YES;
    _countryPicker.delegate = self;
    
    _countryPickerViewTextField.inputView = _countryPicker;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.translucent = NO;
    toolBar.barTintColor=[UIColor customBackgroundHeader];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    [doneButton setTintColor:[UIColor customBlue]];
    
    [toolBar setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    _countryPickerViewTextField.inputAccessoryView = toolBar;
    
    [_countryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(countryViewTouched)]];
    
    [_countryView addSubview:_countryFlag];
    [_countryView addSubview:_countryLabel];
    [_countryView addSubview:separator];
    [_countryView addSubview:_countryPickerViewTextField];
    
    [self addSubview:_countryView];
}

- (void)createTextfield {
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetWidth(_countryView.frame) + MARGE_LEFT, 5, CGRectGetWidth(self.frame) - CGRectGetWidth(_countryView.frame) - MARGE_LEFT - MARGE_RIGHT, 32)];
    
    _textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield.returnKeyType = UIReturnKeyNext;
    _textfield.keyboardAppearance = UIKeyboardAppearanceDark;
    
    _textfield.delegate = self;
    
    _textfield.keyboardType = UIKeyboardTypePhonePad;
    
    _textfield.font = [UIFont customContentLight:18];
    _textfield.textColor = [UIColor whiteColor];
    [_textfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    _textfield.attributedPlaceholder = [self placeHolderWithText:_placeholder];
    
    FLKeyboardView  *inputView = [FLKeyboardView new];
    inputView.textField = _textfield;
    _textfield.inputView = inputView;
    
    [self addSubview:_textfield];
}

- (void)createBottomBar {
    bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 1.0f, CGRectGetWidth(self.frame), 1.0f)];
    bottomBar.backgroundColor = [UIColor customBackground];
    
    [self addSubview:bottomBar];
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

#pragma mark -

- (void)countryViewTouched {
    [_countryPickerViewTextField becomeFirstResponder];
}

- (void)doneTouched:(UIBarButtonItem *)sender
{
    [_textfield becomeFirstResponder];
    [self countryPicker:_countryPicker didSelectCountry:[_countryPicker getSelectedCountry]];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([string isEqualToString:@"\r"]) {
        return YES;
    }
    
    int maxLenght = 10;
    if (![textField.text hasPrefix:@"0"]) {
        maxLenght = 9;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    
    return (newLength > maxLenght) ? NO : YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ([_textfield.text isBlank])
        [_dictionary setValue:nil forKey:@"phone"];
    else {
        [_dictionary setValue:textField.text forKey:@"phone"];
        
        [_targetTextChange performSelector:_actionTextChange withObject:self];
        
        NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
        NSError *anError = nil;
        NBPhoneNumber *myNumber = [phoneUtil parse:_textfield.text defaultRegion:self.currentCountry.code error:&anError];
        
        if (anError == nil) {
            if ([phoneUtil isValidNumber:myNumber])
                [self callAction];
        }
    }
}

- (void)callAction {
    [_target performSelector:_action];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self callAction];
    
    return YES;
}

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

- (void)reloadTextField {
    [self countryPicker:_countryPicker didSelectCountry:[FLCountry countryFromCode:_dictionary[@"country"]]];
    
    [_textfield setText:_dictionary[@"phone"]];
}

- (BOOL)isFirstResponder {
    if ([_textfield isFirstResponder] || [_fakeTextfield isFirstResponder]) {
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    return [_textfield resignFirstResponder];
}

- (void)countryPicker:(FLCountryPicker *)picker didSelectCountry:(FLCountry *)country {
    self.currentCountry = country;
    [_countryPicker setSelectedCountry:self.currentCountry];
    [_countryFlag setImage:[UIImage imageNamed:country.imageName]];
    [_countryLabel setText:country.phoneCode];
    
    [_dictionary setValue:self.currentCountry.code forKey:@"country"];
    [_dictionary setValue:self.currentCountry.phoneCode forKey:@"indicatif"];
}

@end
