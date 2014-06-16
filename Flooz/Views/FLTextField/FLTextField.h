//
//  FLTextField.h
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextField : UIView<UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
    
//    UITextField *_textfield;
}

@property UITextField *textfield;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;

@end
