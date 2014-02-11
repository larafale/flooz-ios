//
//  FLTextView.m
//  Flooz
//
//  Created by jonathan on 1/28/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLTextView.h"

@implementation FLTextView

- (id)initWithPlaceholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position
{
    self = [super initWithFrame:CGRectMake(0, position.y, SCREEN_WIDTH, 3 * 39)];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        
        [self createTextView:placeholder];
    }
    return self;
}

- (void)createTextView:(NSString *)placeholder
{
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(14, 0, CGRectGetWidth(self.frame) - 28, CGRectGetHeight(self.frame))];
    
    _textView.backgroundColor = [UIColor clearColor];
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textView.returnKeyType = UIReturnKeyNext;
    
    _textView.delegate = self;
    
    _textView.font = [UIFont customContentLight:14];
    _textView.textColor = [UIColor whiteColor];
    
    [self addSubview:_textView];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(placeholder, nil)
                                          attributes:@{
                                                       NSFontAttributeName: [UIFont customContentLight:14],
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];
    
    _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_textView.frame), 39)];
    _placeholder.attributedText = attributedText;
    [_textView addSubview:_placeholder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _placeholder.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([textView.text isBlank]){
        [_dictionary setValue:nil forKey:_dictionaryKey];
        _placeholder.hidden = NO;
    }else{
        [_dictionary setValue:textView.text forKey:_dictionaryKey];
    }
    [textView resignFirstResponder];
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }else{
        return YES;
    }
}

@end
