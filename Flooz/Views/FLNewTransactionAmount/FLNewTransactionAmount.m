//
//  FLNewTransactionAmount.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLNewTransactionAmount.h"
#import "FLKeyboardView.h"

#define HEIGHT 84.
#define MARGE_TOP 12.
#define MARGE_BOTTOM 17.
#define INPUTS_WIDTH 226.
#define FONT_SIZE_MAX 20.

@implementation FLNewTransactionAmount

- (id)initFor:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey {
	return [self initFor:dictionary key:dictionaryKey width:SCREEN_WIDTH delegate:nil];
}

- (id)initFor:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey width:(CGFloat)width delegate:(id <FLNewTransactionAmountDelegate> )delegate {
	CGRect frame = CGRectMakeSize(width, HEIGHT);
	self = [super initWithFrame:frame];
	if (self) {
		_dictionary = dictionary;
		_dictionaryKey = dictionaryKey;

		isEmpty = NO;

		if (![_dictionary objectForKey:_dictionaryKey]) {
			isEmpty = YES;
			[_dictionary setValue:[NSNumber numberWithFloat:100.] forKey:_dictionaryKey];
		}

		_delegate = delegate;
		[self commontInit];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (CGFloat)height {
	return HEIGHT;
}

- (void)commontInit {
	self.clipsToBounds = YES;

	currency = [[UILabel alloc] initWithFrame:CGRectMake(5, MARGE_TOP - 2.5, 49, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
	point = [[UILabel alloc] initWithFrame:CGRectMake(0, MARGE_TOP, 0, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
	amount = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(currency.frame), MARGE_TOP, 0, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
	amount2 = [[UITextField alloc] initWithFrame:CGRectMake(0, MARGE_TOP, 0, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];

	currency.font = [UIFont customTitleThin:25];
	point.font = amount.font = amount2.font = [UIFont customTitleThin:FONT_SIZE_MAX];
	currency.textColor = point.textColor = amount.textColor = amount2.textColor = [UIColor whiteColor];
	amount.tintColor = amount2.tintColor = [UIColor clearColor];

	currency.text = NSLocalizedString(@"GLOBAL_EURO", nil);
	currency.textAlignment = NSTextAlignmentCenter;

	point.text = @".";
	point.textAlignment = NSTextAlignmentCenter;

	amount.text = [NSString stringWithFormat:@"%ld", (long)[[_dictionary objectForKey:_dictionaryKey] integerValue]];
	amount.textAlignment = NSTextAlignmentCenter;
	amount.delegate = self;
	FLKeyboardView *inputView = [FLKeyboardView new];
	inputView.textField = amount;
	amount.inputView = inputView;

	amount2.text = @"00";
	amount2.textAlignment = NSTextAlignmentCenter;
	amount2.delegate = self;
	FLKeyboardView *inputView2 = [FLKeyboardView new];
	inputView2.textField = amount2;
	amount2.inputView = inputView2;
    
	[self addSubview:currency];
	[self addSubview:point];
	[self addSubview:amount];
	[self addSubview:amount2];

	[self resizeText];

	[amount addTarget:self action:@selector(resizeText) forControlEvents:UIControlEventEditingChanged];
	[amount2 addTarget:self action:@selector(resizeText) forControlEvents:UIControlEventEditingChanged];

	if (_delegate) {
		[self createButtonsView];
	}

	{
		separatorTop = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame), 1)];
		UIView *separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT - 1, CGRectGetWidth(self.frame), 1)];

		separatorTop.backgroundColor = separatorBottom.backgroundColor = [UIColor customSeparator];

		[self addSubview:separatorTop];
		[self addSubview:separatorBottom];
	}
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

- (void)resizeText {
	CGFloat currentFontSize = FONT_SIZE_MAX;

	point.font = amount.font = amount2.font = [UIFont customTitleThin:FONT_SIZE_MAX];
	[self resizeInputs];

	CGFloat currentInputsWith = CGRectGetWidth(amount.frame) + CGRectGetWidth(point.frame) + CGRectGetWidth(amount2.frame);

	while (currentInputsWith > INPUTS_WIDTH) {
		currentFontSize--;
		point.font = amount.font = amount2.font = [UIFont customTitleThin:currentFontSize];

		[self resizeInputs];

		currentInputsWith = CGRectGetWidth(amount.frame) + CGRectGetWidth(point.frame) + CGRectGetWidth(amount2.frame);
	}
}

- (void)resizeInputs {
	// Revoir resizeText
	if ([amount.text length] > 3) {
		amount.font = amount2.font = [UIFont customTitleThin:FONT_SIZE_MAX - 4];
	}
	else {
		amount.font = amount2.font = [UIFont customTitleThin:FONT_SIZE_MAX];
	}

	[amount setWidthToFit];
	[point setWidthToFit];
	[amount2 setWidthToFit];

	CGFloat offset = 0;
	CGSize size = [@" " sizeWithAttributes : @{ NSFontAttributeName : amount.font }];
	offset = size.width;

	CGRectSetWidth(amount.frame, CGRectGetWidth(amount.frame) + offset + ([amount isEditing] ? 0 : 0));
	CGRectSetX(point.frame, CGRectGetMaxX(amount.frame) + 4);
	CGRectSetX(amount2.frame, CGRectGetMaxX(point.frame) + 5);
	CGRectSetWidth(amount2.frame, CGRectGetWidth(amount2.frame) + offset  + ([amount2 isEditing] ? 0 : 0));
}

- (BOOL)resignFirstResponder {
	[amount resignFirstResponder];
	[amount2 resignFirstResponder];
	return [super resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([string isEqualToString:@"\r"] && textField.text.length > 0) {
		return YES;
	}

	NSCharacterSet *nonNumbers = [NSCharacterSet decimalDigitCharacterSet];
	NSRange r = [string rangeOfCharacterFromSet:nonNumbers];

	// Si n est pas un nombre
	if (r.location == NSNotFound) {
		return NO;
	}

	// test 1ere fois
	if (textField == amount && isEmpty) {
		isEmpty = NO;
		textField.text = @"";
		return YES;
	}

	// Taille limite
	if (textField == amount && amount.text.length == 4) {
		return NO;
		NSString *cleanCentString = [[textField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
		NSInteger centValue = cleanCentString.integerValue;

		if (string.length > 0) {
			centValue = centValue * 10 + string.integerValue;
		}
		else {
			centValue = centValue / 10;
		}

		NSNumber *formatedValue;
		formatedValue = [[NSNumber alloc] initWithFloat:(float)centValue / 100.0f];
		NSNumberFormatter *_currencyFormatter = [[NSNumberFormatter alloc] init];
		[_currencyFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		textField.text = [_currencyFormatter stringFromNumber:formatedValue];
		return NO;
	}

	// Taille limite sur les centimes alors remplace le premier chiffre
	if (textField == amount2 && amount2.text.length == 2) {
		string = [[textField.text substringWithRange:NSMakeRange(1, 1)] stringByAppendingString:string];
		textField.text = string;
		return NO;
	}

	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[textField setBackgroundColor:[UIColor customBlue]];

//    if(textField == amount){
//        textField.text = @"";
//    }

	[self resizeText];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField setBackgroundColor:[UIColor clearColor]];

	if (textField == amount && [textField.text isBlank]) {
		textField.text = @"0";
		[self resizeInputs];
	}

	if (textField == amount2 && textField.text.length != 2) {
		if ([textField.text isBlank]) {
			textField.text = @"00";
		}
		else {
			textField.text = [textField.text stringByAppendingString:@"0"];
		}

		[self resizeInputs];
	}

	CGFloat value = [amount.text floatValue];
	value += [amount2.text floatValue] / 100.;

	[_dictionary setValue:[NSNumber numberWithFloat:value] forKey:_dictionaryKey];
}

- (void)setInputAccessoryView:(UIView *)accessoryView {
	amount.inputAccessoryView = amount2.inputAccessoryView = accessoryView;
}

#pragma mark -

- (void)didValidTouch {
	[amount resignFirstResponder];
	[amount2 resignFirstResponder];
	[_delegate didAmountValidTouch];
}

- (void)didCancelTouch {
	[amount resignFirstResponder];
	[amount2 resignFirstResponder];
	[_delegate didAmountCancelTouch];
}

- (void)hideSeparatorTop {
	separatorTop.hidden = YES;
}

- (BOOL)becomeFirstResponder {
	return [amount becomeFirstResponder];
}

@end
