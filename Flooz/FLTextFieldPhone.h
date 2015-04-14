//
//  FLTextFieldPhone.h
//  Flooz
//
//  Created by Epitech on 2/16/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextFieldPhone : UIView <UITextFieldDelegate> {
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
    NSString *_dictionaryKeyCountry;
    
    id _target;
    SEL _action;
    
    id _targetTextChange;
    SEL _actionTextChange;
    
    NSString *_filterDate;
}

@property UITextField *textfield;
@property UIView *bottomBar;

@property BOOL readOnly;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey  countryKey:(NSString *)dictionaryKeyCountry position:(CGPoint)position;
- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey  countryKey:(NSString *)dictionaryKeyCountry frame:(CGRect)frame;

- (void)addForNextClickTarget:(id)target action:(SEL)action;

- (void)addForTextChangeTarget:(id)target action:(SEL)action;

- (void)reloadTextField;

- (BOOL)isFirstResponder;
- (BOOL)resignFirstResponder;
- (void)setEnable:(BOOL)enable;

- (void)setDictionary:(NSMutableDictionary *)dic key:(NSString *)k andCountryKey:(NSString*)k2;

@end
