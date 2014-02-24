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
#import "InformationsViewController.h"
#import "CashOutViewController.h"

@interface AccountViewController (){
    UIScrollView *_contentView;
    
    FLAccountUserView *userView;
    UILabel *amount;
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
        [userView addTarget:self action:@selector(presentEditAccountController)];
        [_contentView addSubview:userView];
    }
    
    {
        UIImageView *imageView = [UIImageView imageNamed:@"account-balance"];
        imageView.frame = CGRectSetXY(imageView.frame, 25, 200);
        
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
        FLAccountButton *profil = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(- 1, 246) title:NSLocalizedString(@"ACCOUNT_BUTTON_PROFIL", nil) imageNamed:@"account-button-profil"];
        
        FLAccountButton *cashout = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(CGRectGetMaxX(profil.frame) - 1, profil.frame.origin.y) title:NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil) imageNamed:@"account-button-cashout"];
        
        FLAccountButton *settings = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(- 1, CGRectGetMaxY(profil.frame) - 1) title:NSLocalizedString(@"ACCOUNT_BUTTON_SETTINGS", nil) imageNamed:@"account-button-settings"];
        
        FLAccountButton *informations = [[FLAccountButton alloc] initWithFrame:CGRectMakePosition(CGRectGetMaxX(settings.frame) - 1, CGRectGetMaxY(profil.frame) - 1) title:NSLocalizedString(@"ACCOUNT_BUTTON_INFORMATIONS", nil) imageNamed:@"account-button-informations"];
        
        [profil addTarget:self action:@selector(presentEditAccountController) forControlEvents:UIControlEventTouchUpInside];
        [cashout addTarget:self action:@selector(presentCashOutController) forControlEvents:UIControlEventTouchUpInside];
        [settings addTarget:self action:@selector(presentSettingsController) forControlEvents:UIControlEventTouchUpInside];
        [informations addTarget:self action:@selector(presentInformationsController) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:profil];
        [_contentView addSubview:cashout];
        [_contentView addSubview:settings];
        [_contentView addSubview:informations];
        
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetMaxY(informations.frame));
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCurrentUser) name:@"reloadCurrentUser" object:nil];
    _contentView.frame = CGRectMakeWithSize(self.view.frame.size);
    
    [[Flooz sharedInstance] updateCurrentUser];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadCurrentUser" object:nil];
}

- (void)presentEditAccountController
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[EditAccountViewController new]];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)presentCashOutController
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[CashOutViewController new]];
    [self presentViewController:controller animated:YES completion:NULL];
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

@end
