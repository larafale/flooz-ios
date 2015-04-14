//
//  FLNewTransactionAmountInput.m
//  Flooz
//
//  Created by Arnaud on 2014-08-22.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLNewTransactionAmountInput.h"

#import "FLKeyboardView.h"

#define HEIGHT 50. //84.
#define MARGE_TOP 0. //12.
#define MARGE_BOTTOM 0. //17.
#define INPUTS_WIDTH 226.
#define FONT_SIZE_MAX 50.

@implementation FLNewTransactionAmountInput


- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey currencySymbol:(NSString *)symbol andFrame:(CGRect)frame delegate:(id <FLNewTransactionAmountDelegate> )delegate; {
	self = [super initWithFrame:frame];
	if (self) {
		_dictionary = dictionary;
		_dictionaryKey = dictionaryKey;

		[self createTextField:placeholder];
		[self createCurrencySymbol:symbol];

		isEmpty = YES;

		[self commontInit];
	}
	return self;
}

- (void)createCurrencySymbol:(NSString *)symbol {
	currency = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 30, MARGE_TOP - 2.5, 30, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
	currency.font = [UIFont customTitleThin:32];
	currency.textColor = [UIColor whiteColor];
	currency.text = symbol;
	currency.textAlignment = NSTextAlignmentLeft;
    [currency setUserInteractionEnabled:YES];
    [currency addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeFirstResponder)]];

	[self addSubview:currency];
}

- (void)createTextField:(NSString *)placeholder {
	_textfield = [[UITextField alloc] initWithFrame:CGRectMake(0, MARGE_TOP, CGRectGetWidth(self.frame) - 30, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];

	_textfield.autocorrectionType = UITextAutocorrectionTypeNo;
	_textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_textfield.returnKeyType = UIReturnKeyNext;
	_textfield.keyboardAppearance = UIKeyboardAppearanceDark;

	_textfield.delegate = self;

	_textfield.font = [UIFont customTitleThin:26];
	_textfield.textAlignment = NSTextAlignmentLeft;
	_textfield.textColor = [UIColor whiteColor];

	_textfield.layer.sublayerTransform = CATransform3DMakeTranslation(0, 0, 0);

	NSAttributedString *attributedText = [[NSAttributedString alloc]
	                                      initWithString:NSLocalizedString(placeholder, nil)
	                                          attributes:@{
	                                          NSForegroundColorAttributeName: [UIColor customPlaceholder]
										  }];

	_textfield.attributedPlaceholder = attributedText;
	_textfield.textAlignment = NSTextAlignmentRight;

	[self addSubview:_textfield];
}

- (void)commontInit {
	self.clipsToBounds = YES;

	FLKeyboardView *inputView = [FLKeyboardView new];
	[inputView setKeyboardDecimal];
	inputView.textField = _textfield;
	_textfield.inputView = inputView;

	if (_delegate) {
		[self createButtonsView];
	}

    if (_dictionary[_dictionaryKey] && ![_dictionary[_dictionaryKey] isBlank])
        _textfield.text = _dictionary[_dictionaryKey];
    
	{
		separatorTop = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame), 1)];
		separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - 1, CGRectGetWidth(self.frame), 1)];

		separatorTop.backgroundColor = separatorBottom.backgroundColor = [UIColor customSeparator];

		[self addSubview:separatorTop];
		[self addSubview:separatorBottom];
	}
}

- (void) disableInput {
    [_textfield setEnabled:NO];
}

- (BOOL)resignFirstResponder {
	[self endEditing:YES];
	return [super resignFirstResponder];
}

- (void)createButtonsView {
	buttonsView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 42, 0, 42, HEIGHT)];
	buttonsView.layer.borderWidth = 1.;
	buttonsView.layer.borderColor = [UIColor customSeparator].CGColor;

	{
		UIButton *valid = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(buttonsView.frame), CGRectGetHeight(buttonsView.frame) / 2.)];
		UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(buttonsView.frame) / 2., CGRectGetWidth(buttonsView.frame), CGRectGetHeight(buttonsView.frame) / 2.)];
		UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(buttonsView.frame) / 2., CGRectGetWidth(buttonsView.frame), 1)];

		[valid setImage:[UIImage imageNamed:@"transaction-cell-check"] forState:UIControlStateNormal];
		[cancel setImage:[UIImage imageNamed:@"transaction-cell-cross"] forState:UIControlStateNormal];

		[valid addTarget:self action:@selector(didValidTouch) forControlEvents:UIControlEventTouchUpInside];
		[cancel addTarget:self action:@selector(didCancelTouch) forControlEvents:UIControlEventTouchUpInside];

		separator.backgroundColor = [UIColor customSeparator];

		[buttonsView addSubview:valid];
		[buttonsView addSubview:cancel];
		[buttonsView addSubview:separator];
	}

	[self addSubview:buttonsView];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	//[textField setBackgroundColor:[UIColor customBlue]];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField setBackgroundColor:[UIColor clearColor]];

	if (textField == _textfield && [textField.text isBlank]) {
		textField.text = @"0";
	}

	NSString *floatCast = [NSString stringWithFormat:@"%.2f", [_textfield.text floatValue]];
	[_dictionary setValue:floatCast forKey:_dictionaryKey];
}

- (void)setInputAccessoryView:(UIView *)accessoryView {
	_textfield.inputAccessoryView = accessoryView;
}

- (void)hideSeparatorTop {
	separatorTop.hidden = YES;
}

- (void)hideSeparatorBottom {
	separatorBottom.hidden = YES;
}

#pragma mark -

- (BOOL)becomeFirstResponder {
	return [_textfield becomeFirstResponder];
}

#pragma mark -

- (void)didValidTouch {
	[_textfield resignFirstResponder];
	[_delegate didAmountValidTouch];
}

- (void)didCancelTouch {
	[_textfield resignFirstResponder];
	[_delegate didAmountCancelTouch];
}

@end
