//
//  FLTextFieldSignup.h
//  Flooz
//
//  Created by Arnaud on 2014-09-16.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextFieldSignup : UIView <UITextFieldDelegate> {
	__weak NSMutableDictionary *_dictionary;
	NSString *_dictionaryKey;
	NSString *_dictionaryKey2;

	UITextField *_textfield2;

    id _target;
    SEL _action;
    
    id _targetTextChange;
    SEL _actionTextChange;
    
    NSString *_filterDate;
}

@property UITextField *textfield;
@property UIView *bottomBar;

@property BOOL readOnly;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2;

- (void)seTsecureTextEntry:(BOOL)secureTextEntry;

- (void)addForNextClickTarget:(id)target action:(SEL)action;

- (void)addForTextChangeTarget:(id)target action:(SEL)action;

- (void)reloadTextField;
- (void)setPlaceholder:(NSString *)placeholder forTextField:(NSInteger)textfieldID;

- (BOOL)isFirstResponder;
- (BOOL)resignFirstResponder;
- (void)setEnable:(BOOL)enable;
- (void)setTextOfTextField:(NSString *)text;

- (void)setDictionary:(NSMutableDictionary *)dic andKey:(NSString *)k;
- (NSString *)dictionaryKey;

@end
