//
//  InviteFriendsViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-09-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "FLStartItem.h"
#import "ContactCell.h"
#import "FriendCell.h"

@interface InviteFriendsViewController () {
    
    UIView *_footerView;
    UIView *_mainBody;
    
    UIButton *_shareFB;
    UIButton *_shareTwitter;
    UIButton *_shareSMS;
    UIButton *_shareMail;
}

@end

@implementation InviteFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Friends", @"");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight() - PPStatusBarHeight() - CGRectGetHeight(self.navigationController.navigationBar.frame))];
    [self.view addSubview:_mainBody];
    
}

- (void)createFooterView {
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_mainBody.frame) - 30, PPScreenWidth(), 30)];
    [_mainBody addSubview:_footerView];
    
    float padding = (CGRectGetWidth(_footerView.frame) - (4 * 30)) / 7;
    
    float posX = padding * 2;
    
    _shareSMS = [[UIButton alloc] initWithFrame:CGRectMake(posX, 0, 30, 30)];
    [_footerView addSubview:_shareSMS];
    posX += 30 + padding;
    
    _shareFB = [[UIButton alloc] initWithFrame:CGRectMake(posX, 0, 30, 30)];
    [_footerView addSubview:_shareFB];
    posX += 30 + padding;
    
    _shareTwitter = [[UIButton alloc] initWithFrame:CGRectMake(posX, 0, 30, 30)];
    [_footerView addSubview:_shareTwitter];
    posX += 30 + padding;
    
    _shareMail = [[UIButton alloc] initWithFrame:CGRectMake(posX, 0, 30, 30)];
    [_footerView addSubview:_shareMail];
    
    [_shareSMS setImage:[UIImage imageNamed:@"share_sms"] forState:UIControlStateNormal];
    [_shareFB setImage:[UIImage imageNamed:@"share_facebook"] forState:UIControlStateNormal];
    [_shareTwitter setImage:[UIImage imageNamed:@"share_twitter"] forState:UIControlStateNormal];
    [_shareMail setImage:[UIImage imageNamed:@"share_e-mail"] forState:UIControlStateNormal];
}

- (void)inviteFriends {
    //	MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
    //	if ([MFMessageComposeViewController canSendText]) {
    //		message.messageComposeDelegate = self;
    //
    //		NSMutableArray *listOfPhone = [NSMutableArray new];
    //		for (NSDictionary *contact in _contactToInvite) {
    //			for (NSString *phone in contact[@"phones"]) {
    //				[listOfPhone addObject:phone];
    //			}
    //		}
    //		[message setRecipients:listOfPhone];
    //		NSString *textMessage = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Invite_Friends_Message_SMS", @""), [[[Flooz sharedInstance] currentUser] invitCode]];
    //		[message setBody:textMessage];
    //
    //		message.modalPresentationStyle = UIModalPresentationPageSheet;
    //		[self presentViewController:message animated:YES completion:nil];
    //	}
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    //	[self dismissViewControllerAnimated:YES completion: ^{
    //	    if (result == MessageComposeResultSent) {
    //	        [_contactInfoArray removeObjectsInArray:_contactToInvite];
    //	        [_tableView reloadData];
    //		}
    //	    else if (result == MessageComposeResultFailed) {
    //	        [self displayAlertWithText:NSLocalizedString(@"ALERT_CONTACT_DENIES_ACCESS_PREVIOUS", @"")];
    //		}
    //	}];
}

@end
