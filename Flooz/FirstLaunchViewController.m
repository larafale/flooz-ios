//
//  FirstLaunchViewController.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FirstLaunchViewController.h"

#import "FLStartItem.h"
#import "AppDelegate.h"

#define height_nav_bar 40.0f
#define NUMBER_STEP 5.0f

@interface FirstLaunchViewController ()
{
    NSMutableArray   *_tutorialsView;
    UIView *_headMenu;
    UIProgressView *_headProgress;
    
    NSInteger _indexPage;
    UIButton *_closeButton;
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
    
    self.userInfoDico = [NSMutableDictionary new];
}

#define NUMBER_OF_PAGES (SignupPageFriends + 1)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tutorialsView = [NSMutableArray array];
    for (int i = 0 ; i <= NUMBER_OF_PAGES ; i++) {
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
    [_headMenu setYOrigin:-(height_nav_bar+STATUSBAR_HEIGHT)];
    [_headMenu setBackgroundColor:[UIColor customBackgroundHeader]];
    [_headMenu setHeight:height_nav_bar+STATUSBAR_HEIGHT];
    [self.view addSubview:_headMenu];
    
    _headProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [_headProgress setSize:CGSizeMake(PPScreenWidth(), 1)];
    [_headProgress setOrigin:CGPointMake(0, CGRectGetHeight(_headMenu.frame) - CGRectGetHeight(_headProgress.frame))];
    [_headProgress setProgressTintColor: [UIColor customBlueLight]];
    [_headProgress setTrackTintColor: [UIColor whiteColor]];
    [_headProgress setProgress:0.0f / NUMBER_STEP animated:YES];
    [_headMenu addSubview: _headProgress];
    
    CGFloat offset = PPScreenWidth() / NUMBER_STEP;
    float poXMid = offset / 2;
    float midYPos = STATUSBAR_HEIGHT + height_nav_bar / 2;
    
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(offset, STATUSBAR_HEIGHT, height_nav_bar, height_nav_bar)];
    CGRectSetSize(_closeButton.frame, CGSizeMake(height_nav_bar, height_nav_bar));
    [_closeButton setCenter:CGPointMake(poXMid, midYPos)];
    [_closeButton setImage:[UIImage imageNamed:@"navbar-cross"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeSignup) forControlEvents:UIControlEventTouchUpInside];
    [_headMenu addSubview:_closeButton];
    
    
    FLStartItem *item3 = [FLStartItem newWithTitle:@"" imageImageName:@"field-name" contentText:@"" andSize:height_nav_bar];
    CGRectSetSize(item3.frame, CGSizeMake(height_nav_bar, height_nav_bar));
    poXMid += offset;
    [item3 setCenter:CGPointMake(poXMid, midYPos)];
    [_headMenu addSubview:item3];
    

    FLStartItem *item4 = [FLStartItem newWithTitle:@"" imageImageName:@"field-password" contentText:@"" andSize:height_nav_bar];
    CGRectSetSize(item4.frame, CGSizeMake(height_nav_bar, height_nav_bar));
    poXMid += offset;
    [item4 setCenter:CGPointMake(poXMid, midYPos)];
    [_headMenu addSubview:item4];

    
    FLStartItem *item5 = [FLStartItem newWithTitle:@"" imageImageName:@"payment-field-card-selected" contentText:@"" andSize:height_nav_bar];
    CGRectSetSize(item5.frame, CGSizeMake(height_nav_bar, height_nav_bar));
    poXMid += offset;
    [item5 setCenter:CGPointMake(poXMid, midYPos)];
    [_headMenu addSubview:item5];
    
    
    FLStartItem *item6 = [FLStartItem newWithTitle:@"" imageImageName:@"field-rib" contentText:@"" andSize:height_nav_bar];
    CGRectSetSize(item6.frame, CGSizeMake(height_nav_bar, height_nav_bar));
    poXMid += offset;
    [item6 setCenter:CGPointMake(poXMid, midYPos)];
    [_headMenu addSubview:item6];
    
    
    [self setScrollEnabled:NO forPageViewController:_pageViewController];
    _indexPage = SignupPageTuto;
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

