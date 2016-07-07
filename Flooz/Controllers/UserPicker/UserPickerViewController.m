//
//  UserPickerViewController.m
//  Flooz
//
//  Created by Olive on 07/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "UserPickerViewController.h"
#import "FriendAddSearchBar.h"

@interface UserPickerViewController() {
    UIBarButtonItem *searchItem;
    
    FriendAddSearchBar *_searchBar;
    FLUserPickerTableView *tableView;
    
    BOOL isSearching;
    NSString *searchString;

}

@end

@implementation UserPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    searchItem = [[UIBarButtonItem alloc] initWithImage:[FLHelper imageWithImage:[UIImage imageNamed:@"search"] scaledToSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(showSearch)];
    [searchItem setTintColor:[UIColor customBlue]];
    
    _searchBar = [[FriendAddSearchBar alloc] initWithFrame:CGRectMake(10, -45, PPScreenWidth() - 20, 40)];
    [_searchBar setDelegate:self];
    [_searchBar setHidden:YES];
    [_searchBar sizeToFit];
    
    tableView = [[FLUserPickerTableView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [tableView setPickerDelegate:self];
    [tableView initializeView];
    
    [_mainBody addSubview:_searchBar];
    [_mainBody addSubview:tableView];
    
    self.navigationItem.rightBarButtonItem = searchItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [tableView initializeView];

    
    [self registerForKeyboardNotifications];
}

- (void)didFilterChange:(NSString *)text {
    searchString = text;
    
    if ([searchString isBlank]) {
        isSearching = NO;
        [tableView searchUser:text];
        return;
    }
    
    isSearching = YES;
    
    [tableView searchUser:text];
}

- (void)userSelected:(FLUser *)user {

}

- (void)showSearch {
    if ([_searchBar isHidden]) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_searchBar setHidden:NO];
            CGRectSetY(_searchBar.frame, 5);
            CGRectSetY(tableView.frame, CGRectGetMaxY(_searchBar.frame) + 5);
            CGRectSetHeight(tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame));
        } completion:^(BOOL finished) {
            [_searchBar becomeFirstResponder];
        }];
    } else {
        [_searchBar close];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRectSetY(_searchBar.frame, -45);
            CGRectSetY(tableView.frame, CGRectGetMaxY(_searchBar.frame) + 5);
            CGRectSetHeight(tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame));
        } completion:^(BOOL finished) {
            [_searchBar setHidden:YES];
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
