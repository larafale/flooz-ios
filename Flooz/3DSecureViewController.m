//
//  3DSecureViewController.m
//  Flooz
//
//  Created by Epitech on 10/29/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "3DSecureViewController.h"

static Secure3DViewController *instance = nil;

@implementation Secure3DViewController

@synthesize isAtSignup;

+ (Secure3DViewController *)createInstance {
    if (!instance)
        instance = [Secure3DViewController new];
    return instance;
}

+ (Secure3DViewController *)getInstance {
    return instance;
}

+ (void)clearInstance {
    instance = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        self.isAtSignup = NO;
        self.showCross = YES;
        self.title = NSLocalizedString(@"NAV_3DSECURE", nil);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_webView setScalesPageToFit:YES];
    [_webView setBackgroundColor:[UIColor whiteColor]];
    [_webView loadHTMLString:self.htmlContent baseURL:nil];
}

- (void)dismissViewController {
    [[Flooz sharedInstance] abort3DSecure];
}

@end
