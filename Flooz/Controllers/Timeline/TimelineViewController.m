//
//  TimelineViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "TimelineViewController.h"

#import "TransactionCell.h"

#import "MenuNewTransactionViewController.h"
#import "NewTransactionViewController.h"
#import "TransactionViewController.h"
#import "NotificationsViewController.h"
#import "FriendPickerViewController.h"
#import "AppDelegate.h"
#import "FLBadgeView.h"
#import "TransitionDelegate.h"

#define RATIO_TITLE_CONTENT 2.6
#define FADE_EFFECT_RATIO 1.2
#define OFFSET_BETWEEN_TITLES (CGRectGetWidth(self.navigationItem.titleView.frame) / RATIO_TITLE_CONTENT)
#define WIDTH_TITLE_VIEW (PPScreenWidth() - 52.0f * 2.0f)

@implementation TestScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[TestScrollView class]]) {
        TestScrollView *ts = (TestScrollView *)gestureRecognizer.view;
        CGFloat xVelocity = fabs([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ? [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view].x : 0.0f);

        CGFloat yVelocity = fabs([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ? [(UIPanGestureRecognizer*)gestureRecognizer velocityInView:gestureRecognizer.view].y : 0.0f);

        CGFloat xTranslation = fabs([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ? [(UIPanGestureRecognizer*)gestureRecognizer translationInView:gestureRecognizer.view].x : 0.0f);

        CGFloat yTranslation = fabs([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] ? [(UIPanGestureRecognizer*)gestureRecognizer translationInView:gestureRecognizer.view].y : 0.0f);
        
        if ([otherGestureRecognizer.view isKindOfClass:[FLTableView class]]) {
            FLTableView *v = (FLTableView *)otherGestureRecognizer.view;
            
            if (xTranslation > yTranslation && xVelocity > yVelocity && yTranslation == 0)
            {
                if (ts.contentOffset.x == 0 || ts.contentOffset.x == PPScreenWidth() || ts.contentOffset.x == PPScreenWidth() * 2)
                    return YES;
                else {
                    v.scrollEnabled = NO;
                    v.scrollEnabled = YES;
                    return NO;
                }
            }
            else if (yTranslation > 0)
                return NO;
        }
    }
    return YES;
}

@end

@implementation TimelineViewController {
	TestScrollView *_scrollView;
	UILabel *_titleLabel;

	CGFloat posXBase;
	CGFloat posXPosition;

	UIButton *_crossButton;
	NSMutableArray *_viewControllers;

	UIView *_titlesView;
	TimelineFilter selectedTitleIndex;
	NSMutableArray *_digitArray;
    
    FLBadgeView *_badge;
    NSTimer *_timer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = NSLocalizedString(@"NAV_TIMELINE", nil);
		_viewControllers = [NSMutableArray new];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	UIImageView *shadow = [UIImageView imageNamed:@"tableview-shadow"];
	CGRectSetY(shadow.frame, self.view.frame.size.height - shadow.frame.size.height);
	[self.view addSubview:shadow];


	posXPosition = 0.0f;
	posXBase = 0.0f;
    
    CGFloat height = PPScreenHeight() - NAVBAR_HEIGHT - PPStatusBarHeight();
    
	_scrollView = [[TestScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), height)];
	[_scrollView setBackgroundColor:[UIColor customBackground]];
	[_scrollView setScrollEnabled:YES];
	[_scrollView setBounces:YES];
	[_scrollView setPagingEnabled:YES];
	[_scrollView setDelegate:self];
	[self.view addSubview:_scrollView];

	{
		timelineFriend = [[FLTimelineTableViewController alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_scrollView.frame)) andFilter:@"friend"];
		[_viewControllers addObject:timelineFriend];
		[self displayContentController:timelineFriend];

		timelinePublic = [[FLTimelineTableViewController alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_scrollView.frame)) andFilter:@"public"];
		[_viewControllers addObject:timelinePublic];
		[self displayContentController:timelinePublic];

		timelinePrivate = [[FLTimelineTableViewController alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_scrollView.frame)) andFilter:@"private"];
		[_viewControllers addObject:timelinePrivate];
		[self displayContentController:timelinePrivate];
	}

	CGSize scrollableSize = CGSizeMake(CGRectGetWidth(_scrollView.frame) * _viewControllers.count, 0.0);
	[_scrollView setContentSize:scrollableSize];
    
	[self prepareCrossButton];
    [self prepareTitleViews];
    [self preparePin];
    [self addStackButton];
    
    [self registerNotification:@selector(reloadCurrentTimeline) name:kNotificationReloadTimeline object:nil];
}

