//
//  FLNewTransactionAmountInput.h
//  Flooz
//
//  Created by Arnaud on 2014-08-22.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLNewTransactionAmountDelegate.h"

@interface FLNewTransactionAmountInput : UIView <UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
    
    __weak id _target;
    SEL _action;
    
    UILabel *currency;
    
    UIView *buttonsView;
    
    UIView *separatorTop;
    
    BOOL isEmpty;
}

@property UITextField *textfield;
@property (weak, nonatomic) id<FLNewTransactionAmountDelegate> delegate;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey currencySymbol:(NSString *)symbol andFrame:(CGRect)frame delegate:(id<FLNewTransactionAmountDelegate>)delegate;
- (void)setInputAccessoryView:(UIView *)accessoryView;

- (void)hideSeparatorTop;

@end
