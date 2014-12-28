//
//  ShareAppViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-09-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "ShareAppViewController.h"

#import "FLStartItem.h"
#import "ContactCell.h"
#import "FriendCell.h"
#import "FriendPickerSearchBar.h"
#import "FLUser.h"
#import "ClipboardPopoverViewController.h"
#import "FLClearActionTextView.h"

@interface ShareAppViewController () {
    UIView *_footerView;
    UIView *_mainBody;
    
    UIButton *_shareFB;
    UIButton *_shareTwitter;
    UIButton *_shareSMS;
    UIButton *_shareMail;
    
    UIImageView *_backImage;
    
    UILabel *_codeLabel;
    
    FLClearActionTextView *_text;
    
    NSString *_code;
    NSString *_appText;
    NSString *_mailText;
    NSString *_fbDecription;
    NSString *_fbName;
    NSString *_fbLink;
    NSString *_fbCaption;
    NSString *_fbMessage;
    NSString *_twitterText;
    NSString *_smsText;
    NSString *_mailObject;
    
    WYPopoverController *popoverController;
    ClipboardPopoverViewController *popoverViewController;
}

@end

@implementation ShareAppViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"ACCOUNT_BUTTON_INVITE", @"");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(_headerView.frame) + STATUSBAR_HEIGHT, PPScreenWidth(), PPScreenHeight() - CGRectGetHeight(_headerView.frame) - STATUSBAR_HEIGHT)];
    _mainBody.backgroundColor = [UIColor customBackgroundHeader];
    [self.view addSubview:_mainBody];
    
    _backImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(_mainBody.frame) - 40, 200)];
    [_backImage setImage:[[UIImage imageNamed:@"people"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_backImage setTintColor:[UIColor customBlue]];
    [_backImage setContentMode:UIViewContentModeScaleAspectFit];
    
    [_mainBody addSubview:_backImage];
    
    _codeLabel = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentBold:30] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [_codeLabel setUserInteractionEnabled:YES];
    [_codeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPopover)]];

    [_mainBody addSubview:_codeLabel];
    
    _text = [[FLClearActionTextView alloc] initWithFrame:CGRectMake(20, 220, CGRectGetWidth(_mainBody.frame) - 40, 100)];
    
    if (IS_IPHONE4) {
        CGRectSetY(_text.frame, 200);
    }
    
    [_text setEditable:NO];
    [_text setBounces:NO];
    [_text setScrollEnabled:NO];
    [_text setBackgroundColor:[UIColor clearColor]];
    
    [_mainBody addSubview:_text];
    
    [self createFooterView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[Flooz sharedInstance] invitationStrings:^(NSDictionary *result) {
        _code = result[@"item"][@"code"];
        _appText = result[@"item"][@"app"];
        _mailText = result[@"item"][@"mail"][@"content"];
        _fbMessage = result[@"item"][@"facebook"][@"message"];
        _fbName = result[@"item"][@"facebook"][@"name"];
        _fbDecription = result[@"item"][@"facebook"][@"description"];
        _fbCaption = result[@"item"][@"facebook"][@"caption"];
        _fbLink = result[@"item"][@"facebook"][@"link"];
        _twitterText = result[@"item"][@"twitter"];
        _smsText = result[@"item"][@"sms"];
        _mailObject = result[@"item"][@"mail"][@"title"];
        
        if (!_code)
            _code = @"";
        
        [_codeLabel setText:_code];
        [_codeLabel sizeToFit];
        CGRectSetWidth(_codeLabel.frame, CGRectGetWidth(_codeLabel.frame) + 10);
        CGRectSetHeight(_codeLabel.frame, CGRectGetHeight(_codeLabel.frame) + 5);
        [_codeLabel setCenter:_backImage.center];
        [_codeLabel setBackgroundColor:[UIColor customBackgroundHeader]];
        _codeLabel.layer.masksToBounds = YES;
        _codeLabel.layer.cornerRadius = 2;
        
        [_text setText:_appText];
        [_text setTextColor:[UIColor whiteColor]];
        [_text setTextAlignment:NSTextAlignmentCenter];
        [_text setFont:[UIFont customContentRegular:18]];
        [_text sizeToFit];
        CGRectSetX(_text.frame, (CGRectGetWidth(_mainBody.frame) - CGRectGetWidth(_text.frame)) / 2);
        
    } failure:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    popoverViewController = [ClipboardPopoverViewController new];
    [popoverViewController setPreferredContentSize:CGSizeMake(120, 35)];
    popoverViewController.modalInPopover = NO;
}

