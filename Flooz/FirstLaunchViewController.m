//
//  FirstLaunchViewController.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FirstLaunchViewController.h"

#import "FLStartItem.h"

#define height_nav_bar 40.0f

@interface FirstLaunchViewController ()
{
    NSMutableArray   *_tutorialsView;
    UIView *_headMenu;
    UIProgressView *_headProgress;
    
    NSInteger _indexPage;
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
    self.view.backgroundColor = [UIColor customBackgroundHeader];
}

#define NUMBER_OF_PAGES 7

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
    
    
    UILabel *l = [UILabel new];
    [l setOrigin:CGPointMake(50, 200)];
    [l setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:l];
    
    
    _headMenu = [[UIView alloc]initWithFrame:self.view.bounds];
    [_headMenu setYOrigin:STATUSBAR_HEIGHT];
    [_headMenu setBackgroundColor:[UIColor customBackgroundHeader]];
    [_headMenu setHeight:height_nav_bar];
    [self.view addSubview:_headMenu];
    
    _headProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [_headProgress setOrigin:CGPointMake(0, 38)];
    [_headProgress setSize:CGSizeMake(PPScreenWidth(), 2)];
    [_headProgress setProgressTintColor: [UIColor customBlueLight]];
    [_headProgress setTrackTintColor: [UIColor whiteColor]];
    [_headProgress setProgress:0.0f / 7.0f animated:YES];
    [_headMenu addSubview: _headProgress];
    
    CGFloat offset = PPScreenWidth() / 7.0f - height_nav_bar;
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(offset, 0, height_nav_bar, height_nav_bar)];
    [backButton setImage:[UIImage imageNamed:@"navbar-cross"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(previous) forControlEvents:UIControlEventTouchUpInside];
    [_headMenu addSubview:backButton];
    
    FLStartItem *item1 = [FLStartItem newWithTitle:@"" imageImageName:@"field-phone" contentText:@"" andSize:height_nav_bar];
    [item1 setOrigin:CGPointMake(offset + height_nav_bar, 0)];
    [_headMenu addSubview:item1];
    
    
    FLStartItem *item2 = [FLStartItem newWithTitle:@"" imageImageName:@"field-username" contentText:@"" andSize:height_nav_bar];
    [item2 setOrigin:CGPointMake(2*(offset + height_nav_bar), 0)];
    [_headMenu addSubview:item2];
    
    
    FLStartItem *item3 = [FLStartItem newWithTitle:@"" imageImageName:@"field-name" contentText:@"" andSize:height_nav_bar];
    [item3 setOrigin:CGPointMake(3*(offset + height_nav_bar), 0)];
    [_headMenu addSubview:item3];
    
    
    FLStartItem *item4 = [FLStartItem newWithTitle:@"" imageImageName:@"field-password" contentText:@"" andSize:height_nav_bar];
    [item4 setOrigin:CGPointMake(4*(offset + height_nav_bar), 0)];
    [_headMenu addSubview:item4];
    
    FLStartItem *item5 = [FLStartItem newWithTitle:@"" imageImageName:@"payment-field-card-selected" contentText:@"" andSize:height_nav_bar];
    [item5 setOrigin:CGPointMake(5*(offset + height_nav_bar), 0)];
    [_headMenu addSubview:item5];
    
    FLStartItem *item6 = [FLStartItem newWithTitle:@"" imageImageName:@"scope-friend" contentText:@"" andSize:height_nav_bar];
    [item6 setOrigin:CGPointMake(6*(offset + height_nav_bar), 0)];
    [_headMenu addSubview:item6];
    
    
    [self setScrollEnabled:NO forPageViewController:_pageViewController];
    _indexPage = 0;
    [self presentNewViewSignup:UIPageViewControllerNavigationDirectionForward];
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

- (void) previous {
    _indexPage = SignupPagePhone;
    [self presentNewViewSignup:UIPageViewControllerNavigationDirectionReverse];
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
    if (_indexPage >= NUMBER_OF_PAGES) {
        return;
    }
    _indexPage = currentIndex+1;
    [self presentNewViewSignup:UIPageViewControllerNavigationDirectionForward];
}

- (void)goToPreviousPage:(NSInteger)currentIndex {
    if (_indexPage == 0) {
        return;
    }
    _indexPage = currentIndex-1;
    [self presentNewViewSignup:UIPageViewControllerNavigationDirectionReverse];
}

- (void)phoneNotRegistered:(NSDictionary *)user {
    _indexPage = SignupPagePseudo;
    [self presentNewViewSignup:UIPageViewControllerNavigationDirectionForward];
}

- (void) presentNewViewSignup:(UIPageViewControllerNavigationDirection)direction {
    if (direction == UIPageViewControllerNavigationDirectionForward)
    [self manageProgressBar:1.0];
    else
        [self manageProgressBar:-1.0];
    FirstLaunchContentViewController *newView = [self viewControllerAtIndex:_indexPage];
    [self.pageViewController setViewControllers:@[newView]
                                      direction:direction
                                       animated:YES
                                     completion:^(BOOL finished) {
                                         if (finished) {
                                         }
                                     }];
}

- (void) manageProgressBar:(float)pos {
    float pro = _headProgress.progress;
    
    if (_indexPage < SignupPagePhone) {
        pro += 0.0f * pos;
    }
    else if (_indexPage < SignupPageCode) {
        pro += 1.0f / 7.0f * pos;
    }
    else if (_indexPage <= SignupPageCB) {
        pro += 1.0f / 21.0f* pos;
    }
    else {
        pro += 1.0f / 7.0f * pos;
    }
    
    [_headProgress setProgress:pro animated:YES];
    [_headMenu setHidden:(_indexPage < SignupPagePseudo)];
}

@end
