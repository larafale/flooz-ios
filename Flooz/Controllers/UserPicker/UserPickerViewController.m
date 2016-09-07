//
//  UserPickerViewController.m
//  Flooz
//
//  Created by Olive on 07/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "UserPickerViewController.h"
#import "FriendAddSearchBar.h"
#import "NewFloozViewController.h"

@interface UserPickerViewController() {
    FriendAddSearchBar *_searchBar;
    FLUserPickerTableView *tableView;
    
    BOOL isSearching;
    NSString *searchString;
    
    NSTimer *timer;
}

@end

@implementation UserPickerViewController

+ (id)newWithDelegate:(id<UserPickerViewControllerDelegate>)delegate {
    return [[UserPickerViewController alloc] initWithDelegate:delegate];
}

- (id)initWithDelegate:(id<UserPickerViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_USER_PICKER", @"");
    
    _searchBar = [[FriendAddSearchBar alloc] initWithFrame:CGRectMake(10, 5, PPScreenWidth() - 20, 40)];
    _searchBar.searchBar.placeholder = NSLocalizedString(@"FRIEND_PCIKER_PLACEHOLDER", nil);
    
    if ([[[Flooz sharedInstance] currentTexts] friendSearch] && ![[[[Flooz sharedInstance] currentTexts] friendSearch] isBlank])
        _searchBar.searchBar.placeholder = [[[Flooz sharedInstance] currentTexts] friendSearch];
    
    [_searchBar setDelegate:self];
    [_searchBar sizeToFit];
    
    tableView = [[FLUserPickerTableView alloc] initWithFrame:CGRectMake(0, 50, PPScreenWidth(), CGRectGetHeight(_mainBody.frame) - 50)];
    [tableView setPickerDelegate:self];
    
    [_mainBody addSubview:_searchBar];
    [_mainBody addSubview:tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [tableView initializeView];
}

- (void)didFilterChange:(NSString *)text {
    searchString = text;
    
    if ([searchString length] < 3) {
        isSearching = NO;
        [tableView searchUser:text];
        return;
    }
    
    isSearching = YES;
    
    [tableView searchUser:text];
}

- (void)userSelected:(FLUser *)user {
    if (_delegate) {
        [_delegate user:user pickedFrom:self];
    } else if (self.triggerData) {
        NSArray<FLTrigger *> *successTriggers = [FLTriggerManager convertDataInList:self.triggerData[@"success"]];
        FLTrigger *successTrigger = successTriggers[0];
        
        NSMutableDictionary *data = [NSMutableDictionary new];
        
        if (user.userKind == FloozUser) {
            data[@"to"] = user.username;
            data[@"toFullName"] = user.fullname;
            data[@"block"] = user.blockObject;
        } else {
            data[@"to"] = user.phone;
            data[@"toFullName"] = user.fullname;
            if (user.firstname || user.lastname) {
                NSMutableDictionary *contact = [NSMutableDictionary new];
                if (![user.firstname isBlank]) {
                    [contact setValue:user.firstname forKey:@"firstName"];
                }
                
                if (![user.lastname isBlank]) {
                    [contact setValue:user.lastname forKey:@"lastName"];
                }
                
                data[@"contact"] = contact;
            }
        }
        
        NSDictionary *baseDic;
        
        if (self.triggerData[@"in"]) {
            baseDic = successTrigger.data[self.triggerData[@"in"]];
            
            [data addEntriesFromDictionary:baseDic];
            
            NSMutableDictionary *newData = [successTrigger.data mutableCopy];
            
            newData[self.triggerData[@"in"]] = data;
            
            successTrigger.data = newData;
        } else {
            baseDic = successTrigger.data;
            [data addEntriesFromDictionary:baseDic];
            
            successTrigger.data = data;
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            [[FLTriggerManager sharedInstance] executeTriggerList:successTriggers];
        }];
    }
}

#pragma mark - Keyboard Management

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    tableView.contentInset = UIEdgeInsetsMake(topInset,
                                              tableView.contentInset.left,
                                              bottomInset,
                                              tableView.contentInset.right);
    tableView.scrollIndicatorInsets = tableView.contentInset;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:tableView.contentInset.top bottom:bottomInset];
}

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:tableView.frame.origin.y + tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
}

- (void)keyboardDidDisappear:(NSNotification *)notification {
    [self adjustTableViewInsetBottom:0];
}

- (void)keyboardWillDisappear {
    
}

@end
