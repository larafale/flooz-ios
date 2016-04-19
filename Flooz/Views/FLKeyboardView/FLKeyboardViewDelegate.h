//
//  FLKeyboardViewDelegate.h
//  Flooz
//
//  Created by Olivier on 2014-03-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLKeyboardViewDelegate <NSObject>

- (void)keyboardPress:(NSString *)touch;
- (void)keyboardBackwardTouch;

@end
