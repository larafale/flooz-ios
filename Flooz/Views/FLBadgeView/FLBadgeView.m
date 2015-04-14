//
//  FLBadgeView.m
//  Flooz
//
//  Created by Arnaud on 2014-10-06.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLBadgeView.h"

@implementation FLBadgeView {
	UILabel *labelNumber;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self createViews];
    }
	return self;
}

- (void)createViews {
	[self createMain];
	[self createLabel];
}

- (void)createMain {
	[self setBackgroundColor:[UIColor customRedBadge]];
	[self.layer setCornerRadius:CGRectGetHeight(self.frame) / 2.0f];
	[self.layer setMasksToBounds:YES];
}

- (void)createLabel {
	labelNumber = [UILabel newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    [labelNumber setTextAlignment:NSTextAlignmentCenter];
	[labelNumber setTextColor:[UIColor whiteColor]];
    [labelNumber setFont:[UIFont customContentRegular:10]];
    [labelNumber setAdjustsFontSizeToFitWidth:YES];

	[self addSubview:labelNumber];
}

- (void)setNumber:(NSNumber *)number {
    self->_number = number;
    dispatch_async(dispatch_get_main_queue(), ^{
        [labelNumber setText:[_number stringValue]];
        [labelNumber setAdjustsFontSizeToFitWidth:YES];
    });
}

@end
