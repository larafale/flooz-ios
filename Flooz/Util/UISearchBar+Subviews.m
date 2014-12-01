//
//  UISearchBar+Subviews.m
//  Flooz
//
//  Created by Arnaud on 2014-10-01.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "UISearchBar+Subviews.h"

@implementation UISearchBar (Subviews)

- (UITextField *)retrieveTextField {
	for (UIView *subView in self.subviews) {
		for (UIView *searchView in subView.subviews) {
			// kind of class should not work on iOS 7. But let's hope it will be back on iOS8? Also let's assume that there is only one view which conforms to `UITextInputTraits`
			if ([searchView isKindOfClass:[UITextField class]] || [searchView conformsToProtocol:@protocol(UITextInputTraits)]) {
				return (UITextField *)searchView;
			}
		}
	}
	return nil;
}

@end
