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
    NSArray *_rows;
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
        
        _sections = @[
                      @"feed",
                      @"push",
                      @"email",
                      @"phone"
                      ];
        
        _rows = @[
                  @{ @"floozRequest": @"flooz_request" },
                  @{ @"floozStatus": @"flooz_status" },
                  @{ @"friendRequest": @"friend_request" },
                  @{ @"friendJoined": @"friend_joined" },
                  @{ @"event": @"event" },
                  @{ @"comments": @"comments" },
                  @{ @"likes": @"likes" },
                  @{ @"lineNew": @"new_transaction" }
                  ];
    }
    return self;
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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 36, 0, 31)];
        
        label.textColor = [UIColor customPlaceholder];
        
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
        
        UISwitch *switchView = [UISwitch new];

        [switchView setTintColor:[UIColor customBlue]]; // Bordure
        [switchView setThumbTintColor:[UIColor customBackgroundHeader]]; // Cursuer
        [switchView setOnTintColor:[UIColor customBlue]]; // Couleur de fond
        
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
    } failure:NULL];
}

#pragma mark - 

- (NSString *)notificationTitleAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *notification = [self notificationAtIndexPath:indexPath];
    NSString *rowLocalKey = [notification objectForKey:@"rowLocalKey"];
    
    return NSLocalizedString([@"NOTIFICATIONS_" stringByAppendingString:[rowLocalKey uppercaseString]], nil);
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
    
    int indexRowNotification = 0;
    for(indexRowNotification = 0; indexRowNotification < [_rows count]; ++indexRowNotification){
        NSString *notificationKey = [[[_notifications objectForKey:sectionKey] allKeys] objectAtIndex:indexPath.row];
        NSString *rowKey = [[[_rows objectAtIndex:indexRowNotification] allKeys] firstObject];
        
        if([notificationKey isEqualToString:rowKey]){
            break;
        }
    }
    
    NSString *rowKey = [[[_rows objectAtIndex:indexRowNotification] allKeys] firstObject];
    NSString *rowLocalKey = [[[_rows objectAtIndex:indexRowNotification] allValues] firstObject];
    
    return @{
             @"sectionKey": sectionKey,
             @"rowKey": rowKey,
             @"rowLocalKey": rowLocalKey
             };
}

@end
