//
//  FLSelectAmount.m
//  Flooz
//
//  Created by jonathan on 2/5/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLSelectAmount.h"

@implementation FLSelectAmount

- (id)initWithFrame:(CGRect)frame for:(NSMutableDictionary *)dictionary
{
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, SCREEN_WIDTH, 84)];
    if (self) {
        _dictionary = dictionary;
        
        [self createLabel];
        [self createSeparator];
        [self createButtons];
        
        [self didButtonLeftTouch];
    }
    return self;
}

- (void)createLabel
{
    _title = [[UILabel alloc] initWithFrame:CGRectMake(14, 0, 0, CGRectGetHeight(self.frame) / 2)];
    
    _title.textColor = [UIColor whiteColor];
    _title.text = NSLocalizedString(@"TRANSACTION_AMOUNT_TITLE", nil);
    _title.font = [UIFont customContentRegular:12];
    
    [_title setWidthToFit];
    
    [self addSubview:_title];
}

- (void)createSeparator
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_title.frame) - 1, CGRectGetWidth(self.frame), 1)];
    bottomBar.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:bottomBar];
}

- (void)createButtons
{
    buttonLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) / 2, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
    buttonRight = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(buttonLeft.frame), CGRectGetHeight(self.frame) / 2, CGRectGetWidth(self.frame) / 2, CGRectGetHeight(self.frame) / 2)];
    
    [buttonLeft setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundStatus]] forState:UIControlStateSelected];
    [buttonRight setBackgroundImage:[UIImage imageWithColor:[UIColor customBackgroundStatus]] forState:UIControlStateSelected];
    
    buttonLeft.titleLabel.font = buttonRight.titleLabel.font = [UIFont customContentRegular:13];

//    [buttonLeft setTitleColor:[UIColor customBlueHover] forState:UIControlStateNormal];
//    [buttonRight setTitleColor:[UIColor customBlueHover] forState:UIControlStateNormal];
    [buttonLeft setTitleColor:[UIColor customBlueLight] forState:UIControlStateSelected];
    [buttonRight setTitleColor:[UIColor customBlueLight] forState:UIControlStateSelected];
    
    [buttonLeft setTitle:NSLocalizedString(@"TRANSACTION_AMOUNT_FREE", nil) forState:UIControlStateNormal];
    [buttonRight setTitle:NSLocalizedString(@"TRANSACTION_AMOUNT_FIX", nil) forState:UIControlStateNormal];
    
    [buttonLeft addTarget:self action:@selector(didButtonLeftTouch) forControlEvents:UIControlEventTouchUpInside];
    [buttonRight addTarget:self action:@selector(didButtonRightTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:buttonLeft];
    [self addSubview:buttonRight];
}

- (void)didButtonLeftTouch
{
    if(buttonLeft.selected){
        return;
    }
    
    buttonLeft.selected = YES;
    buttonRight.selected = NO;
    
    [_delegate didAmountFreeSelected];
}

- (void)didButtonRightTouch
{
    if(buttonRight.selected){
        return;
    }
    
    buttonLeft.selected = NO;
    buttonRight.selected = YES;
    
    [_delegate didAmountFixSelected];
}

@end
