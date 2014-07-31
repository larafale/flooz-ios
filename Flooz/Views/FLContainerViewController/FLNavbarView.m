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

#import "FLContainerViewController.h"

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
        _viewControllers = viewControllers;
        [self prepareTitleViews];
        
        for(UIViewController *controller in viewControllers){
            [self createPanGestureForController:controller];
        }
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    [self refreshFloozView];
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
            floozCountView = [[UILabel alloc] initWithFrame:CGRectMakeSize(16, 16)];
            CGRectSetY(floozCountView.frame, ((CGRectGetHeight(floozContianerView.frame) - CGRectGetHeight(floozCountView.frame)) / 2.) - 3);
            
            floozCountView.backgroundColor = [UIColor customBackgroundHeader];
            floozCountView.textColor = [UIColor customBlue];
            floozCountView.textAlignment = NSTextAlignmentCenter;
            floozCountView.font = [UIFont customTitleExtraLight:9];
            
            floozCountView.clipsToBounds = YES;
            floozCountView.layer.borderColor = [UIColor customBlue].CGColor;
            floozCountView.layer.borderWidth = 1;
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

//            CGFloat spacing = 5.;
//            CGFloat width = CGRectGetWidth(floozCountView.frame) + CGRectGetWidth(floozTextView.frame);
//            CGRectSetX(floozCountView.frame, (CGRectGetWidth(floozContianerView.frame) - width - spacing) / 2.);
//            CGRectSetX(floozTextView.frame, CGRectGetMaxX(floozCountView.frame) + spacing);
            
            CGRectSetX(floozTextView.frame, (CGRectGetWidth(floozContianerView.frame) - CGRectGetWidth(floozTextView.frame)) / 2.);
            CGRectSetX(floozCountView.frame, CGRectGetMaxX(floozTextView.frame) + 3);
            
            // Hack pour le click sous le rond bleu
            CGRectSetWidth(floozTextView.frame, CGRectGetWidth(floozTextView.frame) + 30);
        }
        
        {
            floozArrowView = [UIImageView imageNamed:@"arrow-blue-down"];
            [floozCountView addSubview:floozArrowView];
            floozArrowView.center = CGRectGetFrameCenter(floozCountView.frame);
        }
        
        {
            
            
            floozCountView.userInteractionEnabled = YES;
            [floozCountView addGestureRecognizer:floozGesture1];
            
            floozTextView.userInteractionEnabled = YES;
            [floozTextView addGestureRecognizer:floozGesture2];
        }
        
        {
            notificationsAnimation = [FLWaveAnimation new];
            notificationsAnimation.view = floozTextView;
            notificationsAnimation.backgroundColor = [UIColor customBlue:.3];
            notificationsAnimation.foregroundColor = [UIColor customBlue];
            notificationsAnimation.repeatCount = HUGE_VALF;
        }
    }
}

- (void)createPanGestureForController:(UIViewController *)controller
{
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPanGesture:)];
    gesture.delegate = self;
    [controller.view addGestureRecognizer:gesture];
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
        [self beginTransition];
        [self loadPreviousController];
    }
    else if(location.x > (CGRectGetWidth(self.frame) / 3. * 2)){
        [self beginTransition];
        [self loadNextController];
    }
}

- (void)respondToPanGesture:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            lastTranslation = CGPointZero;
            [self beginTransition];
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [recognizer translationInView:_titlesView];
                        
            CGPoint diffTranslation = translation;
            diffTranslation.x -= lastTranslation.x;
            lastTranslation = translation;
            
            diffTranslation.x = diffTranslation.x * 0.5; // 0.5 permet de faire en sorte que la vue et le doigt se suivent, pb retina?
            
            {
                UIView *firstView = [[_viewControllers firstObject] view];
                UIView *lastView = [[_viewControllers lastObject] view];
                
                if(firstView.frame.origin.x > 0 || lastView.frame.origin.x < 0){
                    diffTranslation.x = 0;
                }
            }
            
            [self moveViews:diffTranslation];
            break;
        }
        case UIGestureRecognizerStateEnded:{
            CGPoint velocity = [recognizer velocityInView:_titlesView];
            [self completeTranslation:velocity];
            break;
        }
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
    [self refreshCrossButton];
}

