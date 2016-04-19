//
//  WebViewController.m
//  Flooz
//
//  Created by Olivier on 3/3/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "WebViewController.h"
#import "AppDelegate.h"
#import "3DSecureViewController.h"

@interface WebViewController () {
    UIActivityIndicatorView *loader;
}

@end

@implementation WebViewController

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        if (data && data[@"url"])
            _url = data[@"url"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _webView = [UIWebView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [_webView setDelegate:self];
    [_webView setBackgroundColor:[UIColor customBackgroundHeader]];
    
    [_mainBody addSubview:_webView];
    _webView.opaque = NO;
    
    loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loader.center = _mainBody.center;
    loader.hidden = YES;
    [_mainBody addSubview:loader];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_url && ![_url isBlank]) {
        NSURL *url = [NSURL URLWithString:_url];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (![self isKindOfClass:[Secure3DViewController class]]) {
        loader.hidden = NO;
        [loader startAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (![self isKindOfClass:[Secure3DViewController class]]) {
        loader.hidden = YES;
        [loader stopAnimating];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (![self isKindOfClass:[Secure3DViewController class]]) {
        loader.hidden = YES;
        [loader stopAnimating];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] scheme] isEqual:@"mailto"]) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            [mailComposer setMailComposeDelegate:self];
            [mailComposer.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor] }];
            
            NSURL *url = [request URL];
            NSString *mail = [[url absoluteString] stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
            [mailComposer setToRecipients:@[mail]];
            
            [self presentViewController:mailComposer animated:YES completion: ^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
        }
        else {
            [appDelegate displayMessage:NSLocalizedString(@"ALERT_NO_MAIL_TITLE", nil) content:NSLocalizedString(@"ALERT_NO_MAIL_MESSAGE", nil) style:FLAlertViewStyleInfo time:nil delay:nil];
        }
        return NO;
    }
    return YES;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        if (result == MFMailComposeResultSent) {
            
        }
        else if (result == MFMailComposeResultFailed) {
        }
    }];
}

@end
