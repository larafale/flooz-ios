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
@property (nonatomic) Boolean enableAllCaps;

@property (nonatomic) NSInteger maxLenght;

@property (nonatomic, strong, null_unspecified) UIColor *lineSelectedColor;
@property (nonatomic, strong, null_unspecified) UIColor *lineNormalColor;
@property (nonatomic, strong, null_unspecified) UIColor *lineDisableColor;
@property (nonatomic, strong, null_unspecified) UIColor *lineErrorColor;

@property (nonatomic, strong, nonnull) NSMutableDictionary *dictionary;
@property (nonatomic, strong, nonnull) NSString *dictionaryKey;

- (void)reloadTextField;
- (void)setValid:(Boolean)isValid;
- (void)setType:(FLTextFieldType)type;

- (void)addForNextClickTarget:(nonnull id)target action:(nonnull SEL)action;
- (void)addForTextChangeTarget:(nonnull id)target action:(nonnull SEL)action;
- (void)addTextFocusTarget:(nonnull id)instance action:(nonnull SEL)action;

- (void)setDictionary:(nonnull NSMutableDictionary *)dic key:(nonnull NSString *)k;

- (nullable id)initWithPlaceholder:(nonnull NSString *)placeholder for:(nonnull NSMutableDictionary *)dictionary key:(nonnull NSString *)dictionaryKey frame:(CGRect)frame;
- (nullable id)initWithPlaceholder:(nonnull NSString *)placeholder for:(nonnull NSMutableDictionary *)dictionary key:(nonnull NSString *)dictionaryKey position:(CGPoint)position;

@end
