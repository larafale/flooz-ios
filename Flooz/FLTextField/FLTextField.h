//
//  FLTextField.h
//  Flooz
//
//  Created by Olive on 1/5/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <UIFloatLabelTextField/UIFloatLabelTextField.h>

typedef NS_ENUM(NSInteger, FLTextFieldType) {
    FLTextFieldTypeDate,
    FLTextFieldTypeNumber,
    FLTextFieldTypeFloatNumber,
    FLTextFieldTypeText,
    FLTextFieldTypePassword,
    FLTextFieldTypeEmail,
    FLTextFieldTypeURL
};

@interface FLTextField : UIFloatLabelTextField<UITextFieldDelegate> {
    FLTextFieldType type;
}

@property (nonatomic) Boolean readOnly;

@property (nonatomic) NSInteger maxLenght;

@property (nonatomic, strong) UIColor *lineSelectedColor;
@property (nonatomic, strong) UIColor *lineNormalColor;
@property (nonatomic, strong) UIColor *lineDisableColor;
@property (nonatomic, strong) UIColor *lineErrorColor;

@property (nonatomic, weak) NSMutableDictionary *dictionary;
@property (nonatomic, strong) NSString *dictionaryKey;

- (void)reloadTextField;
- (void)setValid:(Boolean)isValid;
- (void)setType:(FLTextFieldType)type;

- (void)addForNextClickTarget:(id)target action:(SEL)action;
- (void)addForTextChangeTarget:(id)target action:(SEL)action;

- (void)setDictionary:(nonnull NSMutableDictionary *)dic key:(nonnull NSString *)k;

- (nullable id)initWithPlaceholder:(nonnull NSString *)placeholder for:(nonnull NSMutableDictionary *)dictionary key:(nonnull NSString *)dictionaryKey frame:(CGRect)frame;
- (nullable id)initWithPlaceholder:(nonnull NSString *)placeholder for:(nonnull NSMutableDictionary *)dictionary key:(nonnull NSString *)dictionaryKey position:(CGPoint)position;

@end
