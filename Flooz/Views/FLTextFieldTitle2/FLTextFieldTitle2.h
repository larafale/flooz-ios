//
//  FLTextFieldTitle2.h
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextFieldTitle2 : UIView<UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
    
    UILabel *_title;
    UITextField *_textfield;
}

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;

@end
