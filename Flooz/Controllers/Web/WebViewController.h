//
//  WebViewController.h
//  Flooz
//
//  Created by olivier on 3/3/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MessageUI/MFMailComposeViewController.h>

@interface WebViewController : BaseViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate> {
    UIWebView *_webView;
}

@property (strong, nonatomic) NSString *url;

@end