- (void) closeSignup {
    [self.userInfoDico removeAllObjects];
    [[Flooz sharedInstance] disconnectFacebook];
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

- (void)goToNextPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico {
    self.userInfoDico = userDico;
    if (currentIndex+1 >= NUMBER_OF_PAGES) {
        [appDelegate goToAccountViewController];
        return;
    }
    _indexPage = currentIndex+1;
    [self presentNewViewSignup:UIPageViewControllerNavigationDirectionForward];
}

- (void)goToPreviousPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico {
    self.userInfoDico = userDico;
    if (currentIndex-1 == 0) {
        return;
    }
    _indexPage = currentIndex-1;
    [self presentNewViewSignup:UIPageViewControllerNavigationDirectionReverse];
}

- (void)phoneNotRegistered:(NSDictionary *)user {
    [self.userInfoDico addEntriesFromDictionary:user];
    [_headProgress setProgress:((SignupPagePhone-1) / 7.0f) animated:YES];
    _indexPage = SignupPagePseudo;
    [self presentNewViewSignup:UIPageViewControllerNavigationDirectionForward];
}

- (void)signupWithFacebookUser:(NSDictionary *)user {
    [self.userInfoDico addEntriesFromDictionary:user];
    _indexPage = SignupPageInfo;
    FirstLaunchContentViewController *newView = [self viewControllerAtIndex:_indexPage];
    [newView setUserInfoDico:self.userInfoDico];
    [newView displayChanges];
}

- (void) presentNewViewSignup:(UIPageViewControllerNavigationDirection)direction {
    if (direction == UIPageViewControllerNavigationDirectionForward) {
        [self manageProgressBar];
    }
    else {
        [self manageProgressBar];
    }
    FirstLaunchContentViewController *newView = [self viewControllerAtIndex:_indexPage];
    if (newView) {
        [newView setUserInfoDico:self.userInfoDico];
        [self.pageViewController setViewControllers:@[newView]
                                          direction:direction
                                           animated:YES
                                         completion:^(BOOL finished) {
                                             if (finished) {
                                             }
                                         }];
    }
}

- (void) manageProgressBar {
    float pro;
    if (_indexPage == SignupPagePhone) {
        pro = 1.0f / NUMBER_STEP;
    }
    else if (_indexPage == SignupPagePseudo) {
        pro = 1.0f / NUMBER_STEP;
    }
    else if (_indexPage == SignupPageInfo) {
        pro = 1.5f / NUMBER_STEP;
    }
    else if (_indexPage == SignupPagePassword) {
        pro = 2.0f / NUMBER_STEP;
    }
    else if (_indexPage == SignupPageCode) {
        pro = 2.5f / NUMBER_STEP;
    }
    else if (_indexPage == SignupPageCodeVerif) {
        pro = 2.75f / NUMBER_STEP;
    }
    else if (_indexPage == SignupPageCB) {
        pro = 3.0f / NUMBER_STEP;
    }
    else if (_indexPage == SignupPageFriends) {
        pro = 4.0f / NUMBER_STEP;
    }
    else {
        pro = NUMBER_STEP / NUMBER_STEP;
    }
    [_headProgress setProgress:pro animated:YES];
    
    [_closeButton setEnabled:YES];
    if (_indexPage > SignupPagePassword) {
        [_closeButton setEnabled:NO];
    }
    
    if (_indexPage < SignupPagePseudo) {
        if (CGRectGetMaxY(_headMenu.frame) > 0) {
            [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                CGRectSetY(_headMenu.frame, -CGRectGetHeight(_headMenu.frame));
            } completion:nil];
        }
    }
    else {
        if (CGRectGetMinY(_headMenu.frame) < 0) {
            
            [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                CGRectSetY(_headMenu.frame, 0);
            } completion:nil];
        }
    }
}

@end
