//
//  FLNewTransactionAmount.h
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLNewTransactionAmountDelegate.h"

@interface FLNewTransactionAmount : UIView<UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
    
    UILabel *currency;
    UILabel *point;
    
    UITextField *amount;
    UITextField *amount2;
    
    UIView *buttonsView;
    
    UIView *separatorTop;
}

+ (CGFloat)height;

- (id)initFor:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey;
- (id)initFor:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey width:(CGFloat)width delegate:(id<FLNewTransactionAmountDelegate>)delegate;

- (void)setInputAccessoryView:(UIView *)accessoryView;

@property (weak, nonatomic) id<FLNewTransactionAmountDelegate> delegate;

- (void)hideSeparatorTop;

@end
