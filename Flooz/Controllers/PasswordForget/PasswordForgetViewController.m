//
//  PasswordForgetViewController.m
//  Flooz
//
//  Created by jonathan on 2014-04-10.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "PasswordForgetViewController.h"

#define MARGE 20.

@interface PasswordForgetViewController (){
    NSMutableDictionary *_user;
}

@end

@implementation PasswordForgetViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_PASSWORD_FORGET", nil);
        _user = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(valid)];
    
     FLTextFieldIcon *email = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_user key:@"email" position:CGPointMake(MARGE, 30)];
    [self.view addSubview:email];
}

- (void)valid
{
    [[self view] endEditing:YES];
    
    if(_user[@"email"]){
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] passwordLost:_user[@"email"] success:nil];
    }
}

@end
