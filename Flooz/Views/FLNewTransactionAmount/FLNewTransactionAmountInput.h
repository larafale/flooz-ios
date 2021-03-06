//
//  FLNewTransactionAmountInput.h
//  Flooz
//
//  Created by Arnaud on 2014-08-22.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VENCalculatorInputTextField.h"
#import "FLNewTransactionAmountDelegate.h"

@interface FLNewTransactionAmountInput : UIView <UITextFieldDelegate> {
	__weak NSMutableDictionary *_dictionary;
	NSString *_dictionaryKey;

	__weak id _target;
	SEL _action;

	UILabel *currency;

	UIView *buttonsView;

	UIView *separatorTop;
	UIView *separatorBottom;

	BOOL isEmpty;
}

@property VENCalculatorInputTextField *textfield;
@property (weak, nonatomic) id <FLNewTransactionAmountDelegate> delegate;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey currencySymbol:(NSString *)symbol andFrame:(CGRect)frame delegate:(id <FLNewTransactionAmountDelegate> )delegate;
- (void)setInputAccessoryView:(UIView *)accessoryView;

- (void)hideSeparatorTop;
- (void)hideSeparatorBottom;
- (void) disableInput;

@end
