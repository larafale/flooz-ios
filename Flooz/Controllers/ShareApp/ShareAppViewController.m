//
//  ShareAppViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-09-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "ShareAppViewController.h"

#import "FLStartItem.h"
#import "ContactCell.h"
#import "FriendCell.h"
#import "FriendPickerSearchBar.h"
#import "FLUser.h"

@interface ShareAppViewController () {
	NSMutableArray *_contactInfoArray;
	NSMutableArray *_contactFiltered;
    NSMutableArray *_contactSearch;

    FriendPickerSearchBar *_searchBar;
    UIView *_messageView;
	UILabel *_messageDescription;
	UIButton *_shareButton;
	UITableView *_tableView;

	NSMutableArray *_arrayPhonesAskServer;
	NSArray *arrayIndex;

	NSMutableArray *_contactToInvite;
    
    NSIndexPath *tmpIndex;
    NSString *_selectionText;
    
    Boolean alertAsked;
}

@end

@implementation ShareAppViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = NSLocalizedString(@"ACCOUNT_BUTTON_INVITE", @"");
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

    alertAsked = NO;
	_contactInfoArray = [NSMutableArray new];
    _contactToInvite = [NSMutableArray new];
    
    _messageView = [UIView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 60.0f)];
    [_messageView setBackgroundColor:[UIColor customBackground]];
    [_mainBody addSubview:_messageView];
    
    {
        UIView *imageView = [UIImageView newWithImage:[UIImage imageNamed:@"invite-image"]];
        CGRectSetX(imageView.frame, 10.0f);
        CGRectSetY(imageView.frame, (CGRectGetHeight(_messageView.frame) - CGRectGetHeight(imageView.frame)) / 2.0f);
        [_messageView addSubview:imageView];
        
        _messageDescription = [UILabel newWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5.0f, 0.0f, CGRectGetWidth(_messageView.frame) - (CGRectGetMaxX(imageView.frame) + 5.0f + 10.0f), CGRectGetHeight(_messageView.frame))];
        _messageDescription.text = NSLocalizedString(@"INVITE_MESSAGE", nil);
        _messageDescription.font = [UIFont customTitleLight:16];
        _messageDescription.numberOfLines = 0;
        _messageDescription.textColor = [UIColor whiteColor];
        _messageDescription.textAlignment = NSTextAlignmentCenter;
        [_messageView addSubview:_messageDescription];
    }

    _searchBar = [FriendPickerSearchBar newWithFrame:CGRectMake(0, CGRectGetMinY(_mainBody.frame) + CGRectGetHeight(_messageView.frame) + 5, PPScreenWidth(), 20)];
    _searchBar.delegate = self;
    _searchBar._searchBar.placeholder = NSLocalizedString(@"FRIEND_PCIKER_PLACEHOLDER2", nil);
    
    [self.view addSubview:_searchBar];
    
	[self createTableContact];

	[[Flooz sharedInstance] grantedAccessToContacts: ^(BOOL granted) {
	    if (granted) {
	        [self createContactList];
		}
	    else {
//	        [self displayAlertWithText:NSLocalizedString(@"ALERT_CONTACT_DENIES_ACCESS", @"")];
		}
	}];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_tableView setHidden:NO];
}

- (void)createShareButton {
	_shareButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 0, PPScreenWidth() - 20.0f * 2, 34)];

	[_shareButton setTitle:NSLocalizedString(@"INVITE_CODE_SHARE", nil) forState:UIControlStateNormal];
	[_shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_shareButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];
	[_shareButton setBackgroundColor:[UIColor customBackground]];
}

- (void)createTableContact {
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_messageView.frame) + 40.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_messageView.frame) - 40.0f) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor customBackgroundHeader]];
	[_tableView setSeparatorInset:UIEdgeInsetsZero];
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setKeyboardDismissMode:UIScrollViewKeyboardDismissModeOnDrag];
    
	[_mainBody addSubview:_tableView];

	[_tableView setDataSource:self];
	[_tableView setDelegate:self];
	[_tableView setHidden:YES];
    [_tableView setAllowsMultipleSelection:YES];

	[self setIndexColorForTableView:_tableView];
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
	[[Flooz sharedInstance] createContactList: ^(NSMutableArray *arrayContactAdressBook, NSMutableArray *arrayContactFlooz) {
	    _contactInfoArray = arrayContactAdressBook;
	    for (FLUser * us in arrayContactFlooz) {
	        NSUInteger index = [[Flooz sharedInstance] findIndexForUser:us inArray:_contactInfoArray];
	        [_contactInfoArray insertObject:us atIndex:index];
		}

	    _contactFiltered = [[self partitionObjects:_contactInfoArray collationStringSelector:@selector(description)] mutableCopy];
	    [_tableView reloadData];
	} atSignup:NO];
}

