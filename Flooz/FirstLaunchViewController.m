//
//  FirstLaunchViewController.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FirstLaunchViewController.h"

#import "AppDelegate.h"

#define NUMBER_STEP 5.0f

@interface FirstLaunchViewController ()
{
	NSMutableArray *_tutorialsView;

	NSInteger _indexPage;
	NSInteger _indexPageStart;
}

@property (strong, nonatomic) UIButton *nextArrow;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

@implementation FirstLaunchViewController

- (id)initWithSpecificPage:(SignupOrderPage)index {
	self = [super init];
	if (self) {
		_indexPage = index;
		_indexPageStart = 0;
	}
	return self;
}

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
	for (int i = 0; i <= NUMBER_OF_PAGES; i++) {
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

	[self setScrollEnabled:NO forPageViewController:_pageViewController];
	if (!_indexPage) {
		_indexPage = SignupPagePhone;
		_indexPageStart = 0;
	}

	SignupViewController *newView = [self viewControllerAtIndex:_indexPage];
	if (newView) {
		[newView setUserInfoDico:self.userInfoDico];
		[self.pageViewController setViewControllers:@[newView] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES];
}

- (void)setScrollEnabled:(BOOL)enabled forPageViewController:(UIPageViewController *)pageViewController {
	for (UIView *view in pageViewController.view.subviews) {
		if ([view isKindOfClass:[UIScrollView class]]) {
			UIScrollView *scrollView = (UIScrollView *)view;
			[scrollView setScrollEnabled:enabled];
			return;
		}
	}
}

- (SignupViewController *)viewControllerAtIndex:(NSUInteger)index {
	// Return the data view controller for the given index.
	if (index >= NUMBER_OF_PAGES) {
		return nil;
	}

	id controller = _tutorialsView[index];
	if ([controller isEqual:[NSNull null]]) {
		SignupViewController *detailNewsViewController = [SignupViewController new];
		detailNewsViewController.delegate = self;
		detailNewsViewController.pageIndex = index;
		detailNewsViewController.pageIndexStart = _indexPageStart;
		_pageViewController.view.frame = detailNewsViewController.view.frame;
		controller = detailNewsViewController;
		_tutorialsView[index] = detailNewsViewController;
	}

	return controller;
}

- (void)closeSignup {
	[self.userInfoDico removeAllObjects];
	for (NSString *key in self.userInfoDico) {
		[self.userInfoDico setValue:@"" forKey:key];
	}
	for (SignupViewController *tutoContentVC in _tutorialsView) {
		if (![tutoContentVC isEqual:[NSNull null]]) {
			[tutoContentVC resetUserInfoDico];
		}
	}
	[[FBSession activeSession] closeAndClearTokenInformation];
	_indexPage = SignupPagePhone;
	_indexPageStart = _indexPage;
	[self presentNewViewSignup:UIPageViewControllerNavigationDirectionReverse];
}

#pragma mark - UIPageViewController - Delegate - Datasource

- (SignupViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(SignupViewController *)viewController {
	return [self viewControllerAtIndex:viewController.pageIndex + 1];
}

- (SignupViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(SignupViewController *)viewController {
	return [self viewControllerAtIndex:viewController.pageIndex - 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
}

- (void)goToNextPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico {
	self.userInfoDico = userDico;
	if (currentIndex + 1 >= NUMBER_OF_PAGES) {
		[self leaveSignup];
	}
	else {
		_indexPage = currentIndex + 1;
		_indexPageStart++;
		[self presentNewViewSignup:UIPageViewControllerNavigationDirectionForward];
	}
}

- (void)goToPreviousPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico {
	self.userInfoDico = userDico;
	if (currentIndex == 0 || _indexPageStart == 0) {
		[appDelegate displayHome];
		return;
	}
	_indexPage = currentIndex - 1;
	_indexPageStart--;
	[self presentNewViewSignup:UIPageViewControllerNavigationDirectionReverse];
}

- (void)phoneNotRegistered:(NSDictionary *)user {
	//[self.userInfoDico ]
	[self.userInfoDico addEntriesFromDictionary:user];
    self.userInfoDico[@"distinctId"] = [Mixpanel sharedInstance].distinctId;
	_indexPage = SignupPagePseudo;
	_indexPageStart++;
	[self presentNewViewSignup:UIPageViewControllerNavigationDirectionForward];
}

- (void)signupWithFacebookUser:(NSDictionary *)user {
	[self.userInfoDico addEntriesFromDictionary:user];
	_indexPage = SignupPagePhoto;
	SignupViewController *newView = [self viewControllerAtIndex:_indexPage];
	[newView setUserInfoDico:self.userInfoDico];
	[newView displayChanges];
}

- (void)signupAfter3DSecure:(NSDictionary *)user {
    [[Flooz sharedInstance] hideLoadView];
    [self.userInfoDico addEntriesFromDictionary:user];
    _indexPage = SignupPageAskAccess;
    [self presentNewViewSignup:UIPageViewControllerNavigationDirectionForward];
}

- (void)signupFriendUser:(NSDictionary *)user {
	[self.userInfoDico addEntriesFromDictionary:user];
	_indexPage = SignupPageFriends;
	SignupViewController *newView = [self viewControllerAtIndex:_indexPage];
	[newView setUserInfoDico:self.userInfoDico];
	[newView displayChanges];
}

- (void)leaveSignup {
	[appDelegate goToAccountViewController];
}

- (void)presentNewViewSignup:(UIPageViewControllerNavigationDirection)direction {
	SignupViewController *newView = [self viewControllerAtIndex:_indexPage];
	if (newView) {
		[newView setUserInfoDico:self.userInfoDico];
		[self.pageViewController setViewControllers:@[newView]
		                                  direction:direction
		                                   animated:YES
		                                 completion: ^(BOOL finished) {
		    if (finished) {
			}
		}];
	}
}

- (void)ignorePage {
	[self goToNextPage:_indexPage withUser:self.userInfoDico];
}

- (void)backPage {
	[self goToPreviousPage:_indexPage withUser:self.userInfoDico];
}

@end