- (void)reloadCurrentTimeline {
    [self reloadTable:selectedTitleIndex andFocus:NO];
}

- (void)displayContentController:(UIViewController *)content {
	[self addChildViewController:content];                 // 1
	CGRect frame = CGRectMake([_scrollView.subviews count] * PPScreenWidth(), 0.0f, CGRectGetWidth(_scrollView.frame), CGRectGetHeight(_scrollView.frame));
	content.view.frame = frame; // 2
	[_scrollView addSubview:content.view];
	[content didMoveToParentViewController:self];          // 3
}

- (void)hideContentController:(UIViewController *)content {
	[content willMoveToParentViewController:nil];  // 1
	[content.view removeFromSuperview];            // 2
	[content removeFromParentViewController];      // 3
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat pageWidth = scrollView.frame.size.width;
	float fractionalPage = scrollView.contentOffset.x / pageWidth;
	NSInteger page = lround(fractionalPage);
	if (selectedTitleIndex != page) {
		selectedTitleIndex = (TimelineFilter)page;
		[self updatePin];
		[self reloadTable:selectedTitleIndex andFocus:NO];
	}
	[self updateViewsPositions];
}

- (void)addStackButton {
	UIButton *butLeft = [UIButton buttonWithBackgroundImageName:@"navbar-left"];
   
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLeftView)];
    singleTap.numberOfTapsRequired = 1;
    [butLeft addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    doubleTap.numberOfTapsRequired = 2;
    [butLeft addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    {
        CGFloat sizeBadge = 20.0f;
        CGRect frame = CGRectMake(CGRectGetWidth(butLeft.frame) - sizeBadge / 2.0f - 2.0f, -5.0f, sizeBadge, sizeBadge);
        _badge = [[FLBadgeView alloc] initWithFrame:frame];
        [self reloadBadge];
        [butLeft addSubview: _badge];
    }
    
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:butLeft];
    
	UIButton *butRight = [UIButton buttonWithBackgroundImageName:@"navbar-right"];
	[butRight addTarget:self action:@selector(showRightView) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:butRight];
}

-(void)longPress:(UIGestureRecognizer *)longPress {
    UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:[NotificationsViewController new]];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)showLeftView {
    [[Flooz sharedInstance] updateCurrentUser];
	[appDelegate.revealSideViewController popLeftController];
}

- (void)showRightView {
    [[Flooz sharedInstance] updateCurrentUser];
    [appDelegate.revealSideViewController popRightController];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    posXBase = 0.0f;
    [self registerNotification:@selector(reloadBadge) name:@"newNotifications" object:nil];
    [self registerNotification:@selector(cancelTimer) name:kNotificationCancelTimer object:nil];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelTimer];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(showTuto) userInfo:nil repeats:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self cancelTimer];
}

- (void)cancelTimer {
    [_timer invalidate];
    _timer = nil;
}

-(void)showTuto {
    [appDelegate showTutoPage:TutoPageWelcome inController:self];
}

- (void)reloadBadge {
    NSNumber *numberNotif = [[Flooz sharedInstance] notificationsCount];
    [_badge setNumber:numberNotif];
    if ([numberNotif intValue] == 0) {
        [_badge setHidden:YES];
    }
    else {
        [_badge setHidden:NO];
    }
}

#pragma mark -

- (void)updateViewsPositions {
	posXPosition = posXBase - _scrollView.contentOffset.x / RATIO_TITLE_CONTENT;
    NSInteger index = 0;
	for (UILabel *view in[_titlesView subviews]) {
		if ([view isKindOfClass:[UILabel class]]) {
			CGRectSetX(view.frame, posXPosition + index * PPScreenWidth() / RATIO_TITLE_CONTENT);

			CGFloat progress = fabs(view.frame.origin.x / view.frame.size.width * 2.0f);
			view.layer.opacity = 1. - (progress * FADE_EFFECT_RATIO);
			index++;
		}
	}
}

