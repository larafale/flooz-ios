//
//  WebViewRequestResultController.h
//  Flooz
//
//  Created by Gawen Berger on 11/07/2017.
//  Copyright © 2017 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface WebViewRequestResultController : BaseViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate> {
  UIWebView *_webView;
}

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *method;
@property (strong, nonatomic) NSDictionary *params;

@end
