//
//  JTContainerViewController.m
//  Flooz
//
//  Created by jonathan on 1/10/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "JTContainerViewController.h"

@implementation JTContainerViewController

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
    
    navbarView = [[JTNavbarView alloc] initWithViewControllers:_viewControllers];
    [self.view addSubview:navbarView];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(navbarView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(navbarView.frame))];
    [self.view addSubview:contentView];
    
    [self prepareViewControllers];
}


- (void)prepareViewControllers
{
    NSInteger index = 0;
    for(UIViewController *controller in _viewControllers){
        [self addChildViewController:controller];
        
        controller.view.frame = CGRectMake(controller.view.frame.origin.x, 0, CGRectGetWidth(contentView.frame), CGRectGetHeight(contentView.frame));
        
        [contentView addSubview:controller.view];
        
        [controller didMoveToParentViewController:self];
        index++;
    }
}

@end
