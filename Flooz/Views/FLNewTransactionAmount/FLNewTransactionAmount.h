//
//  FLNewTransactionAmount.h
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLNewTransactionAmount : UIView<UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
    
    UILabel *currency;
    UILabel *point;
    
    UITextField *amount;
    UITextField *amount2;
}

+ (CGFloat)height;

- (id)initFor:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey;
- (void)setInputAccessoryView:(UIView *)accessoryView;

@end
