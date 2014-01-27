//
//  FLTextField.h
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextField : UIView<UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionnary;
    __weak NSString *_dictionnaryKey;
    
    UITextField *_textfield;
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionnary key:(NSString *)dictionnaryKey position:(CGPoint)position;

@end
