//
//  InviteFriendsViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-09-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "FLStartItem.h"
#import "ContactCell.h"
#import "FriendCell.h"

@interface InviteFriendsViewController () {
	NSMutableArray *_contactInfoArray;
	NSMutableArray *_contactToInvite;
	NSMutableArray *_contactFromFlooz;

	UITableView *_tableView;
	UIView *_footerView;
	UIButton *inviteButton;

	UIView *_mainBody;

	NSMutableArray *_arrayPhonesAskServer;
}

@end

@implementation InviteFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		self.title = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Friends", @"");
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	_mainBody = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight() - PPStatusBarHeight() - CGRectGetHeight(self.navigationController.navigationBar.frame))];
	[self.view addSubview:_mainBody];

	_contactInfoArray = [NSMutableArray new];
	_contactToInvite = [NSMutableArray new];
	_contactFromFlooz = [NSMutableArray new];

	[self createTableContact];
	[self createFooter];

	[[Flooz sharedInstance] grantedAccessToContacts: ^(BOOL granted) {
	    if (granted) {
	        [self createContactList];
		}
	    else {
//	        [self displayAlertWithText:NSLocalizedString(@"ALERT_CONTACT_DENIES_ACCESS", @"")];
		}
	}];
}

- (void)createTableContact {
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor customBackground]];
	[_tableView setSeparatorColor:[UIColor customBackgroundHeader]];
	[_tableView setSeparatorInset:UIEdgeInsetsZero];
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[_tableView setAllowsMultipleSelection:YES];

	[_mainBody addSubview:_tableView];

	[_tableView setDataSource:self];
	[_tableView setDelegate:self];
}

- (void)createFooter {
	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_tableView.frame), CGRectGetWidth(_tableView.frame), 50.0f)];
	[_footerView setBackgroundColor:[UIColor customBlue]];

	FLStartItem *inviteTitle = [FLStartItem newWithTitle:@"" imageImageName:@"Signup_Check_White" contentText:@"" andSize:50.0f];
	CGRectSetX(inviteTitle.frame, CGRectGetWidth(_footerView.frame) - 50.0f);
	[_footerView addSubview:inviteTitle];

	inviteButton = [UIButton newWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 50.0f)];
	[inviteButton setTitle:NSLocalizedString(@"Invite_Friends_Button", @"") forState:UIControlStateNormal];
	[inviteButton addTarget:self action:@selector(inviteFriends) forControlEvents:UIControlEventTouchUpInside];
	[inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_footerView addSubview:inviteButton];

	CALayer *TopBorder = [CALayer layer];
	TopBorder.frame = CGRectMake(0.0f, 0.0f, _footerView.frame.size.width, 2.0f);
	TopBorder.backgroundColor = [UIColor whiteColor].CGColor;
	[_footerView.layer addSublayer:TopBorder];

	[_mainBody addSubview:_footerView];
}

- (void)displayAlertWithText:(NSString *)alertMessage {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GLOBAL_ERROR", nil)
	                                                message:alertMessage
	                                               delegate:nil
	                                      cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil)
	                                      otherButtonTitles:nil
	    ];
	alert.delegate = self;
	alert.tag = 25;
	dispatch_async(dispatch_get_main_queue(), ^{
	    [alert show];
	});
}

- (void)createContactList {
	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] createContactList: ^(NSMutableArray *arrayContactAdressBook, NSMutableArray *arrayContactFlooz) {
	    _contactInfoArray = arrayContactAdressBook;
	    _contactFromFlooz = arrayContactFlooz;
	    [_tableView reloadData];
	} atSignup:NO];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 25) {
	}
}

