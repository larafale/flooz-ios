//
//  SecureCodeFieldDelegate.h
//  Flooz
//
//  Created by jonathan on 2014-03-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SecureCodeFieldDelegate <NSObject>

- (void)didSecureCodeEnter:(NSString *)secureCode;

@optional
- (void)didPressTouch:(NSString *)secureCode;

@end
