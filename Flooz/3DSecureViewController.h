//
//  3DSecureViewController.h
//  Flooz
//
//  Created by Olivier on 10/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "WebViewController.h"

@interface Secure3DViewController : WebViewController<UIWebViewDelegate>

+ (Secure3DViewController *)createInstance;
+ (Secure3DViewController *)getInstance;
+ (void)clearInstance;

@property (nonatomic) Boolean isAtSignup;
@property (nonatomic) NSString *htmlContent;

@end
