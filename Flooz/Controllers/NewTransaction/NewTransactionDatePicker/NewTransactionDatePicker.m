//
//  NewTransactionDatePicker.m
//  Flooz
//
//  Created by jonathan on 2014-03-25.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "NewTransactionDatePicker.h"

@implementation NewTransactionDatePicker

- (id)initWithTitle:(NSString *)title for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position
{
    self = [super initWithFrame:CGRectMake(position.x, position.y, SCREEN_WIDTH - position.x, 41)];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        
        [self createTitle:title];
        [self createTextField:@""];
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
    
    _textfield.font = [UIFont customContentLight:14];
    _textfield.textColor = [UIColor whiteColor];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(placeholder, nil)
                                          attributes:@{
                                                       NSFontAttributeName: [UIFont customContentLight:14],
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];
    
    _textfield.attributedPlaceholder = attributedText;
    _textfield.delegate = self;
    
    {
        UIDatePicker *datePicker = [UIDatePicker new];
        datePicker.backgroundColor = [UIColor whiteColor];
        datePicker.date = [NSDate new];
        datePicker.datePickerMode = UIDatePickerModeDate;
   
        {
            datePicker.minimumDate = [NSDate new];
            
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDateComponents *offsetComponents = [NSDateComponents new];
            [offsetComponents setYear:+1];
            datePicker.maximumDate = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate new] options:0];
        }
        
        [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
        _textfield.inputView = datePicker;
    }
    
    [self addSubview:_textfield];
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
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

-(void)updateTextField:(id)sender
{
    NSDateFormatter *dateFormatterValue = [NSDateFormatter new];
    NSDateFormatter *dateFormatterText = [NSDateFormatter new];
    [dateFormatterValue setDateFormat:@"MM-dd-yyyy"];
    [dateFormatterText setDateFormat:@"dd MMMM yyyy"];
    
    UIDatePicker *picker = (UIDatePicker *)_textfield.inputView;
    _textfield.text = [NSString stringWithFormat:@"%@", [dateFormatterText stringFromDate:picker.date]];
    
    [_dictionary setValue:[dateFormatterValue stringFromDate:picker.date] forKey:_dictionaryKey];
}

- (void)setInputAccessoryView:(UIView *)accessoryView
{
    _textfield.inputAccessoryView = accessoryView;
}

@end