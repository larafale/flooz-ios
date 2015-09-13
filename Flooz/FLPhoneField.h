//
//  FLPhoneField.h
//  Flooz
//
//  Created by Epitech on 9/9/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLCountryPicker.h"

@interface FLPhoneField : UIView <UITextFieldDelegate, FLCountryPickerDelegate> {
    __weak NSMutableDictionary *_dictionary;
    id _target;
    SEL _action;
    
    id _targetTextChange;
    SEL _actionTextChange;
}

@property FLCountry *currentCountry;

@property UITextField *textfield;
@property UIView *bottomBar;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary position:(CGPoint)position;
- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary frame:(CGRect)frame;

- (void)addForNextClickTarget:(id)target action:(SEL)action;

- (void)addForTextChangeTarget:(id)target action:(SEL)action;

- (void)reloadTextField;

- (BOOL)isFirstResponder;
- (BOOL)resignFirstResponder;

@end
