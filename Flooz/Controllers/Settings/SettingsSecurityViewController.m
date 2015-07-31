//
//  SettingsSecurityViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SettingsSecurityViewController.h"

#import "SecureCodeViewController.h"
#import "PasswordViewController.h"
#import "AccountCell.h"

@interface SettingsSecurityViewController () {
    UITableView *_tableView;
    NSMutableArray *_menuArray;
}

@end

@implementation SettingsSecurityViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"SETTINGS_SECURITY", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame)) style:UITableViewStyleGrouped];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [_tableView setBackgroundColor:[UIColor customBackgroundHeader]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [_mainBody addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _menuArray = [NSMutableArray new];
    
    [_menuArray addObject:@{ @"title":NSLocalizedString(@"SETTINGS_CODE", @"") }];
    
    [_menuArray addObject:@{ @"title":NSLocalizedString(@"SETTINGS_PASSWORD", @"") }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableView reloadData];
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
    
    NSDictionary *rowDic = _menuArray[indexPath.row];
    [accountCell setMenu:rowDic];
    
    return accountCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        SecureCodeViewController *controller = [SecureCodeViewController new];
        controller.isForChangeSecureCode = YES;
        controller.blockTouchID = YES;
        self.hidesBottomBarWhenPushed = YES;
        [[self navigationController] pushViewController:controller animated:YES];
        self.hidesBottomBarWhenPushed = NO;
    }
    else if (indexPath.row == 1) {
        [[self navigationController] pushViewController:[PasswordViewController new] animated:YES];
    }
}

@end
