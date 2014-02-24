//
//  SocialViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "SocialViewController.h"

#import "FriendsViewController.h"
#import "EventsViewController.h"
#import "AcitvitiesViewController.h"

@implementation SocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_SOCIAL", nil);
        
        currentController = nil;
        controllers = @[
                        [FriendsViewController new],
                        [EventsViewController new],
                        [AcitvitiesViewController new]
                        ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    {
        [_filterView addFilter:@"SOCIAL_FILTER_FRIENDS" target:self action:@selector(didFilterFriendsTouch)];
        [_filterView addFilter:@"SOCIAL_FILTER_EVENTS" target:self action:@selector(didFilterEventsTouch)];
        [_filterView addFilter:@"SOCIAL_FILTER_ACTIVITIES" target:self action:@selector(didFilterActivitiesTouch)];
    }
    
    [self didFilterFriendsTouch];
}

- (CGRect)frameForContentController
{
    return CGRectMake(0, CGRectGetMaxY(_filterView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(_filterView.frame));
}

- (void)displayContentController:(UIViewController*)newController;
{
    if(currentController == newController){
        return;
    }
    
    if(currentController){
        [self hideContentController:currentController];
    }
        
    [self addChildViewController:newController];
    newController.view.frame = [self frameForContentController];
    [self.view addSubview:newController.view];
    [newController didMoveToParentViewController:self];
    
    currentController = newController;
}

- (void)hideContentController:(UIViewController*)newController
{
    [newController willMoveToParentViewController:nil];
    [newController.view removeFromSuperview];
    [newController removeFromParentViewController];
    
    currentController = nil;
}


#pragma mark - Filters

- (void)didFilterFriendsTouch
{
    [self displayContentController:[controllers objectAtIndex:0]];
}

- (void)didFilterEventsTouch
{
    [self displayContentController:[controllers objectAtIndex:1]];
}

- (void)didFilterActivitiesTouch
{
    [self displayContentController:[controllers objectAtIndex:2]];
}

@end
