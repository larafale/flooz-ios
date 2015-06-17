//
//  TimelineViewController.m
//  Flooz
//
//  Created by olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "TimelineViewController.h"

#import "TransactionCell.h"

#import "NewTransactionViewController.h"
#import "TransactionViewController.h"
#import "NotificationsViewController.h"
#import "FriendPickerViewController.h"
#import "AppDelegate.h"
#import "FLBadgeView.h"
#import "TransitionDelegate.h"
#import "FLTutoPopoverViewController.h"
#import "FLPopoverTutoTheme.h"

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
    
    FLTutoPopoverViewController *tutoPopover;
    WYPopoverController *popoverController;
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
    [self cancelTimer];
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
    [self cancelTimer];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelTimer];
    popoverController = nil;
    tutoPopover = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [appDelegate handlePendingData];
    
    BOOL reloadTimeline = NO;
    
    NSArray *visibleIndexes;
    
    if (selectedTitleIndex == TimelineFilterFriend)
        visibleIndexes = [timelineFriend.tableView indexPathsForVisibleRows];
    else if (selectedTitleIndex == TimelineFilterPublic)
        visibleIndexes = [timelinePublic.tableView indexPathsForVisibleRows];
    else if (selectedTitleIndex == TimelineFilterPrivate)
        visibleIndexes = [timelinePrivate.tableView indexPathsForVisibleRows];
    
    if ([[visibleIndexes lastObject] row] <= [[Flooz sharedInstance] timelinePageSize])
        reloadTimeline = YES;
    
    if (reloadTimeline)
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(reloadCurrentTimeline) userInfo:nil repeats:NO];
    
    [self registerNotification:@selector(reloadBadge) name:@"newNotifications" object:nil];
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
    [self cancelTimer];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kKeyTutoWelcome]) {
        [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoWelcome];
        tutoPopover = [[FLTutoPopoverViewController alloc] initWithTitle:NSLocalizedString(@"TUTO_WELCOME_TITLE", nil) message:NSLocalizedString(@"TUTO_WELCOME_MSG", nil) button:NSLocalizedString(@"GLOBAL_GOTIT", nil) action:^(FLTutoPopoverViewController *viewController) {
            [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
                [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoTimelineFriends];
                tutoPopover = [[FLTutoPopoverViewController alloc] initWithTitle:NSLocalizedString(@"TUTO_FRIENDS_TITLE", nil) message:NSLocalizedString(@"TUTO_FRIENDS_MSG", nil) button:NSLocalizedString(@"GLOBAL_GOTIT", nil) action:^(FLTutoPopoverViewController *viewController) {
                    [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
                    }];
                }];
                popoverController = [[WYPopoverController alloc] initWithContentViewController:tutoPopover];
                [popoverController setTheme:[FLPopoverTutoTheme theme]];
                [popoverController setDelegate:self];
                
                [popoverController presentPopoverFromRect:_titlesView.bounds inView:_titlesView permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:nil];
            }];
        }];
        popoverController = [[WYPopoverController alloc] initWithContentViewController:tutoPopover];
        [popoverController setTheme:[FLPopoverTutoTheme theme]];
        [popoverController setDelegate:self];
        
        [popoverController presentPopoverFromRect:_crossButton.bounds inView:_crossButton permittedArrowDirections:WYPopoverArrowDirectionDown animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:nil];
    }
}

- (void)showTutoPublic {
    [self cancelTimer];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kKeyTutoTimelinePublic]) {
        [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoTimelinePublic];
        tutoPopover = [[FLTutoPopoverViewController alloc] initWithTitle:NSLocalizedString(@"TUTO_PUBLIC_TITLE", nil) message:NSLocalizedString(@"TUTO_PUBLIC_MSG", nil) button:NSLocalizedString(@"GLOBAL_GOTIT", nil) action:^(FLTutoPopoverViewController *viewController) {
            [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
            }];
        }];
        popoverController = [[WYPopoverController alloc] initWithContentViewController:tutoPopover];
        [popoverController setTheme:[FLPopoverTutoTheme theme]];
        [popoverController setDelegate:self];
        
        [popoverController presentPopoverFromRect:_titlesView.bounds inView:_titlesView permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:nil];
    }
}

