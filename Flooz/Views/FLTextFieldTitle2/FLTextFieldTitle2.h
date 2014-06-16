//
//  FLTextFieldTitle2.h
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FLTextFieldTitle2Style) {
    FLTextFieldTitle2StyleNormal,
    FLTextFieldTitle2StyleCardNumber,
    FLTextFieldTitle2StyleCardExpire,
    FLTextFieldTitle2StyleCVV,
    FLTextFieldTitle2StyleRIB
};

@interface FLTextFieldTitle2 : UIView<UITextFieldDelegate>{
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
    
    UILabel *_title;
    UITextField *_textfield;
    
    id _target;
    SEL _action;
}

@property (nonatomic) FLTextFieldTitle2Style style;

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;
- (void)reloadData;

- (void)setKeyboardType:(UIKeyboardType)keyboardType;
- (void)seTsecureTextEntry:(BOOL)secureTextEntry;

- (void)addForNextClickTarget:(id)target action:(SEL)action;

@end
