//
//  FirstLaunchViewController.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FirstLaunchViewController.h"
#import "FirstLaunchContentViewController.h"

@interface FirstLaunchViewController ()
{
    NSMutableArray   *_tutorialsView;
}

@property (strong, nonatomic) UIButton              *nextArrow;
@property (strong, nonatomic) UIPageViewController  *pageViewController;

@end

@implementation FirstLaunchViewController

- (void)loadView {
    [super loadView];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    CGRect frame    = [[UIScreen mainScreen] bounds];
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor customBackground];
}

#define NUMBER_OF_PAGES 3

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tutorialsView = [NSMutableArray array];
    for (int i = 0 ; i < NUMBER_OF_PAGES ; i++) {
        [_tutorialsView addObject:[NSNull null]];
    }
    
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    _pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self;
    _pageViewController.accessibilityLabel = @"FIRST LAUNCH PAGES";
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    
    [self.navigationController setNavigationBarHidden:YES];
    //__block FirstLaunchViewController *weakSelf = self;
    
    [self setScrollEnabled:NO forPageViewController:_pageViewController];
    [_pageViewController setViewControllers:[NSArray arrayWithObject:[self viewControllerAtIndex:0]]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished) {
                                     if (finished) {
                                     }
                                 }];
}

-(void)setScrollEnabled:(BOOL)enabled forPageViewController:(UIPageViewController*)pageViewController{
    for(UIView* view in pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]){
            UIScrollView* scrollView=(UIScrollView*)view;
            [scrollView setScrollEnabled:enabled];
            return;
        }
    }
}

- (FirstLaunchContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    // Return the data view controller for the given index.
    if (index >= NUMBER_OF_PAGES) {
        return nil;
    }
    
    id controller = _tutorialsView[index];
    if ([controller isEqual:[NSNull null]]) {
        FirstLaunchContentViewController *detailNewsViewController = [FirstLaunchContentViewController new];
        detailNewsViewController.delegate = self;
        detailNewsViewController.pageIndex = index;
        _pageViewController.view.frame = detailNewsViewController.view.frame;
        controller = detailNewsViewController;
        _tutorialsView[index] = detailNewsViewController;
    }
    
    return controller;
}

#pragma mark - UIPageViewController - Delegate - Datasource

- (FirstLaunchContentViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(FirstLaunchContentViewController *)viewController {
    
    return [self viewControllerAtIndex:viewController.pageIndex + 1];
}

- (FirstLaunchContentViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(FirstLaunchContentViewController *)viewController {
    
    return [self viewControllerAtIndex:viewController.pageIndex - 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
}

- (void)firstLaunchContentViewControllerDidDAppear:(FirstLaunchContentViewController *)controller;
{
}

- (void)goToNextPage:(NSInteger)currentIndex {
    if (currentIndex >= NUMBER_OF_PAGES) {
        return;
    }
    FirstLaunchContentViewController *next = [self viewControllerAtIndex:currentIndex+1];
    [self.pageViewController setViewControllers:@[next]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         if (finished) {
                                         }
                                     }];
    
}

- (void)goToPreviousPage:(NSInteger)currentIndex {
    if (currentIndex == 0) {
        return;
    }
    FirstLaunchContentViewController *previous = [self viewControllerAtIndex:currentIndex-1];
    [self.pageViewController setViewControllers:@[previous]
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         if (finished) {
                                         }
                                     }];
    
}
@end
