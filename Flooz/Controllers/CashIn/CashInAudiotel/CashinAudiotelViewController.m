//
//  CashinAudiotelViewController.m
//  Flooz
//
//  Created by Olive on 4/14/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLBorderedActionButton.h"
#import "CashinAudiotelViewController.h"

@interface CashinAudiotelViewController () {
    NSMutableDictionary *dictionary;
    
    UIScrollView *contentView;
    
    UILabel *h1;
    UIImageView *numberView;
    UILabel *numberHint;
    
    UILabel *codeHint;
    FLTextField *codeTextField;
    FLActionButton *useCodeButton;
}

@end

@implementation CashinAudiotelViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    dictionary = [NSMutableDictionary new];

    if (!self.title || [self.title isBlank])
        self.title = @"Créditer mon compte";

    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    contentView.bounces = NO;

    h1 = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_AUDIOTEL_INFOS", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:15] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetXY(h1.frame, 20, 20);
    CGRectSetWidth(h1.frame, PPScreenWidth() - 40);
    [h1 setHeightToFit];
    
    numberView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(h1.frame) + 20, PPScreenWidth() - 40, 60)];
    [numberView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callButtonClick)]];
    [numberView setUserInteractionEnabled:YES];
    [numberView setContentMode:UIViewContentModeScaleAspectFit];
    
    [numberView sd_setImageWithURL:[NSURL URLWithString:@"http://www.flooz.me/img/audiotel/num3e.png"]];
    
    numberHint = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_AUDIOTEL_AVALAIBLE", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:13] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetXY(numberHint.frame, 10, CGRectGetMaxY(numberView.frame) + 10);
    CGRectSetWidth(numberHint.frame, PPScreenWidth() - 20);
    [numberHint setHeightToFit];
    
    codeHint = [[UILabel alloc] initWithText:NSLocalizedString(@"CASHIN_AUDIOTEL_HINT", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:15] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetXY(codeHint.frame, 40, CGRectGetMaxY(numberHint.frame) + 50);
    CGRectSetWidth(codeHint.frame, PPScreenWidth() - 80);

    codeTextField = [[FLTextField alloc] initWithPlaceholder:NSLocalizedString(@"CASHIN_AUDIOTEL_PLACEHOLDER", nil) for:dictionary key:@"audiotelCode" frame:CGRectMake(40, CGRectGetMaxY(codeHint.frame) + 10, PPScreenWidth() - 80, 35)];
    codeTextField.floatLabelActiveColor = [UIColor clearColor];
    codeTextField.textAlignment = NSTextAlignmentCenter;
    codeTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [codeTextField addForNextClickTarget:codeTextField action:@selector(resignFirstResponder)];
    
    useCodeButton = [[FLActionButton alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(codeTextField.frame) + 10, PPScreenWidth() - 80, 40) title:NSLocalizedString(@"GLOBAL_VALIDATE", nil)];
    [useCodeButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];

    [contentView addSubview:h1];
    [contentView addSubview:numberView];
    [contentView addSubview:numberHint];
    [contentView addSubview:codeHint];
    [contentView addSubview:codeTextField];
    [contentView addSubview:useCodeButton];
    
    contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(useCodeButton.frame) + 20);
    
    [_mainBody addSubview:contentView];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [codeTextField resignFirstResponder];
    
    [super viewWillDisappear:animated];
}

- (void)callButtonClick {
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:[[[Flooz sharedInstance] currentTexts] audiotelNumber]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)sendButtonClick {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] cashinAudiotel:dictionary[@"audiotelCode"] success:nil failure:nil];
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
