//
//  NumPadAppleStyle.m
//  Flooz
//
//  Created by Arnaud on 2014-09-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "NumPadAppleStyle.h"

@implementation NumPadAppleStyle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createNumPad];
    }
    return self;
}

- (void)createNumPad {
    CGFloat xMargin;
    CGFloat yMargin;
    CGFloat offsetX;
	CGFloat offsetY = 0.0f;
	CGFloat sizeButton = 75.0f;

    if (IS_IPHONE_6 || IS_IPHONE_6P)
        sizeButton = 80.0f;
    
    if (IS_IPHONE_4)
        sizeButton = 65.0f;
    
    xMargin = (CGRectGetWidth(self.frame) - (3 * sizeButton)) / 4;
    yMargin = (CGRectGetHeight(self.frame) - (4 * sizeButton)) / 3;
    
    if (xMargin > yMargin)
        xMargin = yMargin;
    else
        yMargin = xMargin;
    
    offsetY = (CGRectGetHeight(self.frame) - (4 * sizeButton) - (3 * yMargin)) / 2;
    offsetX = (CGRectGetWidth(self.frame) - (3 * sizeButton) - (4 * yMargin)) / 2;
    
	for (int l = 1; l <= 3; l++) {
        offsetX = (CGRectGetWidth(self.frame) - (3 * sizeButton) - (4 * yMargin)) / 2 + xMargin;
        
        if (IS_IPHONE_4)
            offsetX = 44.0f;
        
		for (int c = 1; c <= 3; c++) {
			[self addSubview:[self numButton:c + (l - 1) * 3 withX:offsetX Y:offsetY andSize:sizeButton]];

			offsetX += sizeButton + xMargin;
		}
        offsetY += sizeButton + yMargin;
	}
    
    offsetX = (CGRectGetWidth(self.frame) - (3 * sizeButton) - (4 * yMargin)) / 2 + 2 * xMargin + sizeButton;

	[self addSubview:[self numButton:0 withX:offsetX Y:offsetY andSize:sizeButton]];
}

- (UIButton *)numButton:(int)num withX:(CGFloat)x Y:(CGFloat)y andSize:(CGFloat)sizeButton {
	PadButton *b = [PadButton newWithFrame:CGRectMake(x, y, sizeButton, sizeButton)];
	[b setTitle:[NSString stringWithFormat:@"%d", num] forState:UIControlStateNormal];
    [b setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
	[b.titleLabel setFont:[UIFont customContentLight:32]];

	[b.layer setBorderColor:[[UIColor customBlue] colorWithAlphaComponent:0.8f].CGColor];
	[b.layer setBorderWidth:1.0f];
	[b.layer setCornerRadius:CGRectGetWidth(b.frame) / 2.0f];

	[b addTarget:self action:@selector(padPressed:) forControlEvents:UIControlEventTouchUpInside];

	return b;
}

- (void)padPressed:(id)sender {
	UIButton *b = (UIButton *)sender;
	[self.delegate numberPressed:[b.titleLabel.text integerValue]];
}

@end

@implementation PadButton

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];

	if (highlighted) {
		[self setBackgroundColor:[UIColor customBackground]];
		[self.titleLabel setFont:[UIFont customContentRegular:32]];
	}
	else {
		[self setBackgroundColor:[UIColor clearColor]];
		[self.titleLabel setFont:[UIFont customContentLight:32]];
	}
}

@end
