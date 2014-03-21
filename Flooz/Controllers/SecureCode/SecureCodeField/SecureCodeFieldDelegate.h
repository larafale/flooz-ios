//
//  SecureCodeFieldDelegate.h
//  Flooz
//
//  Created by jonathan on 2014-03-18.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SecureCodeFieldDelegate <NSObject>

- (void)didSecureCodeEnter:(NSString *)secureCode;

@end