- (void)showTutoPrivate {
    [self cancelTimer];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:kKeyTutoTimelinePrivate]) {
        [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoTimelinePrivate];
        tutoPopover = [[FLTutoPopoverViewController alloc] initWithTitle:NSLocalizedString(@"TUTO_PRIVATE_TITLE", nil) message:NSLocalizedString(@"TUTO_PRIVATE_MSG", nil) button:NSLocalizedString(@"GLOBAL_GOTIT", nil) action:^(FLTutoPopoverViewController *viewController) {
            [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
            }];
        }];
        popoverController = [[WYPopoverController alloc] initWithContentViewController:tutoPopover];
        [popoverController setTheme:[FLPopoverTutoTheme theme]];
        [popoverController setDelegate:self];
        
        [popoverController presentPopoverFromRect:_titlesView.bounds inView:_titlesView permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:nil];
    }
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

#pragma mark - popover delegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    if ([((FLTutoPopoverViewController*)controller.contentViewController).titleString isEqualToString:NSLocalizedString(@"TUTO_WELCOME_TITLE", nil)]) {
        [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoTimelineFriends];
        tutoPopover = [[FLTutoPopoverViewController alloc] initWithTitle:NSLocalizedString(@"TUTO_FRIENDS_TITLE", nil) message:NSLocalizedString(@"TUTO_FRIENDS_MSG", nil) button:NSLocalizedString(@"GLOBAL_GOTIT", nil) action:^(FLTutoPopoverViewController *viewController) {
            [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
            }];
        }];
        popoverController = [[WYPopoverController alloc] initWithContentViewController:tutoPopover];
        [popoverController setTheme:[FLPopoverTutoTheme theme]];
        [popoverController setDelegate:self];
        
        [popoverController presentPopoverFromRect:_titlesView.bounds inView:_titlesView permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:nil];
    }
    [self cancelTimer];
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
    [_titlesView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNextPage)]];
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
    [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:NO completionHandler:nil];
    
    NSDictionary *ux = [[[Flooz sharedInstance] currentUser] ux];
    if (ux && ux[@"homeButton"] && [ux[@"homeButton"] count] > 0) {
        NSArray *triggers = ux[@"homeButton"];
        for (NSDictionary *triggerData in triggers) {
            FLTrigger *trigger = [[FLTrigger alloc] initWithJson:triggerData];
            [[Flooz sharedInstance] handleTrigger:trigger];
        }
    } else {
        NewTransactionViewController *newTransac = [[NewTransactionViewController alloc] initWithTransactionType:TransactionTypeBase];
        
        FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:newTransac];
        controller.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)showNextPage {
    if (selectedTitleIndex == TimelineFilterFriend)
        [self smoothFocusOnTimeline:TimelineFilterPublic];
    else if (selectedTitleIndex == TimelineFilterPublic)
        [self smoothFocusOnTimeline:TimelineFilterPrivate];
    else if (selectedTitleIndex == TimelineFilterPrivate)
        [self smoothFocusOnTimeline:TimelineFilterFriend];
}

- (void)reloadTable:(TimelineFilter)filter andFocus:(BOOL)focus {
    BOOL tutoAvalaible;
    switch (filter) {
        case TimelineFilterPublic:
            if (!_timer && ![[NSUserDefaults standardUserDefaults] boolForKey:kKeyTutoTimelinePublic] && selectedTitleIndex == filter && [[appDelegate myTopViewController] isKindOfClass:[FLRevealContainerViewController class]]) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showTutoPublic) userInfo:nil repeats:NO];
            }
            [timelinePublic reloadTableView];
            break;
            
        case TimelineFilterFriend:
            tutoAvalaible = [[NSUserDefaults standardUserDefaults] boolForKey:kKeyTutoWelcome];
            if (!_timer && !tutoAvalaible && selectedTitleIndex == filter && [[appDelegate myTopViewController] isKindOfClass:[FLRevealContainerViewController class]]) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showTuto) userInfo:nil repeats:NO];
            }
            [timelineFriend reloadTableView];
            break;
            
        case TimelineFilterPrivate:
            if (!_timer && ![[NSUserDefaults standardUserDefaults] boolForKey:kKeyTutoTimelinePrivate] && selectedTitleIndex == filter && [[appDelegate myTopViewController] isKindOfClass:[FLRevealContainerViewController class]]) {
                _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showTutoPrivate) userInfo:nil repeats:NO];
            }
            [timelinePrivate reloadTableView];
            break;
            
        default:
            break;
    }
    if (filter) {
        selectedTitleIndex = filter;
    }
    
    if (focus) {
        [self focusOnTimeline:filter];
    }
}

- (void)focusOnTimeline:(TimelineFilter)filter {
    [_scrollView setContentOffset:CGPointMake(PPScreenWidth() * filter, 0.0f)];
}

- (void)smoothFocusOnTimeline:(TimelineFilter)filter {
    [_scrollView setContentOffset:CGPointMake(PPScreenWidth() * filter, 0.0f) animated:YES];
}

@end
