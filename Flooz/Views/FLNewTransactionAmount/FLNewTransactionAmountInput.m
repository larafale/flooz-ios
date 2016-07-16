//
//  FLNewTransactionAmountInput.m
//  Flooz
//
//  Created by Arnaud on 2014-08-22.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLNewTransactionAmountInput.h"

#import "FLKeyboardView.h"

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
	currency = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 28, 0, 28, CGRectGetHeight(self.frame) - 5.5)];
    currency.font = [UIFont customTitleExtraLight:20];
	currency.textColor = [UIColor whiteColor];
	currency.text = symbol;
	currency.textAlignment = NSTextAlignmentLeft;
    currency.numberOfLines = 1;
    [currency setUserInteractionEnabled:YES];
    [currency addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(becomeFirstResponder)]];

	[self addSubview:currency];
}

- (void)createTextField:(NSString *)placeholder {
	_textfield = [[VENCalculatorInputTextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) - 30, CGRectGetHeight(self.frame) - 3)];
    _textfield.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];

	_textfield.keyboardAppearance = UIKeyboardAppearanceDark;

	_textfield.font = [UIFont customTitleExtraLight:20];
	_textfield.textAlignment = NSTextAlignmentLeft;
	_textfield.textColor = [UIColor whiteColor];
    _textfield.adjustsFontSizeToFitWidth = YES;
    _textfield.minimumFontSize = 15;
    
    _textfield.delegate = self;

	NSAttributedString *attributedText = [[NSAttributedString alloc]
	                                      initWithString:NSLocalizedString(placeholder, nil)
	                                          attributes:@{
	                                          NSForegroundColorAttributeName: [UIColor customPlaceholder],
                                                                               NSFontAttributeName: [UIFont customTitleExtraLight:20]
										  }];

	_textfield.attributedPlaceholder = attributedText;
	_textfield.textAlignment = NSTextAlignmentRight;

	[self addSubview:_textfield];
}

- (void)commontInit {
//	FLKeyboardView *inputView = [FLKeyboardView new];
//	[inputView setKeyboardDecimal];
//	inputView.textField = _textfield;
//	_textfield.inputView = inputView;

    if (_dictionary[_dictionaryKey] && ![_dictionary[_dictionaryKey] isBlank])
        _textfield.text = _dictionary[_dictionaryKey];
    
	{
		separatorTop = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame), 1)];
		separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];

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

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
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
