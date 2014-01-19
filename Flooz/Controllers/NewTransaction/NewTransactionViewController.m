//
//  NewTransactionViewController.m
//  Flooz
//
//  Created by jonathan on 1/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "NewTransactionViewController.h"

@interface NewTransactionViewController ()

@end

@implementation NewTransactionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    FLValidNavBar *navBar = [FLValidNavBar new];
    [self.view addSubview:navBar];
    
    [navBar cancelAddTarget:self action:@selector(dismiss)];
    [navBar validAddTarget:self action:@selector(valid)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)valid
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
