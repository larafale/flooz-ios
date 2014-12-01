//
//  GlobalViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "GlobalViewController.h"

@interface GlobalViewController ()

@end

@implementation GlobalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissViewController {
    [self.view endEditing:YES];
    if ([self navigationController]) {
        if ([[[self navigationController] viewControllers] count] == 1) {
            [[self navigationController] dismissViewControllerAnimated:YES completion:NULL];
        }
        else {
            [[self navigationController] popViewControllerAnimated:YES];
        }
    }
    else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (viewControllerToPresent) {
            [super presentViewController:viewControllerToPresent animated:flag completion:completion];
        }
    });
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
