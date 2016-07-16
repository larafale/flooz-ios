//
//  ScopePickerViewController.m
//  Flooz
//
//  Created by Olive on 13/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ScopePickerViewController.h"

@interface ScopePickerViewController() {
    UITableView *_tableView;
    
    FLPreset *currentPreset;
    
    Boolean isPot;
}

@end

@implementation ScopePickerViewController

+ (id)newWithDelegate:(id<ScopePickerViewControllerDelegate>)delegate preset:(FLPreset *)preset forPot:(Boolean)pot {
    return [[ScopePickerViewController alloc] initWithDelegate:delegate preset:preset forPot:pot];
}

- (id)initWithDelegate:(id<ScopePickerViewControllerDelegate>)delegate preset:(FLPreset *)preset forPot:(Boolean)pot {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        currentPreset = preset;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (isPot)
        self.title = NSLocalizedString(@"TRANSACTION_SCOPE_POT_TITLE", nil);
    else
        self.title = NSLocalizedString(@"TRANSACTION_SCOPE_TITLE", nil);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBounces:NO];
    [_tableView setSeparatorColor:[UIColor clearColor]];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setTableFooterView:[UIView new]];
    
    [_mainBody addSubview:_tableView];
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
    return 45;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    TransactionScope scope;
    
    if (currentPreset && currentPreset.scopes && currentPreset.scopes.count) {
        scope = [FLTransaction transactionIDToScope:currentPreset.scopes[indexPath.row]];
    } else {
        switch (indexPath.row) {
            case 0:
                scope = TransactionScopePublic;
                break;
            case 1:
                scope = TransactionScopeFriend;
                break;
            case 2:
                scope = TransactionScopePrivate;
                break;
        }
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    [cell.imageView setImage:[[FLHelper imageWithImage:[FLTransaction transactionScopeToImage:scope] scaledToSize:CGSizeMake(30, 30)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [cell.imageView setTintColor:[UIColor whiteColor]];
    
    [cell.textLabel setText:[FLTransaction transactionScopeToText:scope]];
    [cell.textLabel setFont:[UIFont customContentRegular:15]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];

    [cell.detailTextLabel setText:[FLTransaction transactionScopeToSubtitle:scope forPot:isPot]];
    [cell.detailTextLabel setFont:[UIFont customContentRegular:12]];
    [cell.detailTextLabel setTextColor:[UIColor customPlaceholder]];
    [cell.detailTextLabel setNumberOfLines:0];
    [cell.detailTextLabel setLineBreakMode:NSLineBreakByWordWrapping];

    CGRectSetY(cell.detailTextLabel.frame, CGRectGetMinY(cell.detailTextLabel.frame) + 10);
    
    if (scope == self.currentScope) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionScope scope;
    
    if (currentPreset && currentPreset.scopes && currentPreset.scopes.count) {
        scope = [FLTransaction transactionIDToScope:currentPreset.scopes[indexPath.row]];
    } else {
        switch (indexPath.row) {
            case 0:
                scope = TransactionScopePublic;
                break;
            case 1:
                scope = TransactionScopeFriend;
                break;
            case 2:
                scope = TransactionScopePrivate;
                break;
        }
    }
    
    self.currentScope = scope;
    [_tableView reloadData];
    
    if (self.delegate)
        [self.delegate scope:self.currentScope pickedFrom:self];
}

@end