- (void)refreshFloozView
{
    floozCountView.text = [[[Flooz sharedInstance] notificationsCount] stringValue];
    floozTextView.textColor = floozContianerView.textColor;
    
//    if([[[Flooz sharedInstance] notificationsCount] isEqualToNumber:@0]){
//        floozCountView.hidden = YES;
//    }
//    else{
//        floozCountView.hidden = NO;
//    }
    
    // WARNING Test hack, bug sur ios 7.0 click ne fonctionne pas
    floozTextView.userInteractionEnabled = YES;
    
    [notificationsAnimation stop];
    
    if([[[Flooz sharedInstance] notificationsCount] isEqualToNumber:@0]){
        floozCountView.text = @"";
        floozArrowView.hidden = NO;
    }
    else{
        floozArrowView.hidden = YES;
        [notificationsAnimation start];
    }
}

- (void)refreshCrossButton
{
    UIViewController *controller = _viewControllers[1];
    CGFloat y = SCREEN_WIDTH / 2.;
    
    if(controller.view.frame.origin.x > 0){
        y += controller.view.frame.origin.x;
    }
    else if(controller.view.frame.origin.x < 0){
        y += controller.view.frame.origin.x;
    }
    
    crossButton.center = CGPointMake(y, crossButton.center.y);
}

- (void)completeTranslation:(CGPoint)velocity
{
    CGPoint positionFirstTitle = [[[_titlesView subviews] objectAtIndex:0] frame].origin;
    CGFloat screenWidth = CGRectGetWidth(self.frame);
    
    NSInteger newSelectedTitleIndex = roundf(((positionFirstTitle.x * -1.0) / (screenWidth / RATIO_TITLE_CONTENT)));
    
    if(selectedTitleIndex == newSelectedTitleIndex){
        if(velocity.x > 150){
            newSelectedTitleIndex--;
        }
        else if(velocity.x < -150){
            newSelectedTitleIndex++;
        }
    }
    
    newSelectedTitleIndex = MAX(newSelectedTitleIndex, 0);
    newSelectedTitleIndex = MIN(newSelectedTitleIndex, [[_titlesView subviews] count] - 1);
    
    [self loadControllerWithIndex:newSelectedTitleIndex velocity:velocity.x];
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
    [self loadControllerWithIndex:index velocity:600];
}

- (void)loadControllerWithIndex:(NSInteger)index velocity:(CGFloat)velocity
{
    if(index < 0 || index >= [[_titlesView subviews] count]){
        return;
    }
  
    UILabel *selectedTitleView = [[_titlesView subviews] objectAtIndex:index];
    CGFloat distance = fabs(selectedTitleView.frame.origin.x);
    velocity *= .5; // Voir au dessus pb retina
    CGFloat duration = distance / velocity;
    
    duration = MIN(fabs(duration), .5); // fabs pck parfois devient negatif
    
    if(selectedTitleIndex == index){
        duration = 0.2;
    }
    
    selectedTitleIndex = index;
    
    [UIView animateWithDuration:duration // .4
                          delay:0
                        options:0
                     animations:^{
                         [self updateViewsPositions];
                         [self endTransition];
                     } completion:NULL];
}

- (void)loadActivitiesController
{
    FLNavigationController *controller = [[FLNavigationController alloc] initWithRootViewController:[AcitvitiesViewController new]];
    UIViewController *rootController = appDelegate.window.rootViewController;
    
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;

    [rootController presentViewController:controller animated:NO completion:^{
        rootController.modalPresentationStyle = UIModalPresentationFullScreen;
    }];
}

#pragma mark - Cross button

- (void)prepapreCrossButton
{
    FLContainerViewController *controller = (FLContainerViewController *)appDelegate.window.rootViewController;
    
    UIImage *buttonImage = [UIImage imageNamed:@"menu-new-transaction"];
    crossButton = [[UIButton alloc] initWithFrame:CGRectMakeSize(buttonImage.size.width, buttonImage.size.height)];
    [crossButton setImage:buttonImage forState:UIControlStateNormal];
    [controller.view addSubview:crossButton];
    
    CGFloat y = controller.view.frame.size.height - buttonImage.size.height - 20;
    CGRectSetY(crossButton.frame, y);

    [self refreshCrossButton];
    
    [crossButton addTarget:self action:@selector(didCrossButtonTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didCrossButtonTouch
{
    UIViewController<FLContainerViewControllerDelegate> *currentController = _viewControllers[selectedTitleIndex];
    [currentController presentMenuTransactionController];
}

- (void)beginTransition
{
//    for(UIViewController *controller in _viewControllers){
//        [controller beginAppearanceTransition:NO animated:NO];
//    }
}

- (void)endTransition
{
//    for(UIViewController *controller in _viewControllers){
//        [controller endAppearanceTransition];
//    }
    
    // Si dans amis on a le clavier d ouvert
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCloseKeyboard object:nil];
}

@end
