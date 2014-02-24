//
//  PasswordViewController.m
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "PasswordViewController.h"
#import "FLTextFieldTitle2.h"

@interface PasswordViewController (){
    NSMutableDictionary *_password;
}

@end

@implementation PasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_PASSWORD", nil);
        
        _password = [NSMutableDictionary new];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(didValidTouch)];
    
    CGFloat height = 0;
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_CURRENT_PASSWORD" placeholder:@"" for:_password key:@"password" position:CGPointMake(20, 10)];
        [self.view addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
        
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_NEW_PASSWORD" placeholder:@"" for:_password key:@"newPassword" position:CGPointMake(20, height + 50)];
        [self.view  addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_PASSWORD_CONFIRMATION" placeholder:@"" for:_password key:@"confirm" position:CGPointMake(20, height + 50)];
        [self.view  addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
}

- (void)didValidTouch
{
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updatePassword:_password success:^(id result) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:NULL];
}

@end
