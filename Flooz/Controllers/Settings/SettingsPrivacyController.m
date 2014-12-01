//
//  SettingsPrivacyController.m
//  Flooz
//
//  Created by Epitech on 11/24/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLTransaction.h"
#import "SettingsPrivacyController.h"

#define PADDING_SIDE 20.0f

@implementation SettingsPrivacyController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"SETTINGS_PRIVACY", nil);
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat height = 20.0f;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE, height, PPScreenWidth() - 2 * PADDING_SIDE, 20)];
    [label setText:NSLocalizedString(@"SETTINGS_DEFAULT_SCOPE", nil)];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont customContentLight:16]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    [_mainBody addSubview:label];
    
    height += CGRectGetHeight(label.frame) + 20.0f;
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithFrame:CGRectMake(PADDING_SIDE, height, CGRectGetWidth(self.view.frame) - 2 * PADDING_SIDE, 27)];
    [control insertSegmentWithTitle:[FLTransaction transactionScopeToText:TransactionScopePublic] atIndex:TransactionScopePublic animated:NO];
    [control insertSegmentWithTitle:[FLTransaction transactionScopeToText:TransactionScopeFriend] atIndex:TransactionScopeFriend animated:NO];
    [control insertSegmentWithTitle:[FLTransaction transactionScopeToText:TransactionScopePrivate] atIndex:TransactionScopePrivate animated:NO];
    [control setTintColor:[UIColor customBlue]];
    [control addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [control setSelectedSegmentIndex:[FLTransaction transactionParamsToScope:[Flooz sharedInstance].currentUser.settings[@"def"][@"scope"]]];
    
    [_mainBody addSubview:control];
}

- (void)segmentedControlValueChanged:(UISegmentedControl*)sender {
    [[Flooz sharedInstance] updateUser:@{@"settings":@{@"def":@{@"scope":[FLTransaction transactionScopeToTextParams:sender.selectedSegmentIndex]}}} success:nil failure:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

@end
