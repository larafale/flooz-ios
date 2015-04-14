//
//  SettingsViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//


#import "SettingsViewController.h"
#import "WebViewController.h"

#import "MenuCell.h"

@interface SettingsViewController () {
	UITableView *_tableView;
    NSArray *_menuArray;
}

@end

@implementation SettingsViewController

- (id)init {
	self = [super init];
	if (self) {
		self.title = NSLocalizedString(@"ACCOUNT_BUTTON_DIVERS", nil);
        
        _menuArray = @[
                       @{ @"title":NSLocalizedString(@"INFORMATIONS_RATE", @""),
                          @"action":@"rate",
                          @"page":@"rate"},
                       @{ @"title":NSLocalizedString(@"INFORMATIONS_FAQ", @""),
                          @"action":@"faq",
                          @"page":@"faq"},
                       @{ @"title":NSLocalizedString(@"INFORMATIONS_TERMS", @""),
                          @"action":@"terms" ,
                          @"page":@"cgu"},
                       @{ @"title":NSLocalizedString(@"INFORMATIONS_CONTACT", @""),
                          @"action":@"contact" ,
                          @"page":@"contact"},
                       @{ @"title":NSLocalizedString(@"SETTINGS_IDEAS_CRITICS", nil),
                          @"action":@"presentCashOutController" },
                       @{ @"title":NSLocalizedString(@"SETTINGS_RELOAD_TUTO", nil),
                          @"action":@"reloadTuto" },
                       @{ @"title":NSLocalizedString(@"SETTINGS_LOGOUT", nil),
                          @"action":@"presentCashOutController" }
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
        [cell setAccessoryView: [UIImageView imageNamed:@"arrow-right-accessory"]];
	}

    NSDictionary *dic = _menuArray[indexPath.row];
    [cell setMenu:dic];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = _menuArray[indexPath.row];
    
    if (indexPath.row == 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?pageNumber=0&sortOrdering=1&type=Purple+Software&mt=8&id=940393916"]];
    }
	else if (indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3) {
        [self goToWebView:dic];
	}
	else if (indexPath.row == 4) {
        [self presentIdeaCritics];
	}
    else if (indexPath.row == 5) {
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoFlooz];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoTimelineFriends];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoTimelinePublic];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoTimelinePrivate];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoWelcome];
        
        [self dismissViewControllerAnimated:YES completion:^{
            [appDelegate popToMainView];
        }];
    }
    else if (indexPath.row == 6) {
        FLPopup *popup = [[FLPopup alloc] initWithMessage:NSLocalizedString(@"LOGOUT_INFO", nil) accept: ^{
            [[Flooz sharedInstance] logout];
        } refuse:NULL];
        [popup show];
    }
}

- (void) goToWebView:(NSDictionary *)dic {
    NSString *url = [NSString stringWithFormat:@"%@?layout=webview", dic[@"page"]];
    NSString *link = dic[@"action"];
    NSString *title = NSLocalizedString([@"INFORMATIONS_" stringByAppendingString:[link uppercaseString]], nil);
    
    WebViewController *controller = [WebViewController new];
    [controller setUrl:[@"https://www.flooz.me/" stringByAppendingString : url]];
    controller.title = title;
    [[self navigationController] pushViewController:controller animated:YES];
}

- (void)presentIdeaCritics {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        [mailComposer setMailComposeDelegate:self];
        [mailComposer.navigationBar setTitleTextAttributes:@{ NSForegroundColorAttributeName: [UIColor blackColor] }];
        [mailComposer setNavigationBarHidden:NO animated:YES];
        
        [mailComposer setToRecipients:@[NSLocalizedString(@"IDEA_RECIPIENTS", nil)]];
        [mailComposer setMessageBody:NSLocalizedString(@"IDEA_MESSAGE", nil) isHTML:NO];
        [mailComposer setSubject:NSLocalizedString(@"IDEA_OBJECT", nil)];
        
        [self presentViewController:mailComposer animated:YES completion: ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
    else {
        [appDelegate displayMessage:NSLocalizedString(@"ALERT_NO_MAIL_TITLE", nil) content:NSLocalizedString(@"ALERT_NO_MAIL_MESSAGE1", nil) style:FLAlertViewStyleInfo time:nil delay:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        if (result == MFMailComposeResultSent) {
            [appDelegate displayMessage:@"Merci" content:@"Merci pour vos idées et votre contribution afin d'améliorer Flooz." style:FLAlertViewStyleSuccess time:nil delay:nil];
        }
        else if (result == MFMailComposeResultFailed) {
        }
    }];
}

@end
