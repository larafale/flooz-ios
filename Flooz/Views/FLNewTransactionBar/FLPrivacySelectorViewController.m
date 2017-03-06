//
//  FLPrivacySelectorViewController.m
//  Flooz
//
//  Created by Olivier on 2/19/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import "FLPrivacyCell.h"
#import "FLPrivacySelectorViewController.h"

@interface FLPrivacySelectorViewController() {
    UITableView *_tableView;
    CGFloat viewHeight;
    CGFloat viewWidth;
    
    FLPreset *currentPreset;
}

@end

#define LIKE_CELL_HEIGHT 27.0f
#define LIKE_TEXT_HEIGHT 14.0f

@implementation FLPrivacySelectorViewController

@synthesize delegate;
@synthesize currentScope;

- (id)initWithPreset:(FLPreset *)preset {
    self = [super init];
    if (self) {
        
        currentPreset = preset;

        viewHeight = ([self tableView:_tableView heightForRowAtIndexPath:[NSIndexPath new]] * [self tableView:_tableView numberOfRowsInSection:0]) + 20 + [self tableView:_tableView heightForHeaderInSection:0];
        viewWidth = 200;
        
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
    
    if (currentPreset && currentPreset.scopes && currentPreset.scopeDefined) {
        currentScope = currentPreset.scope;
        [delegate scopeChange:currentScope];
    }
        
    [self.view addSubview:_tableView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView*)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), [self tableView:tableView heightForHeaderInSection:section])];
    
    UILabel *headerTitle = [[UILabel alloc] initWithText:NSLocalizedString(@"TRANSACTION_SCOPE_TITLE", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:15]];
    
    CGRectSetY(headerTitle.frame, CGRectGetHeight(headerView.frame) / 2 - CGRectGetHeight(headerTitle.frame) / 2);
    CGRectSetX(headerTitle.frame, 10);
    
    [headerView addSubview:headerTitle];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (currentPreset && currentPreset.scopes && currentPreset.scopes.count)
        return currentPreset.scopes.count;
    
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
    FLPrivacyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FLPrivacyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    FLScope *scope;
    
    if (currentPreset && currentPreset.scopes && currentPreset.scopes.count) {
        scope = currentPreset.scopes[indexPath.row];
    } else {
        switch (indexPath.row) {
            case 0:
                scope = [FLScope defaultScope:FLScopePublic];
                break;
            case 1:
                scope = [FLScope defaultScope:FLScopeFriend];
                break;
            case 2:
                scope = [FLScope defaultScope:FLScopePrivate];
                break;
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    [cell.imageView setImage:[scope.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [cell.imageView setTintColor:[UIColor blackColor]];
    
    [cell.textLabel setText:scope.name];
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
    FLScope *scope;
    
    if (currentPreset && currentPreset.scopes && currentPreset.scopes.count) {
        scope = currentPreset.scopes[indexPath.row];
    } else {
        switch (indexPath.row) {
            case 0:
                scope = [FLScope defaultScope:FLScopePublic];
                break;
            case 1:
                scope = [FLScope defaultScope:FLScopeFriend];
                break;
            case 2:
                scope = [FLScope defaultScope:FLScopePrivate];
                break;
        }
    }
    
    self.currentScope = scope;
    [_tableView reloadData];
    
    if (delegate)
        [delegate scopeChange:scope];
}

@end
