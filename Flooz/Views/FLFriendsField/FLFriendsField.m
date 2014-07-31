//
//  FLFriendsField.m
//  Flooz
//
//  Created by Jonathan on 31/07/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLFriendsField.h"

#import "FriendPickerViewController.h"

@implementation FLFriendsField

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, SCREEN_WIDTH - position.x, 41)];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        
        [self createTitle:title];
        [self createTextField:placeholder];
        [self createButton];
        [self createBottomBar];
    }
    return self;
}

- (void)createTitle:(NSString *)title
{
    _title = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 0, CGRectGetHeight(self.frame))];
    
    _title.textColor = [UIColor whiteColor];
    _title.text = NSLocalizedString(title, nil);
    _title.font = [UIFont customContentRegular:12];
    
    [_title setWidthToFit];
    
    [self addSubview:_title];
}

- (void)createTextField:(NSString *)placeholder
{
    _textfield = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_title.frame) + 8, 1, CGRectGetWidth(self.frame) - CGRectGetMaxX(_title.frame) - 18, CGRectGetHeight(self.frame))];
    
    _textfield.autocorrectionType = UITextAutocorrectionTypeNo;
    _textfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textfield.returnKeyType = UIReturnKeyNext;
    
    _textfield.delegate = self;
    
    _textfield.font = [UIFont customContentLight:14];
    _textfield.textColor = [UIColor whiteColor];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(placeholder, nil)
                                          attributes:@{
                                                       NSFontAttributeName: [UIFont customContentLight:14],
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];
    
    _textfield.attributedPlaceholder = attributedText;
    
    [self addSubview:_textfield];
}

- (void)createButton
{
    CGFloat size = 20;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - size - 10, (CGRectGetHeight(self.frame) - size) / 2., size, size)];
    
    [button setBackgroundImage:[UIImage imageNamed:@"friends-field-add"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(didAddButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
}

- (void)createBottomBar
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    bottomBar.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:bottomBar];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updateDictionary];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateDictionary];
    [textField resignFirstResponder];
}

- (void)setInputAccessoryView:(UIView *)accessoryView
{
    _textfield.inputAccessoryView = accessoryView;
}

#pragma mark - Friends Controller

- (void)didAddButtonTouch
{
    _dictionaryForFriendController = [NSMutableDictionary new];
    
    FriendPickerViewController *controller = [FriendPickerViewController new];
    [controller setDictionary:_dictionaryForFriendController];
    [_delegate presentViewController:controller animated:YES completion:NULL];
}

- (void)reloadData
{
    if(_dictionaryForFriendController && [_dictionaryForFriendController objectForKey:@"to"]){
        NSString *text = [_dictionaryForFriendController objectForKey:@"to"];
        
        if([_textfield.text isBlank]){
            _textfield.text = text;
        }
        else{
            _textfield.text = [_textfield.text stringByAppendingString:[NSString stringWithFormat:@",%@", text]];
        }
        
        _dictionaryForFriendController = nil;
        [self updateDictionary];
    }
}

#pragma mark - Data

- (void)updateDictionary
{
    NSArray *data = [[[_textfield text] stringByReplacingOccurrencesOfString:@" " withString:@""]componentsSeparatedByString:@","];
    [_dictionary setValue:data forKey:_dictionaryKey];
}

@end
