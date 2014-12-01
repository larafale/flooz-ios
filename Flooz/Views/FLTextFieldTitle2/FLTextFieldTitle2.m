//
//  FLTextFieldTitle2.m
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTextFieldTitle2.h"

@implementation FLTextFieldTitle2

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position {
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

- (void)reloadData {
	[self setTextFieldValueForStyle];
}

- (void)createTitle:(NSString *)title {
	_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 21)];

	_title.textColor = [UIColor customBlueLight];
	_title.text = NSLocalizedString(title, nil);
	_title.font = [UIFont customContentRegular:12];

	[_title setWidthToFit];

	[self addSubview:_title];
}

- (void)createTextField:(NSString *)placeholder {
	_textfield = [[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_title.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(_title.frame))];

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
	                                          NSFontAttributeName: [UIFont customContentLight:18],
	                                          NSForegroundColorAttributeName: [UIColor customPlaceholder]
										  }];

	_textfield.attributedPlaceholder = attributedText;

	[_textfield addTarget:self action:@selector(setDictionaryValueForStyle) forControlEvents:UIControlEventEditingChanged];

	[self addSubview:_textfield];
}

- (void)createBottomBar {
	UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
	bottomBar.backgroundColor = [UIColor customSeparator];

	[self addSubview:bottomBar];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	// Si backward
	if ((!string || [string isBlank]) && range.length == 1) {
		if (_style == FLTextFieldTitle2StyleRIB) {
			return [_textfield.text length] > 2;
		}
		else {
			return YES;
		}
	}

	NSUInteger length = [_textfield.text length];

	if (_style == FLTextFieldTitle2StyleCardNumber && length >= 19) {
		if (string && [string isEqualToString:@"\r"] && textField.text.length > 0) {
			return YES;
		}
		return NO;
	}
	else if (_style == FLTextFieldTitle2StyleCardExpire) {
		NSString *filterDate = @"##-##";
		if (string && [string isEqualToString:@"\r"] && textField.text.length > 0) {
			return YES;
		}
		if (length >= 5) {
			return NO;
		}

		if (!filterDate) return YES; // No filter provided, allow anything

		NSArray *strings = [textField.text componentsSeparatedByString:@"-"];
		if (strings.count == 1) {
			string = [self getModifiedMonth:string forTextMonth:strings[0]];
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

		textField.text = [self filteredTextFromStringWithFilter:changedString andFilter:filterDate];
		[self setDictionaryValueForStyle];

		return NO;
	}
	else if (_style == FLTextFieldTitle2StyleCVV && length >= 3) {
		if (string && [string isEqualToString:@"\r"] && textField.text.length > 0) {
			return YES;
		}
		return NO;
	}
	else if (_style == FLTextFieldTitle2StyleRIB && length >= 27) {
		if (string && [string isEqualToString:@"\r"] && textField.text.length > 0) {
			return YES;
		}
		return NO;
	}

	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self callAction];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self setDictionaryValueForStyle];
	[textField resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
	return [_textfield becomeFirstResponder];
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType {
	_textfield.keyboardType = keyboardType;
}

- (void)seTsecureTextEntry:(BOOL)secureTextEntry {
	_textfield.secureTextEntry = secureTextEntry;
}

#pragma mark -

- (void)addForNextClickTarget:(id)target action:(SEL)action {
	_target = target;
	_action = action;
}

- (void)setDictionaryValueForStyle {
	if ([_textfield.text isBlank]) {
		if (_style == FLTextFieldTitle2StyleRIB) {
			[_dictionary setValue:@"FR" forKey:_dictionaryKey];
		}
		else {
			[_dictionary setValue:nil forKey:_dictionaryKey];
		}
	}
	else if (_style == FLTextFieldTitle2StyleCardNumber || _style == FLTextFieldTitle2StyleRIB) {
		[_dictionary setValue:[_textfield.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:_dictionaryKey];
	}
	else {
		[_dictionary setValue:_textfield.text forKey:_dictionaryKey];
	}

	[self setTextFieldValueForStyle];

	if ([_textfield isFirstResponder]) {
		if (_style == FLTextFieldTitle2StyleCardNumber && [[_dictionary objectForKey:_dictionaryKey] length] == 16) {
			[self callAction];
		}
		else if (_style == FLTextFieldTitle2StyleCardExpire && [[_dictionary objectForKey:_dictionaryKey] length] == 5) {
			[self callAction];
		}
		else if (_style == FLTextFieldTitle2StyleCVV && [[_dictionary objectForKey:_dictionaryKey] length] == 3) {
			[self callAction];
		}
	}
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

- (void)setTextFieldValueForStyle {
	NSString *text = @"";

	if (_style == FLTextFieldTitle2StyleCardNumber) {
		for (int i = 0; i < [[_dictionary objectForKey:_dictionaryKey] length]; ++i) {
			text = [text stringByAppendingString:[[_dictionary objectForKey:_dictionaryKey] substringWithRange:NSMakeRange(i, 1)]];

			if (i % 4 == 3 && i != [[_dictionary objectForKey:_dictionaryKey] length] - 1) {
				text = [text stringByAppendingString:@" "];
			}
		}
	}
	else {
		text = [_dictionary objectForKey:_dictionaryKey];
	}

	_textfield.text = text;
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

- (void)callAction {
	[_textfield resignFirstResponder];
	[_target performSelector:_action];
}

@end
