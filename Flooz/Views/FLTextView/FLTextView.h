//
//  FLTextView.h
//  Flooz
//
//  Created by jonathan on 1/28/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextView : UIView<UITextViewDelegate>{
    __weak NSMutableDictionary *_dictionary;
    NSString *_dictionaryKey;
    
    UITextView *_textView;
    UILabel *_placeholder;
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;
- (void)setInputAccessoryView:(UIView *)accessoryView;

@end
