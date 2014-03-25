//
//  FLNavigationController.m
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLNavigationController.h"

@interface FLNavigationController (){
    UIBarButtonItem *backItem;
    UIBarButtonItem *closeItem;
}

@end

@implementation FLNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.delegate = self;
        [self customAppearence];
    }
    return self;
}

- (void)customAppearence
{
    {
        [[UINavigationBar appearance] setBarTintColor:[UIColor customBackgroundHeader]];
        self.navigationBar.translucent = NO;
        
        NSDictionary *attributes = @{
                                     NSForegroundColorAttributeName: [UIColor customBlue],
                                     NSFontAttributeName: [UIFont customTitleExtraLight:28]
                                     };
        
        [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    }
    
    backItem = [UIBarButtonItem createBackButtonWithTarget:self action:@selector(popViewController)];
    closeItem = [UIBarButtonItem createCloseButtonWithTarget:self action:@selector(dismiss)];
    
    {
        self.navigationBar.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:.2];
        self.navigationBar.layer.shadowOpacity = .2;
        self.navigationBar.layer.shadowOffset = CGSizeMake(0, 3.5);
        self.navigationBar.layer.shadowRadius = 1;
        self.navigationBar.clipsToBounds = NO;
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(navigationController.viewControllers.count == 1 && !navigationController.parentViewController){
        viewController.navigationItem.leftBarButtonItem = closeItem;
    }
    else{
        viewController.navigationItem.leftBarButtonItem = backItem;
    }
}

- (void) popViewController
{
    [self popViewControllerAnimated:YES];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
