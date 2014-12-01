//
//  FLTextFieldIcon.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTextFieldIcon.h"

#define MARGE_MIDDLE_BAR 10

@implementation FLTextFieldIcon

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position {
	return [self initWithIcon:iconName placeholder:placeholder for:dictionary key:dictionaryKey frame:CGRectMakeWithPosition(position) placeholder2:nil key2:nil];
}

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame {
	return [self initWithIcon:iconName placeholder:placeholder for:dictionary key:dictionaryKey frame:frame placeholder2:nil key2:nil];
}

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2 {
	return [self initWithIcon:iconName placeholder:placeholder for:dictionary key:dictionaryKey frame:CGRectMakeWithPosition(position) placeholder2:placeholder2 key2:dictionaryKey2];
}

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2 {
	if (frame.size.width == 0) {
		CGRectSetWidth(frame, SCREEN_WIDTH - (2 * frame.origin.x));
	}
	CGRectSetHeight(frame, 45);

	self = [super initWithFrame:frame];
	if (self) {
		_dictionary = dictionary;
		_dictionaryKey = dictionaryKey;
		_dictionaryKey2 = dictionaryKey2;

		[self createIcon:iconName];
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

- (void)createIcon:(NSString *)iconName {
	icon = [UIImageView imageNamed:iconName];
	CGRectSetXY(icon.frame, 16, 17);

	[self addSubview:icon];
}

- (void)createTextField:(NSString *)placeholder {
	BOOL haveOneTextField = (_dictionaryKey2 == nil ? YES : NO);
	CGFloat width = CGRectGetWidth(self.frame) - CGRectGetMaxX(icon.frame) - 18 - 60;
	if (!haveOneTextField) {
		width = (width / 2.) - MARGE_MIDDLE_BAR;
	}

	_textfield = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 18, 8, width, 30)];

	_textfield.autocorrectionType = UITextAutocorrectionTypeNo;
	_textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_textfield.returnKeyType = UIReturnKeyNext;
	_textfield.keyboardAppearance = UIKeyboardAppearanceDark;

	_textfield.delegate = self;

	if ([_dictionaryKey isEqualToString:@"phone"]) {
		_textfield.keyboardType = UIKeyboardTypeNumberPad;
		[_textfield addTarget:self action:@selector(checkPhoneValue) forControlEvents:UIControlEventEditingChanged];
	}
	else if ([_dictionaryKey isEqualToString:@"email"]) {
		_textfield.keyboardType = UIKeyboardTypeEmailAddress;
	}
	else if ([_dictionaryKey isEqualToString:@"firstName"] || [_dictionaryKey isEqualToString:@"lastName"]) {
		_textfield.autocapitalizationType = UITextAutocapitalizationTypeWords;
	}
	else if ([_dictionaryKey isEqualToString:@"birthday"]) {
		_textfield.keyboardType = UIKeyboardTypeNumberPad;
	}

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

- (void)createTextField2:(NSString *)placeholder {
	BOOL haveOneTextField = (_dictionaryKey2 == nil ? YES : NO);
	if (haveOneTextField) {
		return;
	}

	CGFloat posXSeparator = CGRectGetMaxX(_textfield.frame) + MARGE_MIDDLE_BAR;
	if (icon) {
		posXSeparator = CGRectGetWidth(self.frame) / 2;
	}
	UIView *middleBar = [[UIView alloc] initWithFrame:CGRectMake(posXSeparator, 10, 1, CGRectGetHeight(self.frame) - 10)];
	middleBar.backgroundColor = [UIColor customSeparator];

	[self addSubview:middleBar];


	CGFloat width = ((CGRectGetWidth(self.frame) - CGRectGetMaxX(icon.frame) - 18) / 2.) - MARGE_MIDDLE_BAR;

	_textfield2 = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(middleBar.frame) + MARGE_MIDDLE_BAR, 8, width, 30)];

	_textfield2.autocorrectionType = UITextAutocorrectionTypeNo;
	_textfield2.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_textfield2.returnKeyType = UIReturnKeyNext;
	_textfield2.keyboardAppearance = UIKeyboardAppearanceDark;

	_textfield2.delegate = self;

	if ([_dictionaryKey2 isEqualToString:@"firstName"] || [_dictionaryKey2 isEqualToString:@"lastName"]) {
		_textfield2.autocapitalizationType = UITextAutocapitalizationTypeWords;
	}
	_textfield2.font = [UIFont customContentLight:14];
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

- (void)createBottomBar {
	UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
	bottomBar.backgroundColor = [UIColor customSeparator];

	[self addSubview:bottomBar];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];

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

	if ([textField.text isBlank]) {
		[_dictionary setValue:nil forKey:currentDictionaryKey];
	}
	else {
		[_dictionary setValue:textField.text forKey:currentDictionaryKey];
	}

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
		[_textfield resignFirstResponder];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([_dictionaryKey isEqualToString:@"birthday"]) {
		NSString *filter = @"## / ## / ##";

		if (!filter) return YES; // No filter provided, allow anything

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

		textField.text = [self filteredPhoneStringFromStringWithFilter:changedString andFilter:filter];

		return NO;
	}
	return YES;
}

- (NSMutableString *)filteredPhoneStringFromStringWithFilter:(NSString *)string andFilter:(NSString *)filter {
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
	return [NSString stringWithUTF8String:outputString];
}

- (void)callAction {
	[_target performSelector:_action];
}

@end
