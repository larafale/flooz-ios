//
//  3DSecureViewController.h
//  Flooz
//
//  Created by Epitech on 10/29/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "WebViewController.h"

@interface Secure3DViewController : WebViewController

+ (Secure3DViewController *)createInstance;
+ (Secure3DViewController *)getInstance;
+ (void)clearInstance;

@property (nonatomic) Boolean isAtSignup;
@property (nonatomic) NSString *htmlContent;

@end