- (void)prepareTitleViews {
	_titlesView = [[UIView alloc] initWithFrame:CGRectMake(52.0f, 0.0f, WIDTH_TITLE_VIEW, 40.0f)];
	self.navigationItem.titleView = _titlesView;

	for (UIViewController *controller in _viewControllers) {
		[self createLabelForController:controller];
	}

	selectedTitleIndex = TimelineFilterFriend;
	[self reloadTable:selectedTitleIndex andFocus:NO];
	[self updateViewsPositions];

    {
        UIImage *shad = [UIImage imageNamed:@"navbar-shadow-complete"];
        UIImageView *shadow = [UIImageView newWithImage:shad];
        CGRectSetWidth(shadow.frame, PPScreenWidth());
        CGRectSetHeight(shadow.frame, NAVBAR_HEIGHT - 4.0f);
        [self.navigationController.navigationBar addSubview:shadow];
    }
}

- (void)createLabelForController:(UIViewController *)controller {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f - 10.0f, WIDTH_TITLE_VIEW, NAVBAR_HEIGHT)];

	label.font = [UIFont customTitleNav];
	label.textAlignment = NSTextAlignmentCenter;
	label.textColor = [UIColor customBlue];
	label.text = controller.title;

	[_titlesView addSubview:label];
}

- (void)preparePin {
	_digitArray = [NSMutableArray new];

	UIView *pinView = [UIView newWithFrame:CGRectMake((CGRectGetWidth(_titlesView.frame) - 30.0f) / 2.0f, NAVBAR_HEIGHT - 20.0f, 30.0f, 10.0f)];
	[_titlesView addSubview:pinView];

	CGFloat x = 0.0f;
	CGFloat width = CGRectGetWidth(pinView.frame) / _viewControllers.count;
	CGFloat height = CGRectGetHeight(pinView.frame);

	for (int i = 0; i < _viewControllers.count; i++) {
		UILabel *l = [UILabel newWithFrame:CGRectMake(x, 0.0f, width, height)];
		[l setTextAlignment:NSTextAlignmentCenter];
		[l setFont:[UIFont customTitleBook:12]];
		[l setText:@"●"];

		[pinView addSubview:l];
		[_digitArray addObject:l];

		x += CGRectGetWidth(pinView.frame) / _viewControllers.count;
	}
	[self updatePin];
}

- (void)updatePin {
	NSInteger index = 0;
	for (UILabel *l in _digitArray) {
		if (index == selectedTitleIndex) {
			[l setTextColor:[UIColor customBlue]];
		}
		else {
            [l setTextColor:[UIColor colorWithIntegerRed:49 green:63 blue:78 alpha:1.0f]];
		}
		index++;
	}
}

#pragma mark - Cross button

- (void)prepareCrossButton {
	UIImage *buttonImage = [UIImage imageNamed:@"menu-new-transaction"];
	_crossButton = [[UIButton alloc] initWithFrame:CGRectMakeSize(buttonImage.size.width, buttonImage.size.height)];
	[_crossButton setImage:buttonImage forState:UIControlStateNormal];
	[self.view addSubview:_crossButton];

	CGFloat y = PPScreenHeight() - NAVBAR_HEIGHT - PPStatusBarHeight() - buttonImage.size.height - 20;
	CGRectSetY(_crossButton.frame, y);
	_crossButton.center = CGPointMake(PPScreenWidth() / 2.0f, _crossButton.center.y);

	[_crossButton addTarget:self action:@selector(didCrossButtonTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didCrossButtonTouch {
	[self presentMenuTransactionController];
}

- (void)presentMenuTransactionController {    
    FriendPickerViewController *friendsView = [FriendPickerViewController new];
    [friendsView setDictionary:[NSMutableDictionary new]];
    friendsView.isFirstView = YES;
    friendsView.previousController = (UINavigationController*)self.parentViewController;
    
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:friendsView];
    controller.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)reloadTable:(TimelineFilter)filter andFocus:(BOOL)focus {
    if (filter) {
        selectedTitleIndex = filter;
    }
	switch (filter) {
		case TimelineFilterPublic:
			[timelinePublic reloadTableView];
			break;

		case TimelineFilterFriend:
			[timelineFriend reloadTableView];
			break;

		case TimelineFilterPrivate:
			[timelinePrivate reloadTableView];
			break;

		default:
			break;
	}

	if (focus) {
		[self focusOnTimeline:filter];
	}
}

- (void)focusOnTimeline:(TimelineFilter)filter {
	[_scrollView setContentOffset:CGPointMake(PPScreenWidth() * filter, 0.0f)];
}

@end
