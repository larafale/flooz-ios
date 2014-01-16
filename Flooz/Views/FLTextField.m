//
//  FLTextField.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLTextField.h"

@implementation FLTextField

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionnary key:(NSString *)dictionnaryKey position:(CGPoint)position
{
    return [self initWithIcon:iconName placeholder:placeholder for:dictionnary key:dictionnaryKey position:position placeholder2:nil key2:nil];
}

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionnary key:(NSString *)dictionnaryKey position:(CGPoint)position placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionnaryKey2
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, SCREEN_WIDTH - (2 * position.x), 37)];
    if (self) {
        _dictionnary = dictionnary;
        _dictionnaryKey = dictionnaryKey;
        
        [self createIcon:iconName];
        [self createTextField:placeholder];
        [self createBottomBar];
    }
    return self;
}

- (void)createIcon:(NSString *)iconName
{
    icon = [UIImageView imageNamed:iconName];
    icon.frame = CGRectMakeSetXY(icon.frame, 6, 17);
    
    [self addSubview:icon];
}

- (void)createTextField:(NSString *)placeholder
{
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 18, 8, CGRectGetWidth(self.frame) - CGRectGetMaxX(icon.frame) - 18, 30)];
    
    _textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
    _textfield.delegate = self;
    
    _textfield.font = [UIFont customContentLight:12];
    _textfield.textColor = [UIColor whiteColor];
    
    _textfield.placeholder = placeholder;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                      initWithString:NSLocalizedString(placeholder, nil)
                      attributes:@{
                                   NSFontAttributeName: [UIFont customContentLight:12],
                                   NSForegroundColorAttributeName: [UIColor whiteColor]
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
    if([textField.text isEqualToString:@""]){
        [_dictionnary setValue:nil forKey:_dictionnaryKey];
    }else{
        [_dictionnary setValue:textField.text forKey:_dictionnaryKey];
    }
    [textField resignFirstResponder];
}

@end
