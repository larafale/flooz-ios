//
//  SecureCodeField.h
//  Flooz
//
//  Created by Olivier on 2014-03-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLKeyboardViewDelegate.h"
#import "SecureCodeFieldDelegate.h"

@interface SecureCodeField : UIView <FLKeyboardViewDelegate> {
	NSUInteger currentLabel;
	NSString *currentValue;
	NSArray *dotViews;
}

@property (weak, nonatomic) id <SecureCodeFieldDelegate> delegate;

- (void)clean;

@end
