//
//  InvitationCodeViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-08-21.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "InvitationCodeViewController.h"

@interface InvitationCodeViewController () {
    
    FLTextFieldIcon *_codeField;
    
    NSMutableDictionary *dicCode;
}

@end

@implementation InvitationCodeViewController

- (id)initWithUser:(NSDictionary *)_user
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"Invitation Code", nil);
        if(_user){
            dicCode = [_user mutableCopy];
        }
        else {
            dicCode = [NSMutableDictionary new];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(checkInvitationCode)];
    
    UIImageView *logo = [UIImageView imageNamed:@"home-logo"];
    CGRectSetWidthHeight(logo.frame, 105, 105);
    CGRectSetXY(logo.frame, CGRectGetWidth(self.view.frame) / 2.0f - CGRectGetWidth(logo.frame) / 2.0f, 0.0f);
    if (PPScreenHeight() < 500) {
        CGRectSetY(logo.frame, 30.0f);
    }
    //[self.view addSubview:logo];
    
    
    _codeField = [[FLTextFieldIcon alloc] initWithIcon:@"" placeholder:@"Invitation Code" for:dicCode key:@"invitationCode" position:CGPointMake(0.0f, CGRectGetMaxY(logo.frame) + 18.0f)];
    
    [_codeField addForNextClickTarget:self action:@selector(checkInvitationCode)];
    
    [self.view addSubview:_codeField];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_codeField becomeFirstResponder];
}

- (void) checkInvitationCode {
    if (dicCode[@"invitationCode"] && ![dicCode[@"invitationCode"] isBlank]) {
        [[Flooz sharedInstance] verifyInvitationCode:dicCode[@"invitationCode"] success:^(id result) {
            [self dismissViewControllerAnimated:YES completion:^{}];
            [appDelegate showSignupWithUser:dicCode];
        } failure:^(NSError *error) {
            [_codeField becomeFirstResponder];
        }];
    }
}

@end
