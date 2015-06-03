//
//  FLTextFieldIcon.h
//  Flooz
//
//  Created by olivier on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextFieldIcon : UIView <UITextFieldDelegate> {
	__weak NSMutableDictionary *_dictionary;
	NSString *_dictionaryKey;
	NSString *_dictionaryKey2;

	UIImageView *icon;
	UITextField *_textfield;
	UITextField *_textfield2;

	id _target;
	SEL _action;

	id _targetTextChange;
	SEL _actionTextChange;
}

@property BOOL readOnly;

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2;

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame;

- (id)initWithIcon:(NSString *)iconName placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame placeholder2:(NSString *)placeholder2 key2:(NSString *)dictionaryKey2;

- (void)seTsecureTextEntry:(BOOL)secureTextEntry;

- (void)addForNextClickTarget:(id)target action:(SEL)action;

- (void)addForTextChangeTarget:(id)target action:(SEL)action;

- (void)reloadTextField;

@end
