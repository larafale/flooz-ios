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

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectSetWidthHeight(frame, SCREEN_WIDTH, HEIGHT);
    self = [super initWithFrame:frame];
    if (self) {
        [self commontInit];
    }
    return self;
}

- (void)commontInit
{
    self.layer.borderWidth = 1.;
    self.layer.borderColor = [UIColor customSeparator].CGColor;
    
    currency = [[UILabel alloc] initWithFrame:CGRectMake(0, MARGE_TOP - 2.5, 49, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
    point = [[UILabel alloc] initWithFrame:CGRectMake(0, MARGE_TOP, 0, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
    amount = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(currency.frame), MARGE_TOP, 0, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
    amount2 = [[UITextField alloc] initWithFrame:CGRectMake(0, MARGE_TOP, 0, HEIGHT - MARGE_TOP - MARGE_BOTTOM)];
    
    currency.font = [UIFont customTitleThin:55];
    point.font = amount.font = amount2.font = [UIFont customTitleThin:FONT_SIZE_MAX];
    currency.textColor = point.textColor = amount.textColor = amount2.textColor = [UIColor whiteColor];
//    amount.tintColor = amount2.tintColor = [UIColor clearColor];
    
    currency.text = @"$";
    currency.textAlignment = NSTextAlignmentCenter;
    
    point.text = @" . ";
    point.textAlignment = NSTextAlignmentCenter;

    amount.text = @"000";
    amount.textAlignment = NSTextAlignmentRight;
    amount.delegate = self;
    FLKeyboardView *inputView = [FLKeyboardView new];
    inputView.textField = amount;
    amount.inputView = inputView;
        
    amount2.text = @"00";
    amount2.textAlignment = NSTextAlignmentLeft;
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
    NSLog(@"resize");
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

    amount.frame = CGRectSetWidth(amount.frame, CGRectGetWidth(amount.frame) + 5 + ([amount isEditing] ? 10 : 0));
    point.frame = CGRectSetX(point.frame, CGRectGetMaxX(amount.frame));
    amount2.frame = CGRectSetX(amount2.frame, CGRectGetMaxX(point.frame) + 5);
    amount2.frame = CGRectSetWidth(amount2.frame, CGRectGetWidth(amount2.frame) + 5  + ([amount2 isEditing] ? 10 : 0));
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet:nonNumbers];
    
    return r.location == NSNotFound;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self resizeText];
}

- (void)setInputAccessoryView:(UIView *)accessoryView
{
    amount.inputAccessoryView = amount2.inputAccessoryView = accessoryView;
}

@end
