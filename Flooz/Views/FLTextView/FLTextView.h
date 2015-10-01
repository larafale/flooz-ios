//
//  FLTextView.h
//  Flooz
//
//  Created by olivier on 1/28/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextView : UIView <UITextViewDelegate> {
	__weak NSMutableDictionary *_dictionary;
	NSString *_dictionaryKey;

	UILabel *_placeholder;

	UIView *separatorTop;

	CGFloat maxHeight;
}

@property (nonatomic, retain) UITextView *textView;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;
- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame;
- (void)setInputAccessoryView:(UIView *)accessoryView;
- (void)setHeight:(CGFloat)height;
- (void)hideSeparatorTop;
- (void)setInputView:(UIView *)inputView;
- (void)setWidth:(CGFloat)width;
- (void)addTextChangeTarget:(id)instance action:(SEL)action;
- (void)addTextFocusTarget:(id)instance action:(SEL)action;
- (void)setText:(NSString *)text;

@end
