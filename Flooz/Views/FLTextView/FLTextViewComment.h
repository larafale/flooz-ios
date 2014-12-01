//
//  FLTextViewComment.h
//  Flooz
//
//  Created by Arnaud on 2014-10-17.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLViewDelegate.h"

@interface FLTextViewComment : UIView <UITextViewDelegate> {
	__weak NSMutableDictionary *_dictionary;
	NSString *_dictionaryKey;

	UITextView *_textView;
	UILabel *_placeholder;

	CGFloat maxHeight;
}

@property (weak, nonatomic) UIView <FLViewDelegate> *delegate;

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey frame:(CGRect)frame;
- (void)setInputAccessoryView:(UIView *)accessoryView;
- (void)setHeight:(CGFloat)height;
- (void)setInputView:(UIView *)inputView;
- (void)setMaxHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)reload;

@end
