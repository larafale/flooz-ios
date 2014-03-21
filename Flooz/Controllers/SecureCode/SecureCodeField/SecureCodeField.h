//
//  SecureCodeField.h
//  Flooz
//
//  Created by jonathan on 2014-03-18.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLKeyboardViewDelegate.h"
#import "SecureCodeFieldDelegate.h"

@interface SecureCodeField : UIView<FLKeyboardViewDelegate>{
    NSUInteger currentLabel;
    NSString *currentValue;
}

@property (weak, nonatomic) id<SecureCodeFieldDelegate> delegate;

- (void)clean;

@end
