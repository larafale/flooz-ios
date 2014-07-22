//
//  FLHomeTextField.h
//  Flooz
//
//  Created by Jonathan on 22/07/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLHomeTextField : UIView<UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
    
    __weak id _target;
    SEL _action;
}

@property UITextField *textfield;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;

- (void)addForNextClickTarget:(id)target action:(SEL)action;

@end
