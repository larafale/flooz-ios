//
//  PaymentAudiotelViewController.m
//  Flooz
//
//  Created by Olive on 18/05/16.
//  Copyright © 2016 Flooz. All rights reserved.
//


#import "FLBorderedActionButton.h"
#import "PaymentAudiotelViewController.h"

@interface PaymentAudiotelViewController () {
    NSMutableDictionary *dictionary;
    
    UIScrollView *contentView;
    
    UILabel *h1;
    UIImageView *numberView;
    UILabel *numberHint;
    
    UILabel *currentBalance;
    
    UILabel *codeHint;
    FLTextField *codeTextField;
    FLActionButton *useCodeButton;
}

@end

@implementation PaymentAudiotelViewController

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        if (self.triggerData && self.triggerData[@"flooz"]) {
            _floozData = self.triggerData[@"flooz"];
        }
        
        if (self.triggerData && self.triggerData[@"item"]) {
            _itemData = self.triggerData[@"item"];
        }
        
        if (self.triggerData && self.triggerData[@"cashin"]) {
            _cashinData = self.triggerData[@"cashin"];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dictionary = [NSMutableDictionary new];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_AUDIOTEL", nil);
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    contentView.bounces = NO;
    
    h1 = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_AUDIOTEL_INFOS", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:15] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetXY(h1.frame, 20, 20);
    CGRectSetWidth(h1.frame, PPScreenWidth() - 40);
    
    if ([Flooz sharedInstance].currentTexts.audiotelInfos && ![[Flooz sharedInstance].currentTexts.audiotelInfos isBlank])
        h1.text = [Flooz sharedInstance].currentTexts.audiotelInfos;
    
    [h1 setHeightToFit];
    
    numberView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(h1.frame) + 20, PPScreenWidth() - 40, 60)];
    [numberView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callButtonClick)]];
    [numberView setUserInteractionEnabled:YES];
    [numberView setContentMode:UIViewContentModeScaleAspectFit];
    
    [numberView sd_setImageWithURL:[NSURL URLWithString:[[[Flooz sharedInstance] currentTexts] audiotelImage]]];
    
    numberHint = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_AUDIOTEL_AVALAIBLE", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:13] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetXY(numberHint.frame, 10, CGRectGetMaxY(numberView.frame) + 10);
    CGRectSetWidth(numberHint.frame, PPScreenWidth() - 20);
    [numberHint setHeightToFit];
    
    UILabel *balanceHint = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(numberHint.frame) + 20, PPScreenWidth() - 40, 25)];
    balanceHint.text = NSLocalizedString(@"FLOOZ_BALANCE", nil);
    balanceHint.textColor = [UIColor whiteColor];
    balanceHint.textAlignment = NSTextAlignmentCenter;
    balanceHint.font = [UIFont customContentRegular:15];
    
    currentBalance = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(balanceHint.frame), PPScreenWidth() - 40, 30)];
    currentBalance.textColor = [UIColor customBlue];
    currentBalance.textAlignment = NSTextAlignmentCenter;
    currentBalance.font = [UIFont customContentBold:20];
    currentBalance.numberOfLines = 1;
    currentBalance.text = [FLHelper formatedAmount:[Flooz sharedInstance].currentUser.amount withCurrency:YES withSymbol:NO];
    
    codeHint = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_AUDIOTEL_HINT", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:15] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetXY(codeHint.frame, 40, CGRectGetMaxY(currentBalance.frame) + 30);
    CGRectSetWidth(codeHint.frame, PPScreenWidth() - 80);
    
    codeTextField = [[FLTextField alloc] initWithPlaceholder:NSLocalizedString(@"CASHIN_AUDIOTEL_PLACEHOLDER", nil) for:dictionary key:@"audiotelCode" frame:CGRectMake(40, CGRectGetMaxY(codeHint.frame) + 10, PPScreenWidth() - 80, 35)];
    codeTextField.floatLabelActiveColor = [UIColor clearColor];
    codeTextField.floatLabelPassiveColor = [UIColor clearColor];
    codeTextField.maxLenght = 8;
    codeTextField.textAlignment = NSTextAlignmentCenter;
    codeTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    codeTextField.enableAllCaps = YES;
    [codeTextField addForNextClickTarget:codeTextField action:@selector(resignFirstResponder)];
    
    useCodeButton = [[FLActionButton alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(codeTextField.frame) + 10, PPScreenWidth() - 80, 40) title:NSLocalizedString(@"GLOBAL_VALIDATE", nil)];
    [useCodeButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:h1];
    [contentView addSubview:numberView];
    [contentView addSubview:numberHint];
    [contentView addSubview:codeHint];
    [contentView addSubview:currentBalance];
    [contentView addSubview:codeTextField];
    [contentView addSubview:useCodeButton];
    [contentView addSubview:balanceHint];
    
    contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(useCodeButton.frame) + 20);
    
    [_mainBody addSubview:contentView];
    
    [self registerForKeyboardNotifications];
    
    [self registerNotification:@selector(updateBalance) name:kNotificationReloadCurrentUser object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAudiotelCodeField:) name:@"cashin:audiotel:sync" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [codeTextField resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)updateBalance {
    currentBalance.text = [FLHelper formatedAmount:[Flooz sharedInstance].currentUser.amount withCurrency:YES withSymbol:NO];
}

- (void)callButtonClick {
    [self.view endEditing:YES];
    [self.view endEditing:NO];
    
    if ([[[Flooz sharedInstance] currentTexts] audiotelNumber]) {
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:[[[Flooz sharedInstance] currentTexts] audiotelNumber]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (void)sendButtonClick {
    [self.view endEditing:YES];
    [self.view endEditing:NO];
    
    [[Flooz sharedInstance] showLoadView];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    if (self.floozData && self.floozData.allKeys.count) {
        params[@"flooz"] = self.floozData;
    }
    
    if (self.itemData && self.itemData.allKeys.count) {
        params[@"item"] = self.itemData;
    }
    
    if (self.cashinData && self.cashinData.allKeys.count) {
        params[@"cashin"] = self.cashinData;
    }

    if (dictionary[@"audiotelCode"]) {
        params[@"code"] = dictionary[@"audiotelCode"];
    }
    
    [[Flooz sharedInstance] cashinAudiotel:params success:^(id result) {
        dictionary[@"audiotelCode"] = @"";
        [codeTextField setText:@""];
        [codeTextField setPlaceholder:NSLocalizedString(@"CASHIN_AUDIOTEL_PLACEHOLDER", nil)];
    } failure:^(NSError *error) {
        
    }];
}

- (void)updateAudiotelCodeField:(NSNotification*)notification {
    NSDictionary* userInfo = notification.userInfo;
    
    if (userInfo && userInfo[@"code"]) {
        dictionary[@"audiotelCode"] = userInfo[@"code"];
        [codeTextField reloadTextField];
    }
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRectSetHeight(contentView.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight);
    
    CGPoint bottomOffset = CGPointMake(0, contentView.contentSize.height - contentView.bounds.size.height);
    if (bottomOffset.y < 0)
        [contentView setContentOffset:CGPointZero animated:NO];
    else
        [contentView setContentOffset:bottomOffset animated:NO];
}

- (void)keyboardWillDisappear {
    CGRectSetHeight(contentView.frame, CGRectGetHeight(_mainBody.frame));
    
    CGPoint bottomOffset = CGPointMake(0, contentView.contentSize.height - contentView.bounds.size.height);
    if (bottomOffset.y < 0)
        [contentView setContentOffset:CGPointZero animated:NO];
    else
        [contentView setContentOffset:bottomOffset animated:NO];
}

@end
