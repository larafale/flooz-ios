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
    NSString *_appText;
    NSString *_fbData;
    NSDictionary *_mailData;
    NSString *_twitterText;
    NSString *_smsText;
    NSString *_h1;
    NSString *_h2;
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
    [_backImage setContentMode:UIViewContentModeScaleAspectFill];
    
    [_mainBody addSubview:_backImage];
    
    _titleLabel = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customTitleExtraLight:15] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [_titleLabel setUserInteractionEnabled:NO];
    
    [_mainBody addSubview:_titleLabel];
 
    _subtitleLabel = [[UILabel alloc] initWithText:@"" textColor:[UIColor customBlue] font:[UIFont customContentBold:35] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [_subtitleLabel setUserInteractionEnabled:YES];
    [_subtitleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPopover)]];
    
    [_mainBody addSubview:_subtitleLabel];

    _text = [[FLClearActionTextView alloc] initWithFrame:CGRectMake(20, 250, CGRectGetWidth(_mainBody.frame) - 40, 100)];
    [_text setTextColor:[UIColor customWhite]];
    [_text setFont:[UIFont customContentRegular:18]];
    [_text setTextAlignment:NSTextAlignmentCenter];

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
        _h2 = [[Flooz sharedInstance] invitationTexts].shareSubheader;
        
        if (!_code)
            _code = @"";
        
        [self.navigationItem setTitle:_viewTitle];
        
        [_titleLabel setText:_h1];
        [_titleLabel sizeToFit];
        [_titleLabel setCenter:_backImage.center];
        CGRectSetY(_titleLabel.frame, 50);
 
        [_subtitleLabel setText:_h2];
        [_subtitleLabel sizeToFit];
        [_subtitleLabel setCenter:_backImage.center];
        CGRectSetY(_subtitleLabel.frame, CGRectGetMaxY(_titleLabel.frame) + 15);
        
        [_text setText:_appText];
        [_text sizeToFit];
        CGRectSetX(_text.frame, (CGRectGetWidth(_mainBody.frame) - CGRectGetWidth(_text.frame)) / 2);
        
        if (_footerView)
            [_footerView removeFromSuperview];
        
        [self createFooterView];
    
        CGRectSetY(_text.frame, CGRectGetMinY(_footerView.frame) - CGRectGetHeight(_text.frame) - 50);
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
            _h2 = result.shareSubheader;

            if (!_code)
                _code = @"";
            
            [self.navigationItem setTitle:_viewTitle];
            
            [_titleLabel setText:_h1];
            [_titleLabel sizeToFit];
            [_titleLabel setCenter:_backImage.center];
            CGRectSetY(_titleLabel.frame, 50);
            
            [_subtitleLabel setText:_h2];
            [_subtitleLabel sizeToFit];
            [_subtitleLabel setCenter:_backImage.center];
            CGRectSetY(_subtitleLabel.frame, CGRectGetMaxY(_titleLabel.frame) + 15);
            
            [_text setText:_appText];
            [_text sizeToFit];
            CGRectSetX(_text.frame, (CGRectGetWidth(_mainBody.frame) - CGRectGetWidth(_text.frame)) / 2);
            
            if (_footerView)
                [_footerView removeFromSuperview];
            
            [self createFooterView];
            
            CGRectSetY(_text.frame, CGRectGetMinY(_footerView.frame) - CGRectGetHeight(_text.frame) - 50);
            
        } failure:^(NSError *error) {
            
        }];
    }
    [self registerNotification:@selector(showFbConfirmBox) name:kNotificationFbConnect object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    popoverViewController = [ClipboardPopoverViewController new];
    [popoverViewController setPreferredContentSize:CGSizeMake(120, 35)];
    popoverViewController.modalInPopover = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
        [popoverController presentPopoverFromRect:_subtitleLabel.bounds inView:_subtitleLabel permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
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
    if ([[Flooz sharedInstance] facebook_token]) {
        [self showFbConfirmBox];
    }
    else {
        [[Flooz sharedInstance] connectFacebook];
    }
}

- (void)showFbConfirmBox {
    FLPopup *fbPopup = [[FLPopup alloc] initWithMessage:_fbData accept:^{
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] invitationFacebook:nil failure:nil];
    } refuse:^{
        
    }];
    [fbPopup show];
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
