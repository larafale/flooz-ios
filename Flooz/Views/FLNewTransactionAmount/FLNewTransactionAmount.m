//
//  FLNewTransactionAmount.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLNewTransactionAmount.h"

#import "FLKeyboardView.h"

#define HEIGHT 84.
#define MARGE_TOP 12.
#define MARGE_BOTTOM 17.
#define INPUTS_WIDTH 226.
#define FONT_SIZE_MAX 50.

@implementation FLNewTransactionAmount

- (id)initFor:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey
{
    CGRect frame = CGRectMakeSize(SCREEN_WIDTH, [[self class] height]);
    self = [super initWithFrame:frame];
    if (self) {
        _dictionary = dictionary;
        _dictionaryKey = dictionaryKey;
        
        [_dictionary setValue:[NSNumber numberWithFloat:100.] forKey:_dictionaryKey];
        
        [self commontInit];
    }
    return self;
}

+ (CGFloat)height
{
    return 84.;
}

- (void)commontInit
{
    self.clipsToBounds = YES;
    self.layer.borderWidth = 1.;
    self.layer.borderColor = [UIColor customSeparator].CGColor;
    
    currency = [[UILabel alloc] initWithFrame:CGRectMake(5, MARGE_TOP - 2.5, 49, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
    point = [[UILabel alloc] initWithFrame:CGRectMake(0, MARGE_TOP, 0, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
    amount = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(currency.frame), MARGE_TOP, 0, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
    amount2 = [[UITextField alloc] initWithFrame:CGRectMake(0, MARGE_TOP, 0, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
    
    currency.font = [UIFont customTitleThin:55];
    point.font = amount.font = amount2.font = [UIFont customTitleThin:FONT_SIZE_MAX];
    currency.textColor = point.textColor = amount.textColor = amount2.textColor = [UIColor whiteColor];
    amount.tintColor = amount2.tintColor = [UIColor clearColor];
    
    currency.text = NSLocalizedString(@"GLOBAL_EURO", nil);
    currency.textAlignment = NSTextAlignmentCenter;
    
    point.text = @".";
    point.textAlignment = NSTextAlignmentCenter;

    amount.text = @"100";
    amount.textAlignment = NSTextAlignmentCenter;
    amount.delegate = self;
    FLKeyboardView *inputView = [FLKeyboardView new];
    inputView.textField = amount;
    amount.inputView = inputView;
        
    amount2.text = @"00";
    amount2.textAlignment = NSTextAlignmentCenter;
    amount2.delegate = self;
    FLKeyboardView *inputView2 = [FLKeyboardView new];
    inputView2.textField = amount2;
    amount2.inputView = inputView2;
    
    [self addSubview:currency];
    [self addSubview:point];
    [self addSubview:amount];
    [self addSubview:amount2];
    
    [self resizeText];
        
    [amount addTarget:self action:@selector(resizeText) forControlEvents:UIControlEventEditingChanged];
    [amount2 addTarget:self action:@selector(resizeText) forControlEvents:UIControlEventEditingChanged];
}

- (void)resizeText
{
    CGFloat currentFontSize = FONT_SIZE_MAX;
    
    point.font = amount.font = amount2.font = [UIFont customTitleThin:FONT_SIZE_MAX];
    [self resizeInputs];
    
    CGFloat currentInputsWith = CGRectGetWidth(amount.frame) + CGRectGetWidth(point.frame) + CGRectGetWidth(amount2.frame);
    
    while(currentInputsWith > INPUTS_WIDTH){
        currentFontSize--;
        point.font = amount.font = amount2.font = [UIFont customTitleThin:currentFontSize];
        
        [self resizeInputs];
        
        currentInputsWith = CGRectGetWidth(amount.frame) + CGRectGetWidth(point.frame) + CGRectGetWidth(amount2.frame);
    }
}

- (void)resizeInputs
{
    [amount setWidthToFit];
    [point setWidthToFit];
    [amount2 setWidthToFit];

    CGFloat offset = 0;
    CGSize size = [@" " sizeWithAttributes:@{ NSFontAttributeName:amount.font }];
    offset = size.width;
    
    amount.frame = CGRectSetWidth(amount.frame, CGRectGetWidth(amount.frame) + offset + ([amount isEditing] ? 0 : 0));
    point.frame = CGRectSetX(point.frame, CGRectGetMaxX(amount.frame));
    amount2.frame = CGRectSetX(amount2.frame, CGRectGetMaxX(point.frame) + 5);
    amount2.frame = CGRectSetWidth(amount2.frame, CGRectGetWidth(amount2.frame) + offset  + ([amount2 isEditing] ? 0 : 0));
}

- (BOOL)resignFirstResponder
{
    [amount resignFirstResponder];
    [amount2 resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\r"] && textField == amount && amount.text.length > 0){
        return YES;
    }
    if(textField == amount && amount.text.length == 3){
        return NO;
    }
    
    NSCharacterSet *nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet:nonNumbers];
        
    if(r.location != NSNotFound){
        return NO;
    }
    
    if(textField == amount && [textField.text isEqualToString:@"000"]){
        textField.text = string;
        return NO;
    }
    else if(textField == amount2){
        string = [[amount2.text substringWithRange:NSMakeRange(1, 1)] stringByAppendingString:string];
        textField.text = string;
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setBackgroundColor:[UIColor customBlue]];
    
    if(textField == amount){
        textField.text = @"";
    }
    
    [self resizeText];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField setBackgroundColor:[UIColor clearColor]];
    
    if(textField == amount && [textField.text isEqualToString:@""]){
        textField.text = @"0";
        [self resizeInputs];
    }
    
    CGFloat value = [amount.text floatValue];
    value += [amount2.text floatValue] / 100.;
    
    [_dictionary setValue:[NSNumber numberWithFloat:value] forKey:_dictionaryKey];
}

- (void)setInputAccessoryView:(UIView *)accessoryView
{
    amount.inputAccessoryView = amount2.inputAccessoryView = accessoryView;
}

@end
