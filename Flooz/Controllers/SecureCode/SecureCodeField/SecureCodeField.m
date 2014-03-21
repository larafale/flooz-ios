//
//  SecureCodeField.m
//  Flooz
//
//  Created by jonathan on 2014-03-18.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "SecureCodeField.h"

@implementation SecureCodeField

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(20, frame.origin.y, 280, 100);
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    for(int i = 0; i < 4; ++i){
        UILabel *label = [self createLabel];
        CGRectSetX(label.frame, i * CGRectGetWidth(self.frame) / 4.);
        [self addSubview:label];
    }
    
    [self clean];
}

- (UILabel *)createLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];
    
    label.layer.borderWidth = 1.;
    label.layer.borderColor = [[UIColor customSeparator] CGColor];
    label.backgroundColor = [UIColor customBackgroundHeader];
    label.font = [UIFont customTitleThin:44];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
}

#pragma mark - FLKeyboardViewDelegate

- (void)keyboardPress:(NSString *)touch
{
    currentValue = [currentValue stringByAppendingString:touch];
    [self reformatLabel];
        
    if(currentLabel < [[self subviews] count] - 1){
        currentLabel++;
    }
    else{
        [_delegate didSecureCodeEnter:currentValue];
    }
}

- (void)keyboardBackwardTouch
{
    UILabel *label = [[self subviews] objectAtIndex:currentLabel];
    
    if([label.text isBlank]){
        if(currentLabel > 0){
            currentLabel--;
            [self keyboardBackwardTouch];
        }
    }
    else{
        currentValue = [currentValue stringByReplacingCharactersInRange:NSMakeRange(currentLabel, 1) withString:@""];
        [self reformatLabel];
    }
}

- (void)reformatLabel
{
    for(int i = 0; i < 4; ++i){
        UILabel *label = [[self subviews] objectAtIndex:i];
        
        if(currentValue.length > 0 && i < currentValue.length - 1){
            label.text = @".";
        }
        else if(currentValue.length > 0 && i == currentValue.length - 1){
            label.text = [currentValue substringWithRange:NSMakeRange(i, 1)];
        }
        else{
            label.text = @"";
        }
    }
}

- (void)clean
{
    for(UILabel *subview in self.subviews){
        subview.text = @"";
    }
    currentValue = @"";
    currentLabel = 0;
}

@end
