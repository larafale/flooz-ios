//
//  AccountViewController.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "AccountViewController.h"
#import "FLAccountUserView.h"
#import "FLAccountButton.h"

#import "SettingsViewController.h"
#import "EditAccountViewController.h"
#import "InvitCodeViewController.h"
#import "InformationsViewController.h"
#import "CashOutViewController.h"

#import "SecureCodeViewController.h"

#import "FLWaveAnimation.h"

@interface AccountViewController (){
    UIScrollView *_contentView;
    
    FLAccountUserView *userView;
    UILabel *amount;
    
    FLAccountButton *inviteCode;
    FLAccountButton *cashout;
    FLAccountButton *settings;
    FLAccountButton *informations;
}

@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_ACCOUNT", nil);
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMakeWithSize(self.view.frame.size)];
    [self.view addSubview:_contentView];
    
    {
        userView = [FLAccountUserView new];
        [userView addEditTarget:self action:@selector(presentEditAccountController)];
        [_contentView addSubview:userView];
    }
    
    {
        UIImageView *imageView = [UIImageView imageNamed:@"account-balance"];
        CGRectSetXY(imageView.frame, 25, 200);
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(69, 185, 200, 30)];
        text.text = NSLocalizedString(@"ACCOUNT_BALANCE", nil);
        text.font = [UIFont customContentRegular:10];
        text.textColor = [UIColor customBlueLight];
        
        amount = [[UILabel alloc] initWithFrame:CGRectMake(69, 200, 200, 30)];
        
        amount.text = [FLHelper formatedAmount:[[[Flooz sharedInstance] currentUser] amount]];
        amount.font = [UIFont customTitleExtraLight:24];
        amount.textColor = [UIColor customBlue];
                
        [_contentView addSubview:imageView];
        [_contentView addSubview:text];
        [_contentView addSubview:amount];
    }
    
    {
        inviteCode = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(- 1, 246) title:NSLocalizedString(@"ACCOUNT_BUTTON_CODE", nil) imageNamed:@"account-button-code"];
        
        cashout = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(CGRectGetMaxX(inviteCode.frame) - 1, inviteCode.frame.origin.y) title:NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil) imageNamed:@"account-button-cashout"];
        
        settings = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(- 1, CGRectGetMaxY(inviteCode.frame) - 1) title:NSLocalizedString(@"ACCOUNT_BUTTON_SETTINGS", nil) imageNamed:@"account-button-settings"];
        
        informations = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(CGRectGetMaxX(settings.frame) - 1, CGRectGetMaxY(inviteCode.frame) - 1) title:NSLocalizedString(@"ACCOUNT_BUTTON_INFORMATIONS", nil) imageNamed:@"account-button-informations"];
        
        [inviteCode addTarget:self action:@selector(presentInviteCodeController) forControlEvents:UIControlEventTouchUpInside];
        [cashout addTarget:self action:@selector(presentCashOutController) forControlEvents:UIControlEventTouchUpInside];
        [settings addTarget:self action:@selector(presentSettingsController) forControlEvents:UIControlEventTouchUpInside];
        [informations addTarget:self action:@selector(presentInformationsController) forControlEvents:UIControlEventTouchUpInside];
                
        
        [_contentView addSubview:inviteCode];
        [_contentView addSubview:cashout];
        [_contentView addSubview:settings];
        [_contentView addSubview:informations];
        
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(informations.frame));
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self registerNotification:@selector(reloadCurrentUser) name:kNotificationReloadCurrentUser object:nil];
    _contentView.frame = CGRectMakeWithSize(self.view.frame.size);
    
    [self reloadCurrentUser];
    [[Flooz sharedInstance] updateCurrentUser];
}

- (void)presentEditAccountController
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[EditAccountViewController new]];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)presentInviteCodeController
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[InvitCodeViewController new]];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)presentCashOutController
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] cashoutValidate:^(id result) {
        FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[CashOutViewController new]];
        [self presentViewController:controller animated:YES completion:NULL];
    } failure:^(NSError *error) {        
        [self presentEditAccountController];
    }];
}

- (void)presentSettingsController
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[SettingsViewController new]];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)presentInformationsController
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[InformationsViewController new]];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)reloadCurrentUser
{
    [userView reloadData];
    amount.text = [FLHelper formatedAmount:[[[Flooz sharedInstance] currentUser] amount]];
}

- (void)presentMenuTransactionController
{
}

@end
