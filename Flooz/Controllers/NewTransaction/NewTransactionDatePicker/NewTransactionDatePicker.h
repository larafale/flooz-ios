//
//  NewTransactionDatePicker.h
//  Flooz
//
//  Created by olivier on 2014-03-25.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewTransactionDatePicker : UIView <UITextFieldDelegate> {
	__weak NSMutableDictionary *_dictionary;
	NSString *_dictionaryKey;

	UILabel *_title;
	UITextField *_textfield;
}

- (id)initWithTitle:(NSString *)title for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;
- (void)setInputAccessoryView:(UIView *)accessoryView;

@end
