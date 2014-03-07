//
//  SettingsViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "SettingsViewController.h"

#import "NotificationsViewController.h"
#import "CreditCardViewController.h"
#import "RIBViewController.h"
#import "PasswordViewController.h"

@interface SettingsViewController (){
    NSArray *links;
}

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_SETTINGS", nil);
        
        links = @[
                 @"notifications",
                 @"code",
                 @"card",
                 @"rib",
//                 @"privacy",
                 @"documents",
                 @"password",
                 @"logout"
                 ];
    }
    return self;
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [links count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 69.;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.backgroundColor = [UIColor customBackground];
        cell.textLabel.font = [UIFont customTitleExtraLight:16];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryView = [UIImageView imageNamed:@"arrow-white-right"];
    }
    
    NSString *link = [links objectAtIndex:indexPath.row];
    cell.textLabel.text = NSLocalizedString([@"SETTINGS_" stringByAppendingString:[link uppercaseString]], nil);
    cell.imageView.image = [UIImage imageNamed:[@"settings-" stringByAppendingString:link]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        [[self navigationController] pushViewController:[NotificationsViewController new] animated:YES];
    }
    if(indexPath.row == 2){
        [[self navigationController] pushViewController:[CreditCardViewController new] animated:YES];
    }
    else if(indexPath.row == 3){
        [[self navigationController] pushViewController:[RIBViewController new] animated:YES];
    }
    else if(indexPath.row == 5){
        [[self navigationController] pushViewController:[PasswordViewController new] animated:YES];
    }
    else if(indexPath.row == 6){
        [[Flooz sharedInstance] logout];
    }
}

@end
