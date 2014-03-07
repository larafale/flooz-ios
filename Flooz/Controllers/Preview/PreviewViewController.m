//
//  PreviewViewController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "PreviewViewController.h"

@interface PreviewViewController ()

@end

@implementation PreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    _mainView.backgroundColor = [UIColor customBackground];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - NavBarDelegate

- (void)loadPreviousSlide{
    
}

- (void)loadNextSlide{
    
}

- (void)dismiss{
    if([self navigationController]){
        [[self navigationController] popViewControllerAnimated:YES];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
