//
//  SettingsPreferencesViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SettingsPreferencesViewController.h"
#import "SettingsNotificationsViewController.h"
#import "SettingsPrivacyController.h"
#import "FLSwitch.h"
#import "AccountCell.h"

@interface SettingsPreferencesViewController () {
    UITableView *_tableView;
    NSArray *_menuArray;
    
    FLSwitch *facebookSwitch;
}

@end

@implementation SettingsPreferencesViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"SETTINGS_PREFERENCES", nil);
        
        _menuArray = @[
                       @{ @"title":NSLocalizedString(@"SETTINGS_FACEBOOK", @"") },
                       @{ @"title":NSLocalizedString(@"SETTINGS_NOTIFICATION", @"") },
                       @{ @"title":NSLocalizedString(@"SETTINGS_PRIVACY", @"") }
                       ];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame)) style:UITableViewStyleGrouped];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setBackgroundColor:[UIColor customBackgroundHeader]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_tableView setSeparatorColor:[UIColor customBackground]];
    [_tableView setBounces:NO];
    
    [_mainBody addSubview:_tableView];
    
    facebookSwitch = [FLSwitch new];
    [facebookSwitch addTarget:self action:@selector(didSwitchChange) forControlEvents:UIControlEventValueChanged];
    if ([[Flooz sharedInstance] facebook_token]) {
        facebookSwitch.on = YES;
    }
    else {
        facebookSwitch.on = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [AccountCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AccountCell";
    AccountCell *accountCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!accountCell) {
        accountCell = [[AccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [accountCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    if (indexPath.row == 0) {
        [accountCell setAccessoryView:facebookSwitch];
    }
    
    NSDictionary *rowDic = _menuArray[indexPath.row];
    [accountCell setMenu:rowDic];
    
    return accountCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [[self navigationController] pushViewController:[SettingsNotificationsViewController new] animated:YES];
    }
    else if (indexPath.row == 2) {
        [[self navigationController] pushViewController:[SettingsPrivacyController new] animated:YES];
    }
}

- (void)didSwitchChange {
    [self didFacebookTouch];
}

- (void)didFacebookTouch {
    [[Flooz sharedInstance] showLoadView];
    
    if ([[Flooz sharedInstance] facebook_token]) {
        facebookSwitch.on = NO;
        [[Flooz sharedInstance] disconnectFacebook];
    }
    else {
        facebookSwitch.on = YES;
        [[Flooz sharedInstance] connectFacebook];
    }
}

@end
