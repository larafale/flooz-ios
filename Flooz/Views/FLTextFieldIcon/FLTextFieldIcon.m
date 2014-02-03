//
//  FLTextFieldIcon.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLTextFieldIcon.h"

@implementation FLTextFieldIcon

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position
{
    return [self initWithIcon:iconName placeholder:placeholder for:dictionary key:dictionaryKey position:position placeholder2:nil key2:nil];
}

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, SCREEN_WIDTH - (2 * position.x), 37)];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        _dictionaryKey2 = dictionaryKey2;
        
        [self createIcon:iconName];
        [self createTextField:placeholder];
        [self createTextField2:placeholder2];
        [self createBottomBar];
    }
    return self;
}

- (void)createIcon:(NSString *)iconName
{
    icon = [UIImageView imageNamed:iconName];
    icon.frame = CGRectSetXY(icon.frame, 6, 17);
    
    [self addSubview:icon];
}

- (void)createTextField:(NSString *)placeholder
{
    BOOL haveOneTextField = (_dictionaryKey2 == nil ? YES : NO);
    CGFloat width = CGRectGetWidth(self.frame) - CGRectGetMaxX(icon.frame) - 18;
    if(haveOneTextField){
        width /= 2.;
    }
    
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 18, 8, width, 30)];
    
    _textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield.returnKeyType = UIReturnKeyNext;
    
    _textfield.delegate = self;
    
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
    _textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 18, 8, CGRectGetWidth(self.frame) - CGRectGetMaxX(icon.frame) - 18, 30)];
    
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
