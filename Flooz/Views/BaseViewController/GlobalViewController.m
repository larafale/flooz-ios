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

@synthesize triggerData;

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super init];
    if (self) {
        if (data) {
            triggerData = data;
            
            if (triggerData[@"title"] && ![triggerData[@"title"] isBlank]) {
                self.title = triggerData[@"title"];
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
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

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    [self.view endEditing:YES];
    if ([self navigationController]) {
        if ([[[self navigationController] viewControllers] count] == 1) {
            [[self navigationController] dismissViewControllerAnimated:YES completion:completion];
        }
        else {
            [(FLNavigationController*)[self navigationController] popViewControllerAnimated:YES completion:completion];
        }
    }
    else {
        [super dismissViewControllerAnimated:YES completion:completion];
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

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@end
