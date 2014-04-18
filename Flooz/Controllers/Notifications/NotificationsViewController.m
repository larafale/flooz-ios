//
//  NotificationsViewController.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "NotificationsViewController.h"

@interface NotificationsViewController (){
    NSMutableDictionary *_notifications;
    NSArray *_sections;
}

@end

@implementation NotificationsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Evite barre blanche pendant animation
    self.view.backgroundColor = [UIColor customBackground];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_notifications allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName = [_sections objectAtIndex:section];
    return NSLocalizedString([@"NOTIFICATIONS_SECTION_" stringByAppendingString:[sectionName uppercaseString]], nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 71;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionName = [_sections objectAtIndex:section];
    return [[[_notifications objectForKey:sectionName] allKeys] count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 57;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), [self tableView:tableView heightForHeaderInSection:section])];
    
    view.backgroundColor = [UIColor customBackground];
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 36, 0, 31)];
        
        label.textColor = [UIColor customBlueLight];
        label.font = [UIFont customContentRegular:10];
        
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        [label setWidthToFit];
        
        [view addSubview:label];
    }

    return view;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"NotificationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor customBackground];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont customContentLight:14];
        
        UISwitch *switchView = [UISwitch new];
        
        switchView.userInteractionEnabled = NO; // Permet de detecter le click sur la cellule
        
        cell.accessoryView = switchView;
    }
    
    cell.textLabel.text = [self notificationTitleAtIndexPath:indexPath];
    
    UISwitch *switchView = (UISwitch *)cell.accessoryView;
    if([self notificationValueAtIndexPath:indexPath]){
        switchView.on = YES;
    }
    else{
        switchView.on = NO;
    }
    
    [self refreshSwitchViewColors:switchView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateNotification:notificationAPI success:^(id result) {
        [switchView setOn:(!switchView.on) animated:YES];
        [self notificationValue:switchView.on indexPath:indexPath];
        [self refreshSwitchViewColors:switchView];
    } failure:NULL];
}

#pragma mark - 

- (NSString *)notificationTitleAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *notification = [self notificationAtIndexPath:indexPath];
    NSString *rowKey = [notification objectForKey:@"rowKey"];
    
    return [[[[Flooz sharedInstance] currentUser] notificationsText] objectForKey:rowKey];
}

- (BOOL)notificationValueAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *notification = [self notificationAtIndexPath:indexPath];
    NSString *sectionKey = [notification objectForKey:@"sectionKey"];
    NSString *rowKey = [notification objectForKey:@"rowKey"];
    
    return [[[_notifications objectForKey:sectionKey] objectForKey:rowKey] isEqualToNumber:@1];
}

- (void)notificationValue:(BOOL)value indexPath:(NSIndexPath *)indexPath
{
    NSDictionary *notification = [self notificationAtIndexPath:indexPath];
    NSString *sectionKey = [notification objectForKey:@"sectionKey"];
    NSString *rowKey = [notification objectForKey:@"rowKey"];
    
    [[_notifications objectForKey:sectionKey] setObject:[NSNumber numberWithBool:value] forKey:rowKey];
}

- (NSDictionary *)notificationAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *sectionKey = [_sections objectAtIndex:indexPath.section];
    NSString *rowKey = [[[_notifications objectForKey:sectionKey] allKeys] objectAtIndex:indexPath.row];

    return @{
             @"sectionKey": sectionKey,
             @"rowKey": rowKey
             };
}

- (void)refreshSwitchViewColors:(UISwitch *)switchView{
    if(switchView.on){
        [switchView setThumbTintColor:[UIColor customBackground]]; // Curseur
        [switchView setTintColor:[UIColor customBlue]]; // Bordure
        [switchView setOnTintColor:[UIColor customBlue]]; // Couleur de fond
    }
    else{
        [switchView setThumbTintColor:[UIColor customBackgroundHeader]]; // Curseur
        [switchView setTintColor:[UIColor customBackgroundHeader]]; // Bordure
        [switchView setOnTintColor:[UIColor customBackgroundHeader]]; // Couleur de fond
    }
}

@end
