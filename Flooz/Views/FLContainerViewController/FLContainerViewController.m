//
//  FLContainerViewController.m
//  Flooz
//
//  Created by jonathan on 1/10/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLContainerViewController.h"

#import <IDMPhotoBrowser.h>

@implementation FLContainerViewController

- (id)initWithControllers:(NSArray *)controllers
{
    self = [self init];
    if(self){
        self.viewControllers = controllers;
    }
    
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor customBackground];
    
    _navbarView = [[FLNavbarView alloc] initWithViewControllers:_viewControllers];
    [self.view addSubview:_navbarView];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_navbarView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(_navbarView.frame))];
    [self.view addSubview:contentView];
    contentView.backgroundColor = [UIColor customBackground];
    
    [self prepareViewControllers];
    [_navbarView prepapreCrossButton];
}

- (void)prepareViewControllers
{
    NSInteger index = 0;
    for(UIViewController *controller in _viewControllers){
        [self addChildViewController:controller];
        
        controller.view.frame = CGRectMake(controller.view.frame.origin.x, 0, CGRectGetWidth(contentView.frame), CGRectGetHeight(contentView.frame));
        
        [contentView addSubview:controller.view];
        controller.view.backgroundColor = [UIColor customBackground];
        
        [controller didMoveToParentViewController:self];
        index++;
    }
}

#pragma mark - IDMPhotoBrowserDelegate

- (void)didImageTouch:(UIView *)sender photoURL:(NSURL *)photoURL
{
    if(!photoURL){
        return;
    }
    
    IDMPhotoBrowser *controller = [[IDMPhotoBrowser alloc] initWithPhotoURLs:@[photoURL] animatedFromView:sender];
    
    controller.displayActionButton = NO;
    
    if([self presentedViewController]){
        if([[self presentedViewController] presentedViewController]){
            [[[self presentedViewController] presentedViewController] presentViewController:controller animated:YES completion:NULL];
        }
        else{
            [[self presentedViewController] presentViewController:controller animated:YES completion:NULL];
        }
    }
    else{
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

@end
