//
//  NumPadAppleStyle.m
//  Flooz
//
//  Created by Arnaud on 2014-09-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "NumPadAppleStyle.h"

@implementation NumPadAppleStyle

- (id)initWithHeight:(CGFloat)height {
	self = [super initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, height)];
	if (self) {
		[self createNumPad];
	}
	return self;
}

- (void)createNumPad {
	CGFloat offsetX;
	CGFloat offsetY = 0.0f;
	CGFloat sizeButton = 74.5f;

    if (IS_IPHONE4)
        sizeButton = 63.0f;
    
	for (int l = 1; l <= 3; l++) {
		offsetX = 27.5;
        
        if (IS_IPHONE4)
            offsetX = 44.0f;
        
		for (int c = 1; c <= 3; c++) {
			[self addSubview:[self numButton:c + (l - 1) * 3 withX:offsetX Y:offsetY andSize:sizeButton]];

			offsetX += sizeButton + 20.0f;
		}
		offsetY += CGRectGetWidth(self.frame) / 3.0f - 20.0f;
		if (IS_IPHONE4) {
			offsetY -= 5.0f;
		}
	}
	offsetX = 27.5f + sizeButton + 20.0f;
    if (IS_IPHONE4)
        offsetX = 44.0f + sizeButton + 20.0f;

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
