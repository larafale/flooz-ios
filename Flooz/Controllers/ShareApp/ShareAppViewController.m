//
//  ShareAppViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-09-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "ShareAppViewController.h"

#import "ContactCell.h"
#import "FriendCell.h"
#import "FriendPickerSearchBar.h"
#import "FLUser.h"
#import "ClipboardPopoverViewController.h"
#import "FLClearActionTextView.h"

@interface ShareAppViewController () {
    UIView *_footerView;
    
    UIButton *_shareFB;
    UIButton *_shareTwitter;
    UIButton *_shareSMS;
    UIButton *_shareMail;
    
    UIImageView *_backImage;
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    
    FLClearActionTextView *_text;
    
    NSString *_code;
    NSArray *_appText;
    NSDictionary *_fbData;
    NSDictionary *_mailData;
    NSString *_twitterText;
    NSString *_smsText;
    NSString *_h1;
    NSString *_viewTitle;
    
    WYPopoverController *popoverController;
    ClipboardPopoverViewController *popoverViewController;
}

@end

@implementation ShareAppViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _backImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [_backImage setImage:[UIImage imageNamed:@"back-secure"]];
    [_backImage setContentMode:UIViewContentModeScaleAspectFit];
    
    [_mainBody addSubview:_backImage];
    
    _titleLabel = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentBold:27] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [_titleLabel setUserInteractionEnabled:NO];
    
    [_mainBody addSubview:_titleLabel];
 
    _subtitleLabel = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentBold:27] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [_subtitleLabel setUserInteractionEnabled:YES];
    
    [_mainBody addSubview:_subtitleLabel];

    _text = [[FLClearActionTextView alloc] initWithFrame:CGRectMake(20, 220, CGRectGetWidth(_mainBody.frame) - 40, 100)];
    [_text addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPopover)]];
    
    if (IS_IPHONE_4) {
        CGRectSetY(_text.frame, 200);
    }
    
    [_text setEditable:NO];
    [_text setBounces:NO];
    [_text setScrollEnabled:NO];
    [_text setBackgroundColor:[UIColor clearColor]];
    
    [_mainBody addSubview:_text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[Flooz sharedInstance] invitationTexts]) {
        _code = [[Flooz sharedInstance] invitationTexts].shareCode;
        _appText = [[Flooz sharedInstance] invitationTexts].shareText;
        _fbData = [[Flooz sharedInstance] invitationTexts].shareFb;
        _mailData = [[Flooz sharedInstance] invitationTexts].shareMail;
        _twitterText = [[Flooz sharedInstance] invitationTexts].shareTwitter;
        _smsText = [[Flooz sharedInstance] invitationTexts].shareSms;
        _viewTitle = [[Flooz sharedInstance] invitationTexts].shareTitle;
        _h1 = [[Flooz sharedInstance] invitationTexts].shareHeader;
        
        if (!_code)
            _code = @"";
        
        [self.navigationItem setTitle:_viewTitle];
        
        [_titleLabel setText:_h1];
        [_titleLabel sizeToFit];
        [_titleLabel setCenter:_backImage.center];
        CGRectSetY(_titleLabel.frame, 40);
 
        [_subtitleLabel setText:_h1];
        [_subtitleLabel sizeToFit];
        [_subtitleLabel setCenter:_backImage.center];
        CGRectSetY(_subtitleLabel.frame, CGRectGetMaxY(_titleLabel.frame) + 10);

        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_appText[0]];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor customWhite] range:NSMakeRange(0, text.length)];
        [text addAttribute:NSFontAttributeName value:[UIFont customContentRegular:18] range:NSMakeRange(0, text.length)];
        
        NSMutableAttributedString *code = [[NSMutableAttributedString alloc] initWithString:_code];
        [code addAttribute:NSForegroundColorAttributeName value:[UIColor customBlue] range:NSMakeRange(0, code.length)];
        [code addAttribute:NSFontAttributeName value:[UIFont customContentBold:19] range:NSMakeRange(0, code.length)];
        
        NSMutableAttributedString *text2 = [[NSMutableAttributedString alloc] initWithString:_appText[1]];
        [text2 addAttribute:NSForegroundColorAttributeName value:[UIColor customWhite] range:NSMakeRange(0, text2.length)];
        [text2 addAttribute:NSFontAttributeName value:[UIFont customContentRegular:18] range:NSMakeRange(0, text2.length)];
        
        [text appendAttributedString:code];
        [text appendAttributedString:text2];
        
        [_text setAttributedText:text];
        [_text setTextAlignment:NSTextAlignmentCenter];
        [_text sizeToFit];
        CGRectSetX(_text.frame, (CGRectGetWidth(_mainBody.frame) - CGRectGetWidth(_text.frame)) / 2);
        
        if (_footerView)
            [_footerView removeFromSuperview];
        
        [self createFooterView];
    } else {
        [[Flooz sharedInstance] invitationText:^(FLInvitationTexts *result) {
            _code = result.shareCode;
            _appText = result.shareText;
            _fbData = result.shareFb;
            _mailData = result.shareMail;
            _twitterText = result.shareTwitter;
            _smsText = result.shareSms;
            _viewTitle = result.shareTitle;
            _h1 = result.shareHeader;
            
            if (!_code)
                _code = @"";
            
            [self setTitle:_viewTitle];
            
            [_titleLabel setText:_h1];
            [_titleLabel sizeToFit];
            CGRectSetWidth(_titleLabel.frame, CGRectGetWidth(_titleLabel.frame));
            CGRectSetHeight(_titleLabel.frame, CGRectGetHeight(_titleLabel.frame));
            [_titleLabel setCenter:_backImage.center];
            
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:_appText[0]];
            [text addAttribute:NSForegroundColorAttributeName value:[UIColor customWhite] range:NSMakeRange(0, text.length)];
            [text addAttribute:NSFontAttributeName value:[UIFont customContentRegular:18] range:NSMakeRange(0, text.length)];
            
            NSMutableAttributedString *code = [[NSMutableAttributedString alloc] initWithString:_code];
            [code addAttribute:NSForegroundColorAttributeName value:[UIColor customBlue] range:NSMakeRange(0, code.length)];
            [code addAttribute:NSFontAttributeName value:[UIFont customContentBold:19] range:NSMakeRange(0, code.length)];
            
            NSMutableAttributedString *text2 = [[NSMutableAttributedString alloc] initWithString:_appText[1]];
            [text2 addAttribute:NSForegroundColorAttributeName value:[UIColor customWhite] range:NSMakeRange(0, text2.length)];
            [text2 addAttribute:NSFontAttributeName value:[UIFont customContentRegular:18] range:NSMakeRange(0, text2.length)];
            
            [text appendAttributedString:code];
            [text appendAttributedString:text2];
            
            [_text setAttributedText:text];
            [_text setTextAlignment:NSTextAlignmentCenter];
            [_text sizeToFit];
            CGRectSetX(_text.frame, (CGRectGetWidth(_mainBody.frame) - CGRectGetWidth(_text.frame)) / 2);
            
            if (_footerView)
                [_footerView removeFromSuperview];
            
            [self createFooterView];
        } failure:^(NSError *error) {
            
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    popoverViewController = [ClipboardPopoverViewController new];
    [popoverViewController setPreferredContentSize:CGSizeMake(120, 35)];
    popoverViewController.modalInPopover = NO;
}

- (void)createFooterView {
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_mainBody.frame) - 90, CGRectGetWidth(_mainBody.frame), 80)];
    
    float nbButtons = 0;
    
    if ([self smsAvailable])
        ++nbButtons;
    
    if ([self facebookAvailable])
        ++nbButtons;
    
    if ([self twitterAvailable])
        ++nbButtons;
    
    if ([self mailAvailable])
        ++nbButtons;
    
    float buttonSize = 35;
    float padding = (CGRectGetWidth(_footerView.frame) - (nbButtons * buttonSize)) / (nbButtons + 1);
    float posX = padding;
    
    
    if ([self smsAvailable]) {
        _shareSMS = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareSMS setFrame:CGRectMake(posX, 0, buttonSize, buttonSize)];
        [_shareSMS setImage:[[UIImage imageNamed:@"share_sms"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_shareSMS setTintColor:[UIColor customBlue]];
        [_shareSMS addTarget:self action:@selector(sendWithSMS) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_shareSMS];
        posX += buttonSize + padding;
        
        UILabel *label = [[UILabel alloc] initWithText:NSLocalizedString(@"SHARE_SMS", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleExtraLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        [label setFrame:CGRectMake(CGRectGetMidX(_shareSMS.frame) - (CGRectGetWidth(label.frame) / 2), buttonSize + 10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
        [_footerView addSubview:label];
    }
    
    if ([self facebookAvailable]) {
        _shareFB = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareFB setFrame:CGRectMake(posX, 0, buttonSize, buttonSize)];
        [_shareFB setImage:[[UIImage imageNamed:@"share_facebook"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_shareFB setTintColor:[UIColor customBlue]];
        [_shareFB addTarget:self action:@selector(sendWithFacebook) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_shareFB];
        posX += buttonSize + padding;
        
        UILabel *label = [[UILabel alloc] initWithText:NSLocalizedString(@"SHARE_FACEBOOK", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleExtraLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        [label setFrame:CGRectMake(CGRectGetMidX(_shareFB.frame) - (CGRectGetWidth(label.frame) / 2), buttonSize + 10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
        [_footerView addSubview:label];
    }
    
    if ([self twitterAvailable]) {
        _shareTwitter = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareTwitter setFrame:CGRectMake(posX, 0, buttonSize, buttonSize)];
        [_shareTwitter setImage:[[UIImage imageNamed:@"share_twitter"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_shareTwitter setTintColor:[UIColor customBlue]];
        [_shareTwitter addTarget:self action:@selector(sendWithTwitter) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_shareTwitter];
        posX += buttonSize + padding;
        
        UILabel *label = [[UILabel alloc] initWithText:NSLocalizedString(@"SHARE_TWITTER", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleExtraLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        [label setFrame:CGRectMake(CGRectGetMidX(_shareTwitter.frame) - (CGRectGetWidth(label.frame) / 2), buttonSize + 10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
        [_footerView addSubview:label];
    }
    
    if ([self mailAvailable]) {
        _shareMail = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareMail setFrame:CGRectMake(posX, 0, buttonSize, buttonSize)];
        [_shareMail setImage:[[UIImage imageNamed:@"share_mail"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_shareMail setTintColor:[UIColor customBlue]];
        [_shareMail addTarget:self action:@selector(sendWithMail) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:_shareMail];
        
        UILabel *label = [[UILabel alloc] initWithText:NSLocalizedString(@"SHARE_MAIL", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleExtraLight:14] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        [label setFrame:CGRectMake(CGRectGetMidX(_shareMail.frame) - (CGRectGetWidth(label.frame) / 2), buttonSize + 10, CGRectGetWidth(label.frame), CGRectGetHeight(label.frame))];
        [_footerView addSubview:label];
    }
    
    [_mainBody addSubview:_footerView];
}

- (void)showPopover {
    if (_code && ![_code isBlank]) {
        popoverController = [[WYPopoverController alloc] initWithContentViewController:popoverViewController];
        popoverController.delegate = self;
        
        [popoverController presentPopoverFromRect:_text.bounds inView:_text permittedArrowDirections:WYPopoverArrowDirectionDown animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
            [popoverViewController.button addTarget:self action:@selector(copyCode) forControlEvents:UIControlEventTouchUpInside];
        }];
    }
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

- (BOOL)smsAvailable {
    if (_smsText && ![_smsText isBlank] && [MFMessageComposeViewController canSendText])
        return YES;
    return NO;
}

- (BOOL)mailAvailable {
    if (_mailData && [MFMailComposeViewController canSendMail])
        return YES;
    return NO;
}

- (BOOL)facebookAvailable {
    if (_fbData)
        return YES;
    return NO;
}

- (BOOL)twitterAvailable {
    if (_twitterText && ![_twitterText isBlank] && [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        return YES;
    return NO;
}

- (void)sendWithFacebook {
    if ([FBDialogs canPresentShareDialog]) {
        FBLinkShareParams *params = [[FBLinkShareParams alloc] initWithLink:[NSURL URLWithString:_fbData[@"link"]] name:_fbData[@"name"] caption:_fbData[@"caption"] description:_fbData[@"description"] picture:nil];
        
        [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if(error) {
                // An error occurred, we need to handle the error
            } else {
                [[Flooz sharedInstance] sendInvitationMetric:@"facebook"];
            }
        }];
    } else {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       _fbData[@"name"] , @"name",
                                       _fbData[@"caption"], @"caption",
                                       _fbData[@"description"], @"description",
                                       _fbData[@"link"], @"link",
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
                                                                  [[Flooz sharedInstance] sendInvitationMetric:@"facebook"];
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
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *mySLComposerSheet;
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:_twitterText];
        
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            NSString *output;
            switch (result) {
                case SLComposeViewControllerResultDone:
                    [[Flooz sharedInstance] sendInvitationMetric:@"twitter"];
                    break;
                default:
                    break;
            }
        }];
    }
}

- (void)sendWithMail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *message = [[MFMailComposeViewController alloc] init];
        message.mailComposeDelegate = self;
        
        [message setSubject:_mailData[@"title"]];
        [message setMessageBody:_mailData[@"content"] isHTML:@YES];
        
        [[Flooz sharedInstance] showLoadView];
        message.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:message animated:YES completion:^{
            [[Flooz sharedInstance] hideLoadView];
        }];
    }
}

- (void)sendWithSMS {
    if ([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
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
            [[Flooz sharedInstance] sendInvitationMetric:@"sms"];
        }
        else if (result == MessageComposeResultCancelled) {
            
        }
        else if (result == MessageComposeResultFailed) {
            
        }
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion: ^{
        if (result == MFMailComposeResultSent) {
            [[Flooz sharedInstance] sendInvitationMetric:@"email"];
        }
        else if (result == MFMailComposeResultCancelled) {
            
        }
        else if (result == MFMailComposeResultFailed) {
            
        }
    }];
}

@end
