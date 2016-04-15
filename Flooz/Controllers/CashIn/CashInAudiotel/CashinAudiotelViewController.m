//
//  CashinAudiotelViewController.m
//  Flooz
//
//  Created by Olive on 4/14/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CashinAudiotelViewController.h"

@interface CashinAudiotelViewController () {
    NSMutableDictionary *dictionary;
    FLActionButton *callButton;
    
    FLTextField *codeTextfield;
    FLActionButton *sendButton;
}

@end

@implementation CashinAudiotelViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    dictionary = [NSMutableDictionary new];
    
    if (!self.title || [self.title isBlank])
        self.title = @"Charger par Audiotel";

    callButton = [[FLActionButton alloc] initWithFrame:CGRectMake(50, 30, PPScreenWidth() - 100, 40) title:@"Appeler"];
    [callButton addTarget:self action:@selector(callButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [callButton setBackgroundColor:[UIColor customGreen] forState:UIControlStateNormal];
    [callButton setBackgroundColor:[UIColor customGreen:0.5f] forState:UIControlStateHighlighted];
    
    codeTextfield = [[FLTextField alloc] initWithPlaceholder:@"Code audiotel" for:dictionary key:@"code" frame:CGRectMake(50, CGRectGetMaxY(callButton.frame) + 50, PPScreenWidth() - 100, 40)];
    
    sendButton = [[FLActionButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(codeTextfield.frame) + 20, PPScreenWidth() - 100, 40) title:@"Utiliser"];
    [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [_mainBody addSubview:callButton];
    [_mainBody addSubview:codeTextfield];
    [_mainBody addSubview:sendButton];
}

- (void)callButtonClick {
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:@"0660718983"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)sendButtonClick {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] cashinValidate:dictionary success:nil failure:nil];
}

@end
