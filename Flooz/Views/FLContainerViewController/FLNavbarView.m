//
//  FLNavbarView.m
//  Flooz
//
//  Created by jonathan on 1/10/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLNavbarView.h"

#import "AppDelegate.h"
#import "AcitvitiesViewController.h"

#define STATUSBAR_HEIGHT 20.
#define NAVBAR_HEIGHT 44.
#define HEIGHT (STATUSBAR_HEIGHT + NAVBAR_HEIGHT)

#define RATIO_TITLE_CONTENT 2.
#define FADE_EFFECT_RATIO 1.2
#define OFFSET_BETWEEN_TITLES (CGRectGetWidth(self.frame) / RATIO_TITLE_CONTENT)

@implementation FLNavbarView

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super initWithFrame:CGRectMakeSize(SCREEN_WIDTH, HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor customBackgroundHeader];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFloozView) name:@"newNotifications" object:nil];
        
        [self preparePanGesture];
        [self prepareSwipeGesture];
        _viewControllers = viewControllers;
        [self prepareTitleViews];
    }
    return self;
}

- (void)preparePanGesture
{
    floozGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadActivitiesController)];
    floozGesture1.delegate = self;
    
    floozGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadActivitiesController)];
    floozGesture2.delegate = self;
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPanGesture:)];
    panGesture.delegate = self;
    [panGesture requireGestureRecognizerToFail:floozGesture1];
    [panGesture requireGestureRecognizerToFail:floozGesture2];
    [self addGestureRecognizer:panGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(respondToTapGesture:)];
    [tapGesture requireGestureRecognizerToFail:panGesture];
    [self addGestureRecognizer:tapGesture];
}

- (void)prepareSwipeGesture
{
    {
        swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(loadNextController)];
        swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [panGesture requireGestureRecognizerToFail:swipeGestureLeft];
        [self addGestureRecognizer:swipeGestureLeft];
    }
    {
        swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(loadPreviousController)];
        swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [panGesture requireGestureRecognizerToFail:swipeGestureRight];
        [self addGestureRecognizer:swipeGestureRight];
    }
}

- (void)prepareTitleViews
{
    _titlesView = [[UIView alloc] initWithFrame:self.frame];
    [self addSubview:_titlesView];
    
    for(UIViewController *controller in _viewControllers){
        [self createLabelForController:controller];
    }
    
    selectedTitleIndex = 1;
    [self updateViewsPositions];
    
    {
        UIImageView *shadow = [UIImageView imageNamed:@"navbar-shadow"];
        CGRectSetY(shadow.frame, STATUSBAR_HEIGHT);
        [self addSubview:shadow];
    }
}

- (void)createLabelForController:(UIViewController *)controller
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT - 4, CGRectGetWidth(self.frame), NAVBAR_HEIGHT)];
    
    label.font = [UIFont customTitleExtraLight:28];
    label.textColor = [UIColor customBlue];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = controller.title;
    
    [_titlesView addSubview:label];
    
    if([[_titlesView subviews] count] == 2){
        floozContianerView = label;
        floozContianerView.userInteractionEnabled = YES;
    
        {
            floozCountView = [[UILabel alloc] initWithFrame:CGRectMakeSize(22, 22)];
            CGRectSetY(floozCountView.frame, ((CGRectGetHeight(floozContianerView.frame) - CGRectGetHeight(floozCountView.frame)) / 2.) + 1);
            
            floozCountView.backgroundColor = [UIColor customBlue];
            floozCountView.textColor = [UIColor whiteColor];
            floozCountView.textAlignment = NSTextAlignmentCenter;
            floozCountView.font = [UIFont customTitleExtraLight:13];
            
            floozCountView.clipsToBounds = YES;
//            floozCountView.layer.borderColor = [UIColor whiteColor].CGColor;
//            floozCountView.layer.borderWidth = 1;
            floozCountView.layer.cornerRadius = CGRectGetHeight(floozCountView.frame) / 2.;
            
            [floozContianerView addSubview:floozCountView];
        }
        
        {
            floozTextView = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(floozContianerView.frame.size)];
            floozTextView.text = floozContianerView.text;
            floozContianerView.text = nil;
            floozTextView.font = floozContianerView.font;
            
            [floozContianerView addSubview:floozTextView];
        }
        
        {
            [floozTextView setWidthToFit];

            CGFloat spacing = 5.;
            CGFloat width = CGRectGetWidth(floozCountView.frame) + CGRectGetWidth(floozTextView.frame);
            
            CGRectSetX(floozCountView.frame, (CGRectGetWidth(floozContianerView.frame) - width - spacing) / 2.);
            CGRectSetX(floozTextView.frame, CGRectGetMaxX(floozCountView.frame) + spacing);
        }
        
        {
            floozCountView.userInteractionEnabled = YES;
            [floozCountView addGestureRecognizer:floozGesture1];
            
            floozTextView.userInteractionEnabled = YES;
            [floozTextView addGestureRecognizer:floozGesture2];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]){
        return selectedTitleIndex == 1;
    }
    else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint translation = [recognizer translationInView:_titlesView];
        
        if(translation.x > 0 && selectedTitleIndex == 0){
            return NO;
        }
        else if(translation.x < 0 && selectedTitleIndex == [[_titlesView subviews] count] - 1){
            return NO;
        }
    }
    return YES;
}

