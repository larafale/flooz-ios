//
//  UIView+FindFirstResponder.m
//  Flooz
//
//  Created by jonathan on 2014-03-14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "UIView+FindFirstResponder.h"

@implementation UIView (FindFirstResponder)

- (UIView *)findFirstResponder {
	if (self.isFirstResponder) {
		return self;
	}

	for (UIView *subview in self.subviews) {
		UIView *firstResponder = [subview findFirstResponder];
		if (firstResponder) {
			return firstResponder;
		}
	}

	return nil;
}

@end
