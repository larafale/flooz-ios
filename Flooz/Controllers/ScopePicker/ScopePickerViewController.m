//
//  ScopePickerViewController.m
//  Flooz
//
//  Created by Olive on 13/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ScopePickerCell.h"
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
        isPot = pot;
        _currentScope = TransactionScopeNone;
    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        _currentScope = TransactionScopeNone;

        isPot = NO;
        
        if (self.triggerData && self.triggerData[@"isPot"] && [self.triggerData[@"isPot"] boolValue])
            isPot = YES;
        
        if (self.triggerData && self.triggerData[@"scope"])
            _currentScope = [FLTransaction transactionIDToScope:self.triggerData[@"scope"]];
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
    
    return [ScopePickerCell getHeight:scope pot:isPot];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    ScopePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ScopePickerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
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
    
    [cell setScope:scope pot:isPot];
    
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
    
    if (self.delegate) {
        [self.delegate scope:self.currentScope pickedFrom:self];
    } else if (self.triggerData) {
        [self dismissViewControllerAnimated:YES completion:^{
            NSArray<FLTrigger *> *successTriggers = [FLTriggerManager convertDataInList:self.triggerData[@"success"]];
            FLTrigger *successTrigger = successTriggers[0];
            
            NSMutableDictionary *data = [NSMutableDictionary new];
            
            data[@"scope"] = [FLTransaction transactionScopeToParams:self.currentScope];
            
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

            [[FLTriggerManager sharedInstance] executeTriggerList:successTriggers];
        }];
    }
}

@end