#pragma mark - TableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_contactFiltered[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	[self setIndexColorForTableView:tableView];

	static NSString *cellIdentifier = @"ContactCell";
	ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (!cell) {
		cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor customBackgroundHeader];
	}
    
	NSDictionary *contact = _contactFiltered[indexPath.section][indexPath.row];
	if ([contact isKindOfClass:[NSDictionary class]]) {
		[cell setContact:contact];
	}
	else {
		[cell setContactUser:(FLUser *)contact];
    }
    [cell.addFriendButton setHidden:YES];
    NSInteger anIndex=[_contactToInvite indexOfObject:contact];
    if(NSNotFound == anIndex) {
        UIImage *image = [UIImage imageNamed:@"event-scope-invite-selected"];
        UIButton *b = [UIButton newWithFrame:CGRectMakeWithSize(image.size)];
        b.tag = indexPath.row;
        [b addTarget:self action:@selector(invite:) forControlEvents:UIControlEventTouchUpInside];
        [b setImage:image forState:UIControlStateNormal];
        cell.accessoryView = b;
    }
    else {
        cell.accessoryView = [UIImageView imageNamed:@"friends-field-in"];
    }
    return cell;
}

- (void)setIndexColorForTableView:(UITableView *)tableView {
	for (UIView *view in[tableView subviews]) {
		if ([view respondsToSelector:@selector(setIndexColor:)]) {
			[view performSelector:@selector(setIndexColor:) withObject:[UIColor customBackground]];
			[view performSelector:@selector(setIndexBackgroundColor:) withObject:[UIColor customBackgroundHeader]];
		}
	}
}

- (void)invite:(id)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:buttonPosition];
    if (indexPath != nil)
    {
        ContactCell *cell = (ContactCell *)[_tableView cellForRowAtIndexPath:indexPath];
        NSDictionary *friend = _contactFiltered[indexPath.section][indexPath.row];
        NSInteger anIndex = [_contactToInvite indexOfObject:friend];
        if (NSNotFound == anIndex) {
            if (!alertAsked)
                [self showAlertAskInvite:indexPath];
            else {
                [_contactToInvite addObject:friend];
                cell.accessoryView = [UIImageView imageNamed:@"friends-field-in"];
                [[Flooz sharedInstance] inviteWithPhone:friend[@"phone"]];
            }
        }
    }
}

- (void)showAlertAskInvite:(NSIndexPath*)indexPath {
    tmpIndex = indexPath;
    alertAsked = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SHARE_APP_ALERT_TITLE", nil) message:NSLocalizedString(@"SHARE_APP_ALERT_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_INVITE", nil), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        ContactCell *cell = (ContactCell *)[_tableView cellForRowAtIndexPath:tmpIndex];
        NSDictionary *friend = _contactFiltered[tmpIndex.section][tmpIndex.row];
        [_contactToInvite addObject:friend];
        cell.accessoryView = [UIImageView imageNamed:@"friends-field-in"];
        [[Flooz sharedInstance] inviteWithPhone:friend[@"phone"]];
    }
}

- (void)didFilterChange:(NSString *)text {
    _selectionText = text;
    
    // Supprime le @ si text commence par @
    if ([text rangeOfString:@"@"].location == 0) {
        text = [text substringFromIndex:1];
    }
    
    if (!text || [text isBlank]) {
        _contactFiltered = [[self partitionObjects:_contactInfoArray collationStringSelector:@selector(description)] mutableCopy];
        [_tableView reloadData];
        return;
    }

    _contactSearch = [NSMutableArray new];
    
    for (NSDictionary *contact in _contactInfoArray) {
        if ([contact objectForKey:@"name"] && [[[contact objectForKey:@"name"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
            [_contactSearch addObject:contact];
        }
        else if ([contact objectForKey:@"email"] && [[[contact objectForKey:@"email"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
            [_contactSearch addObject:contact];
        }
        else if ([contact objectForKey:@"phone"] && [[[contact objectForKey:@"phone"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
            [_contactSearch addObject:contact];
        }
        else if ([contact objectForKey:@"phone"]) {
            NSString *clearPhone = [contact objectForKey:@"phone"];
            if ([clearPhone hasPrefix:@"+33"]) {
                clearPhone = [clearPhone stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"0"];
            }
            if ([[clearPhone lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
                [_contactSearch addObject:contact];
            }
            else if ([[[contact objectForKey:@"phone"] lowercaseString] rangeOfString:[text lowercaseString]].location != NSNotFound) {
                [_contactSearch addObject:contact];
            }
        }
    }
    
    if (!_contactSearch.count) {
        NSString *formattedPhone = [FLHelper formatedPhone2:text];
        if (formattedPhone) {
            [_contactSearch addObject:@{@"name":@"Futur utilisateur", @"phone":formattedPhone}];
        }
    }

    _contactFiltered = [[self partitionObjects:_contactSearch collationStringSelector:@selector(description)] mutableCopy];
    [_tableView reloadData];
}

#pragma mark - index section

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	BOOL showSection;
	showSection = [_contactFiltered[section] count] != 0;
	return (showSection) ? [NSString stringWithFormat:@"%@", [[UILocalizedIndexedCollation currentCollation] sectionTitles][section]] : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 5.0f;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [UIView new];
}

- (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector {
	UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];

	NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
	NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];

	//create an array to hold the data for each section
	for (int i = 0; i < sectionCount; i++) {
		[unsortedSections addObject:[NSMutableArray array]];
	}
	//put each object into a section
	for (NSDictionary *object in array) {
		NSInteger index;

		if ([object isKindOfClass:[NSDictionary class]]) {
			index = [collation sectionForObject:object[@"name"] collationStringSelector:selector];
		}
		else {
			index = [collation sectionForObject:[(FLUser *)object fullname] collationStringSelector:selector];
		}

		[unsortedSections[index] addObject:object];
	}
	return unsortedSections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 54.0f;
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

@end