- (void)respondToTapGesture:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    if(location.x < (CGRectGetWidth(self.frame) / 3.)){
        [self loadPreviousController];
    }
    else if(location.x > (CGRectGetWidth(self.frame) / 3. * 2)){
        [self loadNextController];
    }
}

- (void)respondToPanGesture:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            lastTranslation = CGPointZero;
//            for(UIViewController *controller in _viewControllers){
//                [controller beginAppearanceTransition:YES animated:YES];
//            }
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [recognizer translationInView:_titlesView];
            
            CGPoint diffTranslation = translation;
            diffTranslation.x -= lastTranslation.x;
            lastTranslation = translation;
            
            diffTranslation.x = diffTranslation.x * 0.7;
            
            [self moveViews:diffTranslation];
            break;
        }
        case UIGestureRecognizerStateEnded:
            [self completeTranslation];
            break;
        default:
            break;
    }
}

- (void)moveViews:(CGPoint)offset
{
    for(UIView *view in [_titlesView subviews]){
        view.frame = CGRectOffset(view.frame, offset.x, 0);
    }
    for(UIViewController *controller in _viewControllers){
        controller.view.frame = CGRectOffset(controller.view.frame, offset.x * RATIO_TITLE_CONTENT, 0);
        
        CGFloat progress = fabs(controller.view.frame.origin.x / CGRectGetWidth(self.frame));
        controller.view.layer.opacity = 1. - (progress * FADE_EFFECT_RATIO);
    }
}

- (void)updateViewsPositions
{
    NSInteger index = 0;
    for(UIView *view in [_titlesView subviews]){
        CGRectSetX(view.frame, OFFSET_BETWEEN_TITLES * (index - selectedTitleIndex));
        index++;
    }
    
    index = 0;
    for(UIViewController *controller in _viewControllers){
        CGRectSetX(controller.view.frame, CGRectGetWidth(self.frame) * (index - selectedTitleIndex));
        index++;
        
        CGFloat progress = fabs(controller.view.frame.origin.x / CGRectGetWidth(self.frame));
        controller.view.layer.opacity = 1. - (progress * FADE_EFFECT_RATIO);
    }
    
    for(UILabel *titleView in [_titlesView subviews]){
        titleView.textColor = [UIColor customBlueLight];
    }
    
    UILabel *selectedTitleView = [[_titlesView subviews] objectAtIndex:selectedTitleIndex];
    selectedTitleView.textColor = [UIColor customBlue];
    
    [self refreshFloozView];
}

- (void)refreshFloozView
{
    floozCountView.text = [[[[Flooz sharedInstance] currentUser] notificationsCount] stringValue];
    floozTextView.textColor = floozContianerView.textColor;
}

- (void)completeTranslation
{
    CGPoint positionFirstTitle = [[[_titlesView subviews] objectAtIndex:0] frame].origin;
    CGFloat screenWidth = CGRectGetWidth(self.frame);
    
    NSInteger newSelectedTitleIndex = roundf(((positionFirstTitle.x * -1.0) / (screenWidth / RATIO_TITLE_CONTENT)));
    newSelectedTitleIndex = MAX(newSelectedTitleIndex, 0);
    newSelectedTitleIndex = MIN(newSelectedTitleIndex, [[_titlesView subviews] count] - 1);

    [self loadControllerWithIndex:newSelectedTitleIndex];
}

- (void)loadPreviousController
{
    [self loadControllerWithIndex:(selectedTitleIndex - 1)];
}

- (void)loadNextController
{
    [self loadControllerWithIndex:(selectedTitleIndex + 1)];
}

- (void)loadControllerWithIndex:(NSInteger)index
{
    if(index < 0 || index >= [[_titlesView subviews] count]){
        return;
    }
    
    selectedTitleIndex = index;
 
    [UIView animateWithDuration:0.3
                          delay:0
                        options:0
                     animations:^{
                         [self updateViewsPositions];
                         
//                         for(UIViewController *controller in _viewControllers){
//                             [controller endAppearanceTransition];
//                         }
                     } completion:NULL];
}

- (void)loadActivitiesController
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[AcitvitiesViewController new]];
//    AcitvitiesViewController *controller = [AcitvitiesViewController new];
    UIViewController *rootController = appDelegate.window.rootViewController;
    
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;

    [rootController presentViewController:controller animated:NO completion:^{
        rootController.modalPresentationStyle = UIModalPresentationFullScreen;
    }];
}

@end
