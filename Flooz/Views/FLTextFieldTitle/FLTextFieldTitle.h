//
//  FLTextFieldTitle.h
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextFieldTitle : UIView<UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionnary;
    __weak NSString *_dictionnaryKey;
    
    UILabel *_title;
    UITextField *_textfield;
}

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionnary key:(NSString *)dictionnaryKey position:(CGPoint)position;

@end
