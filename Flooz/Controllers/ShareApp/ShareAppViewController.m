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
#import "FLSharePopup.h"
#import "ShareSMSViewController.h"
#import "AmbassadorStepsViewController.h"

@interface ShareAppViewController () {
    UIView *_footerView;
    
    UIButton *_shareFB;
    UIButton *_shareTwitter;
    UIButton *_shareSMS;
    UIButton *_shareMail;
    
    UIImageView *_backImage;
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UILabel *_codeLabel;
    
    FLClearActionTextView *_text;
    
    NSString *_code;
    NSArray *_appText;
    NSDictionary *_fbData;
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
    
    _titleLabel = [[UILabel alloc] initWithText:@"" textColor:[UIColor customBlue] font:[UIFont customContentBold:28] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    [_titleLabel setUserInteractionEnabled:NO];
    [_titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    CGRectSetWidth(_titleLabel.frame, CGRectGetWidth(_mainBody.frame) - 20);
    
    [_mainBody addSubview:_titleLabel];
    
    _subtitleLabel = [[UILabel alloc] initWithText:@"" textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    [_subtitleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [_subtitleLabel setUserInteractionEnabled:NO];
    CGRectSetWidth(_subtitleLabel.frame, CGRectGetWidth(_mainBody.frame) - 20);
    [_subtitleLabel setHidden:YES];
    
    [_mainBody addSubview:_subtitleLabel];
    
    _codeLabel = [[UILabel alloc] initWithText:@"" textColor:[UIColor customBlue] font:[UIFont customContentBold:20] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [_codeLabel setUserInteractionEnabled:YES];
    [_codeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPopover)]];
    [_codeLabel setHidden:YES];
    
    [_mainBody addSubview:_codeLabel];
    
    _text = [[FLClearActionTextView alloc] initWithFrame:CGRectMake(20, 250, CGRectGetWidth(_mainBody.frame) - 40, 100)];
    [_text setTextColor:[UIColor customWhite]];
    [_text setFont:[UIFont customContentRegular:16]];
    [_text setTextAlignment:NSTextAlignmentCenter];
    [_text addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPopover)]];
    
    CGRectSetWidth(_text.frame, CGRectGetWidth(_mainBody.frame) - 20);
    
    [_text setEditable:NO];
    [_text setBounces:NO];
    [_text setScrollEnabled:NO];
    [_text setSelectable:NO];
    [_text setBackgroundColor:[UIColor clearColor]];
    
    [_mainBody addSubview:_text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[Flooz sharedInstance] invitationText:^(FLInvitationTexts *result) {
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self prepareViews];
        });
    } failure:^(NSError *error) {
        
    }];
    
    [self registerNotification:@selector(showFbConfirmBox) name:kNotificationFbConnect object:nil];
    [self registerNotification:@selector(reloadShareTexts) name:kNotificationReloadShareTexts object:nil];
}

- (void)reloadShareTexts {
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareViews];
    });
}

- (void)prepareViews {
    if ([[[Flooz sharedInstance] currentUser] isAmbassador]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[[UIImage imageNamed:@"alertview-info"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 20, 20);
        [btn setTintColor:[UIColor customBlue]];
        [btn addTarget:self action:@selector(showStepPopup) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *ambassadorItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        self.navigationItem.rightBarButtonItem = ambassadorItem;
    } else
        self.navigationItem.rightBarButtonItem = nil;
    
    [self.navigationItem setTitle:_viewTitle];
    
    if (_footerView)
        [_footerView removeFromSuperview];
    
    [self createFooterView];
    
    [_codeLabel setText:[NSString stringWithFormat:@"“%@”", _code]];
    [_codeLabel sizeToFit];
    [_codeLabel setCenter:_backImage.center];
    CGRectSetY(_codeLabel.frame, CGRectGetMinY(_footerView.frame) - CGRectGetHeight(_codeLabel.frame) - 25);
    
    [_subtitleLabel setText:_h2];
    [_subtitleLabel setHeightToFit];
    [_subtitleLabel setCenter:_backImage.center];
    CGRectSetY(_subtitleLabel.frame, CGRectGetMinY(_codeLabel.frame) - CGRectGetHeight(_subtitleLabel.frame) - 10);
    
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
    [_text setCenter:_backImage.center];
    CGRectSetY(_text.frame, CGRectGetMinY(_footerView.frame) - CGRectGetHeight(_text.frame) - 60);
    
    [_titleLabel setText:_h1];
    [_titleLabel setHeightToFit];
    [_titleLabel setCenter:_backImage.center];
    //    CGRectSetY(_titleLabel.frame, (CGRectGetHeight(_mainBody.frame) - (CGRectGetHeight(_mainBody.frame) - CGRectGetMinY(_text.frame))) / 2 - CGRectGetHeight(_titleLabel.frame) / 2);
    CGRectSetY(_titleLabel.frame, 80);
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
        popoverController.theme.dimsBackgroundViewsTintColor = NO;
        
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
    if ([_fbData[@"method"] isEqualToString:@"widget"]) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:_fbData[@"link"]];
        content.contentTitle = _fbData[@"name"];
        content.contentDescription = _fbData[@"description"];
        
        [FBSDKShareDialog showFromViewController:self withContent:content delegate:self];
    }
    else {
        if ([[Flooz sharedInstance] facebook_token]) {
            [self showFbConfirmBox];
        }
        else {
            [[Flooz sharedInstance] connectFacebook];
        }
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSURL *fbURL = [NSURL URLWithString:@"fb://root"];
    
    if (![[UIApplication sharedApplication] canOpenURL:fbURL]) {
        if (results[@"postId"] != nil) {
            [[Flooz sharedInstance] sendInvitationMetric:@"facebook"];
        }
    } else {
        [[Flooz sharedInstance] sendInvitationMetric:@"facebook"];
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    
}

- (void)showFbConfirmBox {
    FLSharePopup *fbPopup = [[FLSharePopup alloc] initWithTitle:_fbData[@"title"] placeholder:_fbData[@"placeholder"] accept:^(NSString *data) {
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] invitationFacebook:data success:nil failure:nil];
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
    [[Flooz sharedInstance] grantedAccessToContacts:^(BOOL granted) {
        if (granted) {
            [self.navigationController presentViewController:[[FLNavigationController alloc] initWithRootViewController:[ShareSMSViewController new]] animated:YES completion:nil];
        } else {
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
    }];
}

- (void)showStepPopup {
    AmbassadorStepsViewController *viewController = [AmbassadorStepsViewController new];
    [viewController show];
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