#pragma mark - TableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0)
		return _contactFromFlooz.count;
	else
		return _contactInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		static NSString *cellIdentifier = @"FriendAddCell";
		FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if (!cell) {
			cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}

		FLUser *user = [_contactFromFlooz objectAtIndex:indexPath.row];
		[cell setFriend:user];

		return cell;
	}
	else {
		static NSString *cellIdentifier = @"ContactCell";
		ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if (!cell) {
			cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor customBackground];
		}

		NSDictionary *contact = _contactInfoArray[indexPath.row];
		[cell setContact:contact];

		cell.accessoryView = nil;
		if ([contact[@"selected"] boolValue]) {
			cell.accessoryView = [UIImageView imageNamed:@"Signup_Friends_Selected"];
		}
		else {
			cell.accessoryView = [UIImageView imageNamed:@"Signup_Friends_Plus"];
		}

		[cell.addFriendButton setHidden:YES];
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 54.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"CONTACT_PICKER_FLOOZ", nil);
	}
	return NSLocalizedString(@"CONTACT_PICKER_NON_FLOOZ", nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0 && _contactFromFlooz.count) {
		return 28;
	}
	else if (section == 1 && _contactInfoArray.count) {
		return 28;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGFloat heigth = [self tableView:tableView heightForHeaderInSection:section];

	UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), heigth)];

	view.backgroundColor = [UIColor customBackgroundHeader];

	{
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 0, CGRectGetHeight(view.frame))];

		label.textColor = [UIColor customBlueLight];

		label.font = [UIFont customContentRegular:14];
		label.text = [self tableView:tableView titleForHeaderInSection:section];
		[label setWidthToFit];

		[view addSubview:label];
	}

	{
		UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame), CGRectGetWidth(view.frame), 1)];

		separator.backgroundColor = [UIColor customSeparator];

		[view addSubview:separator];
	}

	return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		ContactCell *cell = (ContactCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell setSelected:![cell isSelected]];

		NSMutableDictionary *contact = [_contactInfoArray[indexPath.row] mutableCopy];

		cell.accessoryView = nil;
		if (![contact[@"selected"] boolValue]) {
			[contact setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
			cell.accessoryView = [UIImageView imageNamed:@"Signup_Friends_Selected"];
			[_contactToInvite addObject:contact];
		}
		else {
			[_contactToInvite removeObject:contact];
			[contact setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
			cell.accessoryView = [UIImageView imageNamed:@"Signup_Friends_Plus"];
		}
		[_contactInfoArray replaceObjectAtIndex:indexPath.row withObject:contact];
		[self displaySendButtonOrNot];
	}
}

- (void)displaySendButtonOrNot {
	if (!_footerView) {
		[self createFooter];
	}
	if (_contactToInvite.count > 0) {
		if (CGRectGetMinY(_footerView.frame) >= CGRectGetHeight(_mainBody.frame)) {
			[UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
			    CGRectSetHeight(_tableView.frame, CGRectGetHeight(_tableView.frame) - 50.0f);
			    CGRectSetY(_footerView.frame, CGRectGetMinY(_footerView.frame) - 50.0f);
			} completion:nil];
		}
	}
	else {
		if (CGRectGetHeight(_mainBody.frame) > CGRectGetMinY(_footerView.frame)) {
			[UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations: ^{
			    CGRectSetHeight(_tableView.frame, CGRectGetHeight(_tableView.frame) + 50.0f);
			    CGRectSetY(_footerView.frame, CGRectGetHeight(_mainBody.frame));
			} completion:nil];
		}
	}
}

- (void)inviteFriends {
	MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
	if ([MFMessageComposeViewController canSendText]) {
		message.messageComposeDelegate = self;

		NSMutableArray *listOfPhone = [NSMutableArray new];
		for (NSDictionary *contact in _contactToInvite) {
			for (NSString *phone in contact[@"phones"]) {
				[listOfPhone addObject:phone];
			}
		}
		[message setRecipients:listOfPhone];
		NSString *textMessage = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Invite_Friends_Message_SMS", @""), [[[Flooz sharedInstance] currentUser] invitCode]];
		[message setBody:textMessage];

		message.modalPresentationStyle = UIModalPresentationPageSheet;
		[self presentViewController:message animated:YES completion:nil];
	}
}

- (UIView *)findFirstViewInHierarchyOfClass:(Class)classToLookFor object:(UIView *)v {
	UIView *sView = v.superview;
	while (sView) {
		if ([sView isKindOfClass:classToLookFor]) {
			return sView;
		}
		sView = [sView superview];
	}
	return sView;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[self dismissViewControllerAnimated:YES completion: ^{
	    if (result == MessageComposeResultSent) {
	        [_contactInfoArray removeObjectsInArray:_contactToInvite];
	        [_tableView reloadData];
		}
	    else if (result == MessageComposeResultFailed) {
	        [self displayAlertWithText:NSLocalizedString(@"ALERT_CONTACT_DENIES_ACCESS_PREVIOUS", @"")];
		}
	}];
}

@end
