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
        
        _notifications = [NSMutableDictionary new];
        
        _sections = @[
                      @[
                          @{ @"comments": @"" },
                          @{ @"likes": @"" },
                          @{ @"friend_request": @"" },
                          @{ @"friend_joined": @"" },
                          @{ @"status": @"" }
                          ],
                      @[
                          @{ @"status": @"" }
                          ],
                      @[
                          @{ @"comments": @"" },
                          @{ @"likes": @"" },
                          @{ @"friend_request": @"" },
                          @{ @"friend_joined": @"" },
                          @{ @"status": @"" }
                          ]
                      ];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(didValidTouch)];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Bug avec uitableview style grouped
    _tableView.frame = CGRectSetY(_tableView.frame, _tableView.frame.origin.y - 40);
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"NOTIFICATIONS_SECTION_PUSH", nil);
            break;
        case 1:
            title = NSLocalizedString(@"NOTIFICATIONS_SECTION_SMS", nil);
            break;
        case 2:
            title = NSLocalizedString(@"NOTIFICATIONS_SECTION_EMAIL", nil);
            break;
        default:
            break;
    }
    
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 71;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[_sections objectAtIndex:section] count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    
    {
        UIView *separatorTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.frame), 1)];
        UIView *separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame) - 1, CGRectGetWidth(view.frame), 1)];
        
        separatorTop.backgroundColor = separatorBottom.backgroundColor = [UIColor customSeparator];
        
        [view addSubview:separatorTop];
        [view addSubview:separatorBottom];
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
        
        cell.accessoryView = switchView;
    }
    
    NSString *notificationKey = [[[[_sections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] allKeys] firstObject];
    cell.textLabel.text = NSLocalizedString([@"NOTIFICATIONS_" stringByAppendingString:[notificationKey uppercaseString]], nil);;
    
    return cell;
}

#pragma mark - 

- (void)didValidTouch
{
    
}

@end
