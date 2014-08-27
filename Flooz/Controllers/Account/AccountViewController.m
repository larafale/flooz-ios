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
    UIView *_bottomView;
    
    FLAccountUserView *userView;
    UILabel *amount;
    
    FLAccountButton *inviteCode;
    FLAccountButton *cashout;
    FLAccountButton *settings;
    FLAccountButton *informations;
    
    UILabel *plusL;
    UILabel *minusL;
    NSNumber *plusAmount;
    NSNumber *minusAmount;
    NSMutableArray *transactions;
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
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMakeWithSize(CGSizeMake(PPScreenWidth(), PPScreenHeight() - PPStatusBarHeight() - PPToolBarHeight()))];
    [self.view addSubview:_contentView];
    {
        userView = [FLAccountUserView new];
        [userView addEditTarget:self action:@selector(presentEditAccountController)];
        [_contentView addSubview:userView];
    }
    
    {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userView.frame), CGRectGetWidth(userView.frame), CGRectGetHeight(_contentView.frame) - CGRectGetHeight(userView.frame))];
        [_contentView addSubview:_bottomView];
    }
    {
        UIImageView *imageView = [UIImageView imageNamed:@"account-balance"];
        CGRectSetXY(imageView.frame, 15, 20);
        
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 15, 5, 145, 30)];
        text.text = NSLocalizedString(@"ACCOUNT_BALANCE", nil);
        text.font = [UIFont customContentRegular:10];
        text.textColor = [UIColor customBlueLight];
        
        amount = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(text.frame), 20, CGRectGetWidth(text.frame), 30)];
        amount.text = [FLHelper formatedAmount:[[[Flooz sharedInstance] currentUser] amount]];
        amount.font = [UIFont customTitleExtraLight:24];
        amount.textColor = [UIColor customBlue];
        
        [_bottomView addSubview:imageView];
        [_bottomView addSubview:text];
        [_bottomView addSubview:amount];
    }
    
    {
        UIImageView *arrowUp = [UIImageView imageNamed:@"balance-plus"];
        CGRectSetXY(arrowUp.frame, CGRectGetMaxX(amount.frame), 5);
        
        plusL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(arrowUp.frame) + 5, CGRectGetMinY(arrowUp.frame), 100, CGRectGetHeight(arrowUp.frame))];
        plusL.text = [FLHelper formatedAmount:plusAmount];
        plusL.font = [UIFont customTitleLight:18];
        plusL.textColor = [UIColor customGreen];
        
        
        UIImageView *arrowDown = [UIImageView imageNamed:@"balance-minus"];
        CGRectSetXY(arrowDown.frame, CGRectGetMinX(arrowUp.frame), CGRectGetMaxY(arrowUp.frame) + 8);
        
        minusL = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(arrowDown.frame) + 5, CGRectGetMinY(arrowDown.frame), 100, CGRectGetHeight(arrowDown.frame))];
        minusL.text = [FLHelper formatedAmount:minusAmount];
        minusL.font = [UIFont customTitleLight:18];
        minusL.textColor = [UIColor customRed];
        
        [_bottomView addSubview:arrowUp];
        [_bottomView addSubview:plusL];
        [_bottomView addSubview:arrowDown];
        [_bottomView addSubview:minusL];
    }
    
    {
        settings = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(- 1, CGRectGetHeight(_bottomView.frame) - CGRectGetHeight(settings.frame)) title:NSLocalizedString(@"ACCOUNT_BUTTON_SETTINGS", nil) imageNamed:@"account-button-settings"];
        
        informations = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(CGRectGetMaxX(settings.frame) - 1, CGRectGetMinY(settings.frame)) title:NSLocalizedString(@"ACCOUNT_BUTTON_INFORMATIONS", nil) imageNamed:@"account-button-informations"];
        
        inviteCode = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(- 1, CGRectGetMinY(settings.frame) - CGRectGetHeight(inviteCode.frame) + 1) title:NSLocalizedString(@"ACCOUNT_BUTTON_CODE", nil) imageNamed:@"account-button-cash"];
        
        cashout = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(CGRectGetMaxX(inviteCode.frame) - 1, CGRectGetMinY(inviteCode.frame)) title:NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil) imageNamed:@"account-button-bank"];
        /*
        inviteCode = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(- 1, 65) title:NSLocalizedString(@"ACCOUNT_BUTTON_CODE", nil) imageNamed:@"account-button-cash"];
        cashout = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(CGRectGetMaxX(inviteCode.frame) - 1, CGRectGetMinY(inviteCode.frame)) title:NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil) imageNamed:@"account-button-bank"];
        settings = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(- 1, CGRectGetMaxY(inviteCode.frame) - 1) title:NSLocalizedString(@"ACCOUNT_BUTTON_SETTINGS", nil) imageNamed:@"account-button-settings"];
        informations = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(CGRectGetMaxX(settings.frame) - 1, CGRectGetMaxY(inviteCode.frame) - 1) title:NSLocalizedString(@"ACCOUNT_BUTTON_INFORMATIONS", nil) imageNamed:@"account-button-informations"];
         */
        CGRectSetY(settings.frame, CGRectGetHeight(_bottomView.frame) - CGRectGetHeight(settings.frame));
        CGRectSetY(informations.frame, CGRectGetMinY(settings.frame));
        CGRectSetY(inviteCode.frame, CGRectGetMinY(settings.frame) - CGRectGetHeight(inviteCode.frame) + 1);
        CGRectSetY(cashout.frame, CGRectGetMinY(inviteCode.frame));
        
        [inviteCode addTarget:self action:@selector(presentInviteCodeController) forControlEvents:UIControlEventTouchUpInside];
        [cashout addTarget:self action:@selector(presentCashOutController) forControlEvents:UIControlEventTouchUpInside];
        [settings addTarget:self action:@selector(presentSettingsController) forControlEvents:UIControlEventTouchUpInside];
        [informations addTarget:self action:@selector(presentInformationsController) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:inviteCode];
        [_bottomView addSubview:cashout];
        [_bottomView addSubview:settings];
        [_bottomView addSubview:informations];
        
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(_bottomView.frame));
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerNotification:@selector(reloadCurrentUser) name:kNotificationReloadCurrentUser object:nil];
    _contentView.frame = CGRectMakeWithSize(CGSizeMake(PPScreenWidth(), PPScreenHeight() - PPStatusBarHeight() - PPToolBarHeight()));
    
    [self reloadCurrentUser];
    [self getTransations];
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

- (void) getTransations {
    [[Flooz sharedInstance] timeline:@"private" success:^(id result, NSString *nextPageUrl) {
        transactions = [result mutableCopy];
        [self reloadAmounts];
    } failure:NULL];
}

- (void) reloadAmounts {
    float plus = 0.0;
    float minus = 0.0;
    for (FLTransaction *tr in transactions) {
        if (tr && [tr status] == TransactionStatusAccepted) {
            if ([tr type] == TransactionTypePayment) {
                minus += [[tr amount] floatValue];
            }
            else {
                plus += [[tr amount] floatValue];
            }
        }
    }
    plusAmount = [NSNumber numberWithFloat:plus];
    minusAmount = [NSNumber numberWithFloat:minus];
    
    plusL.text = [FLHelper formatedAmount:plusAmount];
    minusL.text = [FLHelper formatedAmount:minusAmount];
}


- (void)presentMenuTransactionController
{
}

@end
