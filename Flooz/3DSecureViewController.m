//
//  3DSecureViewController.m
//  Flooz
//
//  Created by Olivier on 10/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
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
        self.title = NSLocalizedString(@"NAV_3DSECURE", nil);
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_webView setScalesPageToFit:YES];
    [_webView setBackgroundColor:[UIColor whiteColor]];
    [_webView setDelegate:self];
    [_webView loadHTMLString:self.htmlContent baseURL:nil];
}

- (void)dismissViewController {
    [[Flooz sharedInstance] abort3DSecure];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [super webViewDidStartLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
    
    CGSize contentSize = webView.scrollView.contentSize;
    CGSize viewSize = webView.bounds.size;
    
    float rw = viewSize.width / contentSize.width;
    
    webView.scrollView.zoomScale = rw;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [super webView:webView didFailLoadWithError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

@end
