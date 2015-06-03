//
//  FLPrivacySelectorViewController.m
//  Flooz
//
//  Created by Olivier on 2/19/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import "FLPrivacyCell.h"
#import "FLPrivacySelectorViewController.h"

@interface FLPrivacySelectorViewController() {
    UITableView *_tableView;
    CGFloat viewHeight;
    CGFloat viewWidth;
}

@end

#define LIKE_CELL_HEIGHT 27.0f
#define LIKE_TEXT_HEIGHT 14.0f

@implementation FLPrivacySelectorViewController

@synthesize delegate;
@synthesize currentScope;

- (id)init {
    self = [super init];
    if (self) {
        
        viewHeight = (LIKE_CELL_HEIGHT * 3) + 20;
        viewWidth = 131;
        
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
    FLPrivacyCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FLPrivacyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    TransactionScope scope;
    
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
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    [cell.imageView setImage:[[FLTransaction transactionScopeToImage:scope] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [cell.imageView setTintColor:[UIColor blackColor]];
    
    [cell.textLabel setText:[FLTransaction transactionScopeToText:scope]];
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
            scope = TransactionScopePublic;
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
