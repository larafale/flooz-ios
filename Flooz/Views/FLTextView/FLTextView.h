//
//  FLTextView.h
//  Flooz
//
//  Created by jonathan on 1/28/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextView : UIView <UITextViewDelegate> {
	__weak NSMutableDictionary *_dictionary;
	NSString *_dictionaryKey;

	UITextView *_textView;
	UILabel *_placeholder;

	UIView *separatorTop;

	CGFloat maxHeight;
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;
- (void)setInputAccessoryView:(UIView *)accessoryView;
- (void)setHeight:(CGFloat)height;
- (void)hideSeparatorTop;
- (void)setInputView:(UIView *)inputView;
- (void)setMaxHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;

@end