- (void)createFooterView {
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_mainBody.frame) - 90, CGRectGetWidth(_mainBody.frame), 80)];
    
    float buttonSize = 35;
    float padding = (CGRectGetWidth(_footerView.frame) - (4 * buttonSize)) / 5;
    float posX = padding;
    
    _shareSMS = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareSMS setFrame:CGRectMake(posX, 0, buttonSize, buttonSize)];
    [_footerView addSubview:_shareSMS];
    posX += buttonSize + padding;
    
    _shareFB = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareFB setFrame:CGRectMake(posX, 0, buttonSize, buttonSize)];
    [_footerView addSubview:_shareFB];
    posX += buttonSize + padding;
    
    _shareTwitter = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareTwitter setFrame:CGRectMake(posX, 0, buttonSize, buttonSize)];
    [_footerView addSubview:_shareTwitter];
    posX += buttonSize + padding;
    
    _shareMail = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareMail setFrame:CGRectMake(posX, 0, buttonSize, buttonSize)];
    [_footerView addSubview:_shareMail];
    
    UIImage *image;
    
    image = [[UIImage imageNamed:@"share_sms"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_shareSMS setImage:image forState:UIControlStateNormal];
    
    image = [[UIImage imageNamed:@"share_facebook"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_shareFB setImage:image forState:UIControlStateNormal];
    
    image = [[UIImage imageNamed:@"share_twitter"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_shareTwitter setImage:image forState:UIControlStateNormal];
    
    image = [[UIImage imageNamed:@"share_mail"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_shareMail setImage:image forState:UIControlStateNormal];
    
    [_shareSMS setTintColor:[UIColor customBlue]];
    [_shareFB setTintColor:[UIColor customBlue]];
    [_shareTwitter setTintColor:[UIColor customBlue]];
    [_shareMail setTintColor:[UIColor customBlue]];
    
    [_shareSMS addTarget:self action:@selector(sendWithSMS) forControlEvents:UIControlEventTouchUpInside];
    [_shareFB addTarget:self action:@selector(sendWithFacebook) forControlEvents:UIControlEventTouchUpInside];
    [_shareTwitter addTarget:self action:@selector(sendWithTwitter) forControlEvents:UIControlEventTouchUpInside];
    [_shareMail addTarget:self action:@selector(sendWithMail) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label;
    
    label = [[UILabel alloc] initWithText:NSLocalizedString(@"SHARE_SMS", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleExtraLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [label setFrame:CGRectMake(CGRectGetMidX(_shareSMS.frame) - (CGRectGetWidth(label.frame) / 2), buttonSize + 10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
    [_footerView addSubview:label];
    
    label = [[UILabel alloc] initWithText:NSLocalizedString(@"SHARE_FACEBOOK", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleExtraLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [label setFrame:CGRectMake(CGRectGetMidX(_shareFB.frame) - (CGRectGetWidth(label.frame) / 2), buttonSize + 10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
    [_footerView addSubview:label];
    
    label = [[UILabel alloc] initWithText:NSLocalizedString(@"SHARE_TWITTER", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleExtraLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [label setFrame:CGRectMake(CGRectGetMidX(_shareTwitter.frame) - (CGRectGetWidth(label.frame) / 2), buttonSize + 10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
    [_footerView addSubview:label];
    
    label = [[UILabel alloc] initWithText:NSLocalizedString(@"SHARE_MAIL", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleExtraLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [label setFrame:CGRectMake(CGRectGetMidX(_shareMail.frame) - (CGRectGetWidth(label.frame) / 2), buttonSize + 10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
    [_footerView addSubview:label];
    
    [_mainBody addSubview:_footerView];
}


- (void)showPopover {
    popoverController = [[WYPopoverController alloc] initWithContentViewController:popoverViewController];
    popoverController.delegate = self;
    
    [popoverController presentPopoverFromRect:_codeLabel.bounds inView:_codeLabel permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
        [popoverViewController.button addTarget:self action:@selector(copyCode) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)copyCode {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:_code];
    [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale];
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)sendWithFacebook {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewController *mySLComposerSheet;
        
        mySLComposerSheet = [[SLComposeViewController alloc] init];
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:_fbMessage];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = @"Action Cancelled";
                    break;
                case SLComposeViewControllerResultDone:
                    output = @"Post Successfull";
                    break;
                default:
                    break;
            }
        }];
    } else if ([FBDialogs canPresentShareDialog]) {
        FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:[NSURL URLWithString:_fbLink] name:_fbName caption:@"www.flooz.me" description:_fbDecription picture:nil];
        
        [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if(error) {
                // An error occurred, we need to handle the error
            } else {
                // Success
            }
        }];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       _fbName , @"name",
                                       _fbCaption, @"caption",
                                       _fbDecription, @"description",
                                       _fbLink, @"link",
                                       nil];
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          NSLog(@"Error publishing story: %@", error.description);
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              NSLog(@"User cancelled.");
                                                          } else {
                                                              NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                              
                                                              if (![urlParams valueForKey:@"post_id"]) {
                                                                  NSLog(@"User cancelled.");
                                                                  
                                                              } else {
                                                                  NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                                  NSLog(@"result %@", result);
                                                              }
                                                          }
                                                      }
                                                  }];
    }
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

- (void)sendWithTwitter {
    SLComposeViewController *mySLComposerSheet;
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        mySLComposerSheet = [[SLComposeViewController alloc] init];
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:_twitterText];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output = @"Action Cancelled";
                break;
            case SLComposeViewControllerResultDone:
                output = @"Post Successfull";
                break;
            default:
                break;
        }
    }];
}

- (void)sendWithMail {
    MFMailComposeViewController *message = [[MFMailComposeViewController alloc] init];
    message.mailComposeDelegate = self;
    
    [message setSubject:_mailObject];
    [message setMessageBody:_mailText isHTML:@YES];
    
    [[Flooz sharedInstance] showLoadView];
    message.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:message animated:YES completion:^{
        [[Flooz sharedInstance] hideLoadView];
    }];
}

- (void)sendWithSMS {
    MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        message.messageComposeDelegate = self;
        
        [message setBody:_smsText];
        
        [[Flooz sharedInstance] showLoadView];
        message.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:message animated:YES completion:^{
            [[Flooz sharedInstance] hideLoadView];
        }];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion: ^{
        if (result == MessageComposeResultSent) {
            
        }
        else if (result == MessageComposeResultCancelled) {
            
        }
        else if (result == MessageComposeResultFailed) {
            
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion: ^{
        if (result == MessageComposeResultSent) {
            
        }
        else if (result == MessageComposeResultCancelled) {
            
        }
        else if (result == MessageComposeResultFailed) {
            
        }
    }];
}

@end
