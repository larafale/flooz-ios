//
//  WebViewController.m
//  Flooz
//
//  Created by jonathan on 3/3/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = _webView.backgroundColor = [UIColor customBackground];
    _webView.opaque = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSURL *url = [NSURL URLWithString:_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[Flooz sharedInstance] showLoadView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[Flooz sharedInstance] hideLoadView];
}

@end
