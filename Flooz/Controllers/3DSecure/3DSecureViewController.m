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
    [[Flooz sharedInstance] hideLoadView];
}

- (id)init {
    self = [super init];
    if (self) {
        self.isAtSignup = NO;
    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        if (data && data[@"html"])
            self.htmlContent = data[@"html"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_3DSECURE", nil);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[Flooz sharedInstance] hideLoadView];
    
    [_webView setScalesPageToFit:YES];
    [_webView setBackgroundColor:[UIColor whiteColor]];
    [_webView setDelegate:self];
    [_webView loadHTMLString:self.htmlContent baseURL:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[Flooz sharedInstance] hideLoadView];
}

- (void)dismissViewController {
    [[Flooz sharedInstance] abort3DSecure];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [super webViewDidStartLoad:webView];
    [[Flooz sharedInstance] showLoadView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [super webViewDidFinishLoad:webView];
    
    CGSize contentSize = webView.scrollView.contentSize;
    CGSize viewSize = webView.bounds.size;
    
    float rw = viewSize.width / contentSize.width;
    
    webView.scrollView.zoomScale = rw;
    [[Flooz sharedInstance] hideLoadView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [super webView:webView didFailLoadWithError:error];
    [[Flooz sharedInstance] hideLoadView];
    
    [appDelegate displayMessage:@"Erreur" content:error.localizedDescription style:FLAlertViewStyleError time:@3 delay:@0];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

@end
