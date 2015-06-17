//
//  FLTextView.m
//  Flooz
//
//  Created by olivier on 1/28/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTextView.h"

@implementation FLTextView {
    id targetId;
    SEL targetAction;

    id focusId;
    SEL focusAction;
}

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position {
    self = [super initWithFrame:CGRectMake(0, position.y, SCREEN_WIDTH, 3 * 39)];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        [self setBackgroundColor:[UIColor customBackground]];
        [self createTextView:placeholder];
        [self createTopBar];
        maxHeight = CGFLOAT_MAX;
    }
    return self;
}

- (void)createTextView:(NSString *)placeholder {
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 0, CGRectGetWidth(self.frame) - 20, CGRectGetHeight(self.frame))];
    
    _textView.backgroundColor = [UIColor clearColor];
    _textView.autocorrectionType = UITextAutocorrectionTypeYes;
    _textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _textView.keyboardAppearance = UIKeyboardAppearanceDark;
    _textView.scrollEnabled = YES;
    
    _textView.delegate = self;
    
    _textView.font = [UIFont customContentLight:16];
    _textView.textColor = [UIColor whiteColor];
    
    [self addSubview:_textView];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(placeholder, nil)
                                          attributes:@{
                                                       NSFontAttributeName: [UIFont customContentLight:16],
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];
    
    _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, CGRectGetWidth(_textView.frame), 39)];
    _placeholder.attributedText = attributedText;
    [_textView addSubview:_placeholder];
    
    if (_dictionary[_dictionaryKey] && ![_dictionary[_dictionaryKey] isBlank]) {
        _textView.text = _dictionary[_dictionaryKey];
        _placeholder.hidden = YES;
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(responderContent)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [_textView addGestureRecognizer:gestureRecognizer];
}

- (void)createTopBar {
    separatorTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 1)];
    separatorTop.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:separatorTop];
}

- (void)hideSeparatorTop {
    separatorTop.hidden = YES;
}

#pragma mark - UITextViewDelegate

- (void)addTextChangeTarget:(id)instance action:(SEL)action {
    targetId = instance;
    targetAction = action;
}

- (void)addTextFocusTarget:(id)instance action:(SEL)action {
    focusId = instance;
    focusAction = action;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (focusId) {
        [focusId performSelector:focusAction withObject:nil];
    }

    //	_placeholder.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isBlank]) {
        [_dictionary setValue:nil forKey:_dictionaryKey];
        //		_placeholder.hidden = NO;
    }
    else {
        [_dictionary setValue:textView.text forKey:_dictionaryKey];
    }
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    static const NSUInteger MAX_NUMBER_OF_LINES_ALLOWED = 10;
    
    NSMutableString *t = [NSMutableString stringWithString:textView.text];
    [t replaceCharactersInRange:range withString:text];
    
    // First check for standard '\n' (newline) type characters.
    NSUInteger numberOfLines = 0;
    for (NSUInteger i = 0; i < t.length; i++) {
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:[t characterAtIndex:i]]) {
            numberOfLines++;
        }
    }
    
    if (numberOfLines >= MAX_NUMBER_OF_LINES_ALLOWED)
        return NO;
    
    
    // Now check for word wrapping onto newline.
    NSAttributedString *t2 = [[NSAttributedString alloc]
                              initWithString:[NSMutableString stringWithString:t] attributes:@{ NSFontAttributeName:textView.font }];
    
    __block NSInteger lineCount = 0;
    
    CGFloat maxWidth   = textView.frame.size.width;
    
    NSTextContainer *tc = [[NSTextContainer alloc] initWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    NSLayoutManager *lm = [[NSLayoutManager alloc] init];
    NSTextStorage *ts = [[NSTextStorage alloc] initWithAttributedString:t2];
    [ts addLayoutManager:lm];
    [lm addTextContainer:tc];
    [lm enumerateLineFragmentsForGlyphRange:NSMakeRange(0, lm.numberOfGlyphs)
                                 usingBlock: ^(CGRect rect,
                                               CGRect usedRect,
                                               NSTextContainer *textContainer,
                                               NSRange glyphRange,
                                               BOOL *stop)
     {
         lineCount++;
     }];
    
    return (lineCount <= MAX_NUMBER_OF_LINES_ALLOWED);
}

- (void)textViewDidChange:(UITextView *)textView {
    [self setHeight:_textView.contentSize.height];
    
    if ([textView.text isBlank]) {
        _placeholder.hidden = NO;
        [_dictionary setValue:nil forKey:_dictionaryKey];
    }
    else {
        _placeholder.hidden = YES;
        [_dictionary setValue:textView.text forKey:_dictionaryKey];
    }
    
    CGRect line = [textView caretRectForPosition:
                   textView.selectedTextRange.start];
    CGFloat overflow = line.origin.y + line.size.height - (textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top);
    if (overflow > 0) {
        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
        // Scroll caret to visible area
        CGPoint offset = textView.contentOffset;
        offset.y += overflow + 7; // leave 7 pixels margin
        // Cannot animate with setContentOffset:animated: or caret will not appear
        [UIView animateWithDuration:.2 animations: ^{
            [textView setContentOffset:offset];
        }];
    }
    
    if (targetId) {
        [targetId performSelector:targetAction withObject:nil];
    }
}

- (void)setInputAccessoryView:(UIView *)accessoryView {
    _textView.inputAccessoryView = accessoryView;
}

- (void)setInputView:(UIView *)inputView {
    [_textView resignFirstResponder];
    _textView.inputView = inputView;
    [_textView becomeFirstResponder];
    
    [self setHeight:_textView.contentSize.height];
}

- (BOOL)becomeFirstResponder {
    return [_textView becomeFirstResponder];
}

- (void)setHeight:(CGFloat)height {
    //TODO: don't need to small textview if nothing underneath
    height = maxHeight;
    [super setHeight:height];
    [_textView setHeight:height];
}

- (void)responderContent {
    [self setInputView:nil];
    _textView.keyboardAppearance = UIKeyboardAppearanceDark;
}

- (void)setMaxHeight:(CGFloat)height {
    maxHeight = height;
    
    if (_textView.contentSize.height > CGRectGetHeight(_textView.frame)) {
        if (_textView.contentSize.height < maxHeight) {
            [self setHeight:_textView.contentSize.height];
        }
        else {
            [self setHeight:maxHeight];
        }
    }
    else {
        [self setHeight:maxHeight];
    }
}

- (void)setWidth:(CGFloat)width {
    [super setWidth:width];
    [_textView setWidth:width - 20];
}

@end
