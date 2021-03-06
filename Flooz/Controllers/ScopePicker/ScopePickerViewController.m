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
    
    NSArray *scopes;
    
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
        _currentScope = [FLScope defaultScope:FLScopeNone];
        
        if (currentPreset.options.scope)
            _currentScope = currentPreset.options.scope;
        
        if (currentPreset.options.scopes)
            scopes = currentPreset.options.scopes;
    }
    return self;
}

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        _currentScope = [FLScope defaultScope:FLScopeNone];
        
        isPot = NO;
        
        if (self.triggerData && self.triggerData[@"isPot"] && [self.triggerData[@"isPot"] boolValue])
            isPot = YES;
        
        if (self.triggerData && self.triggerData[@"scope"])
            _currentScope = [FLScope scopeFromObject:self.triggerData[@"scope"]];
        
        if (self.triggerData && self.triggerData[@"scopes"]) {
            NSMutableArray *fixScopes = [NSMutableArray new];
            for (id scopeData in self.triggerData[@"scopes"]) {
                [fixScopes addObject:[FLScope scopeFromObject:scopeData]];
            }
            scopes = fixScopes;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (isPot)
        self.title = NSLocalizedString(@"TRANSACTION_SCOPE_POT_TITLE", nil);
    else
        self.title = NSLocalizedString(@"TRANSACTION_SCOPE_TITLE", nil);
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, PPScreenWidth(), CGRectGetHeight(_mainBody.frame) - 10)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setBounces:NO];
    [_tableView setSeparatorColor:[UIColor clearColor]];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setTableFooterView:[UIView new]];
    
    [_mainBody addSubview:_tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (currentPreset && currentPreset.options.scopes && currentPreset.options.scopes.count)
        return currentPreset.options.scopes.count;
    
    if (self.triggerData && scopes)
        return scopes.count;
    
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLScope *scope;
    
    if (currentPreset && currentPreset.options.scopes && currentPreset.options.scopes.count) {
        scope = currentPreset.options.scopes[indexPath.row];
    } else if (self.triggerData && scopes) {
        scope = scopes[indexPath.row];
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
    
    return [ScopePickerCell getHeight:scope pot:isPot];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    ScopePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ScopePickerCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    FLScope *scope;
    
    if (currentPreset && currentPreset.options.scopes && currentPreset.options.scopes.count) {
        scope = currentPreset.options.scopes[indexPath.row];
    } else if (self.triggerData && scopes) {
        scope = scopes[indexPath.row];
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
    
    [cell setScope:scope pot:isPot];
    
    if ([scope.keyString isEqualToString:self.currentScope.keyString]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLScope *scope;
    
    if (currentPreset && currentPreset.options.scopes && currentPreset.options.scopes.count) {
        scope = currentPreset.options.scopes[indexPath.row];
    } else if (self.triggerData && scopes) {
        scope = scopes[indexPath.row];
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
    
    if (self.delegate) {
        [self.delegate scope:self.currentScope pickedFrom:self];
    } else if (self.triggerData) {
        [self dismissViewControllerAnimated:YES completion:^{
            NSArray<FLTrigger *> *successTriggers = [FLTriggerManager convertDataInList:self.triggerData[@"success"]];
            FLTrigger *successTrigger = successTriggers[0];
            
            NSMutableDictionary *data = [NSMutableDictionary new];
            
            data[@"scope"] = self.currentScope.keyString;
            
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
