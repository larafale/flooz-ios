//
//  FLHomeTextField.m
//  Flooz
//
//  Created by Jonathan on 22/07/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLHomeTextField.h"

@implementation FLHomeTextField {
    NSString *_prefixPhone;
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position {
	self = [super initWithFrame:CGRectMake(position.x, position.y, SCREEN_WIDTH - 2 * position.x, 32)];
	if (self) {
		_dictionary = dictionary;
		_dictionaryKey = dictionaryKey;
        _prefixPhone = @"0";
		[self createTextField:placeholder];
		[self createBottomBar];
	}
	return self;
}

- (void)createTextField:(NSString *)placeholder {
	_textfield = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 0, CGRectGetWidth(self.frame) - 20.0f, CGRectGetHeight(self.frame))];

	_textfield.autocorrectionType = UITextAutocorrectionTypeNo;
	_textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_textfield.returnKeyType = UIReturnKeyNext;
	_textfield.keyboardAppearance = UIKeyboardAppearanceDark;

	_textfield.delegate = self;

	_textfield.font = [UIFont customContentLight:18];
	_textfield.textColor = [UIColor whiteColor];

	NSAttributedString *attributedText = [[NSAttributedString alloc]
	                                      initWithString:NSLocalizedString(placeholder, nil)
	                                          attributes:@{
	                                          NSForegroundColorAttributeName: [UIColor customPlaceholder]
										  }];

	_textfield.attributedPlaceholder = attributedText;

	[_textfield addTarget:self action:@selector(checkValueForCallAction:) forControlEvents:UIControlEventEditingChanged];

	[self addSubview:_textfield];
}

- (void)createBottomBar {
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 1.0f, CGRectGetWidth(self.frame), 1.0f)];
    bottomBar.backgroundColor = [UIColor customBackground];
    
    [self addSubview:bottomBar];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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

	return (newLength > (_prefixPhone.length + 9)) ? NO : YES;
}

- (void)setTextOfTextField:(NSString *)text {
	[_textfield setText:text];
	[_dictionary setValue:_textfield.text forKey:_dictionaryKey];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([_dictionaryKey isEqualToString:@"amount"]) {
        if (textField == _textfield && [textField.text isBlank]) {
            textField.text = @"0";
        }
        NSString *floatCast = [NSString stringWithFormat:@"%.2f", [_textfield.text floatValue]];
        [_dictionary setValue:floatCast forKey:_dictionaryKey];
        
        return;
    }
	if ([textField.text isBlank]) {
		[_dictionary setValue:nil forKey:_dictionaryKey];
	}
	else {
		[_dictionary setValue:textField.text forKey:_dictionaryKey];
	}
	[textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
	return [_textfield becomeFirstResponder];
}

- (void)addForNextClickTarget:(id)target action:(SEL)action {
	_target = target;
	_action = action;
}

- (void)checkValueForCallAction:(UITextField *)textField {
	if ([textField.text isBlank]) {
		[_dictionary setValue:nil forKey:_dictionaryKey];
	}
	else {
		[_dictionary setValue:textField.text forKey:_dictionaryKey];
	}

	if (_textfield.text.length >= (_prefixPhone.length + 9)) {
		[self callAction];
	}
	else {
		[self callAction];
	}
}

- (void)callAction {
	[_target performSelector:_action];
}

- (void)setEnable:(BOOL)enable {
    [_textfield setEnabled:enable];
}

@end
