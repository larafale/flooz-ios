//
//  RIBViewController.m
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "RIBViewController.h"
#import "FLTextFieldTitle2.h"

@interface RIBViewController (){
    NSMutableDictionary *_sepa;
}

@end

@implementation RIBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_RIB", nil);
        
        FLUser *currentUser = [[Flooz sharedInstance] currentUser];
        _sepa = [[currentUser sepa] mutableCopy];
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
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_IBAN" placeholder:@"FIELD_IBAN_PLACEHOLDER" for:_sepa key:@"iban" position:CGPointMake(20, 10)];
        [self.view addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldTitle2 *view = [[FLTextFieldTitle2 alloc] initWithTitle:@"FIELD_BIC" placeholder:@"FIELD_BIC_PLACEHOLDER" for:_sepa key:@"bic" position:CGPointMake(20, height + 50)];
        [self.view  addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
}

#pragma mark -

- (void)didValidTouch
{
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateUser:@{ @"settings": @{ @"sepa": _sepa }} success:^(id result) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:NULL];
}

@end
