//
//  SettingsNotificationsViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-07.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SettingsNotificationsViewController.h"

@interface SettingsNotificationsViewController () {
    NSMutableDictionary *_notifications;
    NSArray *_sections;
    UITableView *_tableView;
}

@end

@implementation SettingsNotificationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_NOTIFICATIONS", nil);
        
        FLUser *currentUser = [[Flooz sharedInstance] currentUser];
        _notifications = [[currentUser notifications] mutableCopy];
        
        [_notifications removeObjectForKey:@"feed"];
        
        _sections = @[
                      //                      @"feed",
                      @"push",
                      @"email",
                      @"phone"
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
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [_mainBody addSubview:_tableView];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[_notifications allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = [_sections objectAtIndex:section];
    return NSLocalizedString([@"NOTIFICATIONS_SECTION_" stringByAppendingString:[sectionName uppercaseString]], nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionName = [_sections objectAtIndex:section];
    return [[[_notifications objectForKey:sectionName] allKeys] count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGFloat height = [self tableView:tableView heightForHeaderInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), height)];
    
    view.backgroundColor = [UIColor customBackground];
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, CGRectGetWidth(tableView.frame) - 20.0f, height)];
        
        label.textColor = [UIColor customBlueLight];
        label.font = [UIFont customContentRegular:14];
        
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        [label setWidthToFit];
        
        [view addSubview:label];
    }
    
    return view;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NotificationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor customBackgroundHeader];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont customContentLight:14];
        
        UISwitch *switchView = [UISwitch new];
        
        switchView.userInteractionEnabled = NO; // Permet de detecter le click sur la cellule
        
        cell.accessoryView = switchView;
    }
    
    cell.textLabel.text = [self notificationTitleAtIndexPath:indexPath];
    
    UISwitch *switchView = (UISwitch *)cell.accessoryView;
    if ([self notificationValueAtIndexPath:indexPath]) {
        switchView.on = YES;
    }
    else {
        switchView.on = NO;
    }
    
    [self refreshSwitchViewColors:switchView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UISwitch *switchView = (UISwitch *)cell.accessoryView;
    
    NSDictionary *notification = [self notificationAtIndexPath:indexPath];
    NSString *sectionKey = [notification objectForKey:@"sectionKey"];
    NSString *rowKey = [notification objectForKey:@"rowKey"];
    
    NSDictionary *notificationAPI = @{
                                      @"canal": sectionKey,
                                      @"type": rowKey,
                                      @"value": [NSNumber numberWithBool:(!switchView.on)]
                                      };
    
    BOOL nextValue = !switchView.on;
    
    //    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateNotification:notificationAPI success: ^(id result) {
        [switchView setOn:nextValue animated:YES];
        [self notificationValue:switchView.on indexPath:indexPath];
        [self refreshSwitchViewColors:switchView];
    } failure: ^(NSError *error) {
        [switchView setOn:!nextValue animated:YES];
        [self notificationValue:switchView.on indexPath:indexPath];
        [self refreshSwitchViewColors:switchView];
    }];
    
    [switchView setOn:nextValue animated:YES];
    [self notificationValue:switchView.on indexPath:indexPath];
    [self refreshSwitchViewColors:switchView];
}

#pragma mark -

- (NSString *)notificationTitleAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *notification = [self notificationAtIndexPath:indexPath];
    NSString *rowKey = [notification objectForKey:@"rowKey"];
    
    return [[[[Flooz sharedInstance] currentTexts] notificationsText] objectForKey:rowKey];
}

- (BOOL)notificationValueAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *notification = [self notificationAtIndexPath:indexPath];
    NSString *sectionKey = [notification objectForKey:@"sectionKey"];
    NSString *rowKey = [notification objectForKey:@"rowKey"];
    
    return [[[_notifications objectForKey:sectionKey] objectForKey:rowKey] isEqualToNumber:@1];
}

- (void)notificationValue:(BOOL)value indexPath:(NSIndexPath *)indexPath {
    NSDictionary *notification = [self notificationAtIndexPath:indexPath];
    NSString *sectionKey = [notification objectForKey:@"sectionKey"];
    NSString *rowKey = [notification objectForKey:@"rowKey"];
    
    [[_notifications objectForKey:sectionKey] setObject:[NSNumber numberWithBool:value] forKey:rowKey];
}

- (NSDictionary *)notificationAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [_sections objectAtIndex:indexPath.section];
    NSString *rowKey = [[[_notifications objectForKey:sectionKey] allKeys] objectAtIndex:indexPath.row];
    
    return @{
             @"sectionKey": sectionKey,
             @"rowKey": rowKey
             };
}

- (void)refreshSwitchViewColors:(UISwitch *)switchView {
    if (switchView.on) {
        [switchView setThumbTintColor:[UIColor customBackgroundHeader]]; // Curseur
        [switchView setTintColor:[UIColor customBlue]]; // Bordure
        [switchView setOnTintColor:[UIColor customBlue]]; // Couleur de fond
    }
    else {
        [switchView setThumbTintColor:[UIColor customBackground]]; // Curseur
        [switchView setTintColor:[UIColor customBackground]]; // Bordure
        [switchView setOnTintColor:[UIColor customBackground]]; // Couleur de fond
    }
}

@end
