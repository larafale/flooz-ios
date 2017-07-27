//
//  RegisterCreditCardViewController.m
//  Flooz
//
//  Created by Gawen Berger on 07/07/2017.
//  Copyright © 2017 Flooz. All rights reserved.
//

#import "RegisterCreditCardViewController.h"

@interface RegisterCreditCardViewController ()
{
}
@end

@implementation RegisterCreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  UILabel *cbInfos = [[UILabel alloc] initWithText:NSLocalizedString(@"CREDIT_CARD_INFOS", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentCenter numberOfLines:0];
  [cbInfos setLineBreakMode:NSLineBreakByWordWrapping];
  CGRectSetWidth(cbInfos.frame, CGRectGetWidth(self.view.frame) - 15 * 2);
  [cbInfos sizeToFit];
  CGRectSetXY(cbInfos.frame, 15, PPScreenHeight() - 15 - cbInfos.frame.size.height - 125);
  [self.view addSubview:cbInfos];

  UIImageView *cards = [[UIImageView alloc] initWithFrame:CGRectMake(15, cbInfos.frame.origin.y - 80, PPScreenWidth() - (2 * 15), 80)];
  [cards setImage:[UIImage imageNamed:@"cards"]];
  [cards setContentMode:UIViewContentModeScaleAspectFit];
  [self.view addSubview:cards];

  self.title = NSLocalizedString(@"CARD", nil);
  
  _webView.scrollView.scrollEnabled = YES;
  CGRectSetHeight(_webView.frame, cards.frame.origin.y);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [[Flooz sharedInstance] hideLoadView];
  
  [_webView setScalesPageToFit:YES];
  [_webView setBackgroundColor:[UIColor whiteColor]];
  [_webView setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [[Flooz sharedInstance] hideLoadView];
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
  [[Flooz sharedInstance] hideLoadView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  [super webView:webView didFailLoadWithError:error];
  [[Flooz sharedInstance] hideLoadView];
  
  [appDelegate displayMessage:@"Erreur" content:error.localizedDescription style:FLAlertViewStyleError time:@3 delay:@0];
}

@end
