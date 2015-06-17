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
#import "SettingsSecretViewController.h"
#import "MenuCell.h"

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
    //    NSArray *missingFields = [Flooz sharedInstance].currentUser.json[@"missingFields"];
    
    _menuArray = [NSMutableArray new];
    
    [_menuArray addObject:@{ @"title":NSLocalizedString(@"SETTINGS_CODE", @"") }];
    
    [_menuArray addObject:@{ @"title":NSLocalizedString(@"SETTINGS_PASSWORD", @"") }];
    
    //    if ([missingFields containsObject:@"secret"])
    //        [_menuArray addObject:@{ @"title":NSLocalizedString(@"SETTINGS_SECRET", @""), @"incomplete": @YES}];
    //    else
    //        [_menuArray addObject:@{ @"title":NSLocalizedString(@"SETTINGS_SECRET", @"")}];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableView reloadData];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (CGRectGetHeight(_tableView.frame) - [_menuArray count] * [MenuCell getHeight] ) / 3.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [UIView newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_tableView.frame), [self tableView:_tableView heightForHeaderInSection:section])];
    [v setBackgroundColor:[UIColor customBackgroundHeader]];
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_menuArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [MenuCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MenuCell";
    MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[MenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryView:[UIImageView imageNamed:@"arrow-right-accessory"]];
    }
    
    NSDictionary *dic = _menuArray[indexPath.row];
    [cell setMenu:dic];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        SecureCodeViewController *controller = [SecureCodeViewController new];
        controller.isForChangeSecureCode = YES;
        controller.blockTouchID = YES;
        [[self navigationController] pushViewController:controller animated:YES];
    }
    else if (indexPath.row == 1) {
        [[self navigationController] pushViewController:[PasswordViewController new] animated:YES];
    }
    //    else if (indexPath.row == 2) {
    //        [[self navigationController] pushViewController:[SettingsSecretViewController new] animated:YES];
    //    }
}

@end
