//
//  FLTextFieldTitle.m
//  Flooz
//
//  Created by olivier on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTextFieldTitle.h"

@implementation FLTextFieldTitle

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position {
	self = [super initWithFrame:CGRectMake(position.x, position.y, SCREEN_WIDTH - position.x, 41)];
	if (self) {
		_dictionary = dictionary;
		_dictionaryKey = dictionaryKey;

		[self createTitle:title];
		[self createTextField:placeholder];
		[self createBottomBar];
	}
	return self;
}

- (void)createTitle:(NSString *)title {
	_title = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 0, CGRectGetHeight(self.frame))];

	_title.textColor = [UIColor whiteColor];
	_title.text = NSLocalizedString(title, nil);
	_title.font = [UIFont customContentRegular:12];

	[_title setWidthToFit];

	[self addSubview:_title];
}

- (void)createTextField:(NSString *)placeholder {
	_textfield = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_title.frame) + 8, 1, CGRectGetWidth(self.frame) - CGRectGetMaxX(_title.frame) - 18, CGRectGetHeight(self.frame))];

	_textfield.autocorrectionType = UITextAutocorrectionTypeNo;
	_textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_textfield.returnKeyType = UIReturnKeyNext;
	_textfield.keyboardAppearance = UIKeyboardAppearanceDark;

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

- (void)createBottomBar {
	UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
	bottomBar.backgroundColor = [UIColor customSeparator];

	[self addSubview:bottomBar];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ([textField.text isBlank]) {
		[_dictionary setValue:nil forKey:_dictionaryKey];
	}
	else {
		[_dictionary setValue:textField.text forKey:_dictionaryKey];
	}
	[textField resignFirstResponder];
}

- (void)setInputAccessoryView:(UIView *)accessoryView {
	_textfield.inputAccessoryView = accessoryView;
}

@end
