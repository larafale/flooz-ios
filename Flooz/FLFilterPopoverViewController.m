//
//  FLFilterPopoverViewController.m
//  Flooz
//
//  Created by Epitech on 7/23/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLFilterPopoverViewController.h"

@interface FLFilterPopoverViewController () {
    UITableView *_tableView;
    CGFloat viewHeight;
    CGFloat viewWidth;
}

@end

#define LIKE_CELL_HEIGHT 27.0f
#define LIKE_TEXT_HEIGHT 14.0f


@implementation FLFilterPopoverViewController

@synthesize currentScope;
@synthesize delegate;

- (id)init {
    self = [super init];
    if (self) {
        
        viewHeight = ([self tableView:_tableView heightForRowAtIndexPath:[NSIndexPath new]] * 3) + 20 + [self tableView:_tableView heightForHeaderInSection:0];
        viewWidth = 165;
        
        [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
        self.modalInPopover = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, self.preferredContentSize.width, self.preferredContentSize.height)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBounces:NO];
    [_tableView setSeparatorColor:[UIColor clearColor]];
    [_tableView setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:_tableView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView*)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), [self tableView:tableView heightForHeaderInSection:section])];
    
    UILabel *headerTitle = [[UILabel alloc] initWithText:NSLocalizedString(@"TIMELINE_FILTER_TITLE", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    
    CGRectSetY(headerTitle.frame, CGRectGetHeight(headerView.frame) / 2 - CGRectGetHeight(headerTitle.frame) / 2);
    CGRectSetX(headerTitle.frame, 10);
    
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LIKE_CELL_HEIGHT;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TransactionScope scope;
    
    NSString *title;

    switch (indexPath.row) {
        case 0:
            scope = TransactionScopeAll;
            title = NSLocalizedString(@"TIMELINE_FILTER_ALL", nil);
            break;
        case 1:
            scope = TransactionScopeFriend;
            title = NSLocalizedString(@"TIMELINE_FILTER_FRIENDS", nil);
            break;
        case 2:
            scope = TransactionScopePrivate;
            title = NSLocalizedString(@"TIMELINE_FILTER_PRIVATE", nil);
            break;
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    [cell.textLabel setText:title];
    [cell.textLabel setFont:[UIFont customContentRegular:LIKE_TEXT_HEIGHT]];
    [cell.textLabel setTextColor:[UIColor blackColor]];
    [cell.textLabel setTintColor:[UIColor blackColor]];
    
    if (scope == self.currentScope) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionScope scope;
    
    switch (indexPath.row) {
        case 0:
            scope = TransactionScopeAll;
            break;
        case 1:
            scope = TransactionScopeFriend;
            break;
        case 2:
            scope = TransactionScopePrivate;
            break;
    }
    
    self.currentScope = scope;
    [_tableView reloadData];
    
    if (delegate)
        [delegate scopeChange:scope];
}

@end
