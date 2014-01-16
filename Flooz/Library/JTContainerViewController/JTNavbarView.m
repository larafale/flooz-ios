//
//  JTNavbarView.m
//  Flooz
//
//  Created by jonathan on 1/10/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "JTNavbarView.h"

#define STATUSBAR_HEIGHT 20.
#define NAVBAR_HEIGHT 44.
#define HEIGHT (STATUSBAR_HEIGHT + NAVBAR_HEIGHT)

#define RATIO_TITLE_CONTENT 2.
#define OFFSET_BETWEEN_TITLES (CGRectGetWidth(self.frame) / RATIO_TITLE_CONTENT)

@implementation JTNavbarView

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super initWithFrame:CGRectMakeSize([[UIScreen mainScreen] bounds].size.width, HEIGHT)];
    if (self) {
        self.backgroundColor = [UIColor customBackgroundHeader];
        
        panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPanGesture:)];
        [self addGestureRecognizer:panGesture];
        
        _viewControllers = viewControllers;
        [self prepareTitleViews];
    }
    return self;
}

- (void)prepareTitleViews
{
    [_titlesView removeFromSuperview];
    _titlesView = [[UIView alloc] initWithFrame:self.frame];
    [self addSubview:_titlesView];
    
    for(UIViewController *controller in _viewControllers){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT, CGRectGetWidth(self.frame), NAVBAR_HEIGHT)];
        
        label.font = [UIFont customTitleExtraLight:28];
        label.textColor = [UIColor customBlue];
        label.textAlignment = NSTextAlignmentCenter;
        
        label.text = controller.title;
        label.tag = [[_titlesView subviews] count];

        [_titlesView addSubview:label];
    }
    
    selectedTitleIndex = 1;
    [self updateViewsPositions];
}

- (void)respondToPanGesture:(UIPanGestureRecognizer *)recognizer
{
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            lastTranslation = CGPointZero;
            break;
        case UIGestureRecognizerStateChanged:{
            CGPoint translation = [recognizer translationInView:_titlesView];
            CGPoint diffTranslation = translation;
            diffTranslation.x -= lastTranslation.x;
            lastTranslation = translation;
            
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
    }
}

- (void)updateViewsPositions
{
    NSInteger index = 0;
    for(UIView *view in [_titlesView subviews]){
        view.frame = CGRectMakeSetX(view.frame, OFFSET_BETWEEN_TITLES * (index - selectedTitleIndex));
        index++;
    }
    
    index = 0;
    for(UIViewController *controller in _viewControllers){
        controller.view.frame = CGRectMakeSetX(controller.view.frame, CGRectGetWidth(self.frame) * (index - selectedTitleIndex));
        index++;
    }
}

- (void)completeTranslation
{
    CGPoint positionFirstTitle = [[[_titlesView subviews] objectAtIndex:0] frame].origin;
    CGFloat screenWidth = CGRectGetWidth(self.frame);
    
    selectedTitleIndex = roundf(((positionFirstTitle.x * -1.0) / (screenWidth / RATIO_TITLE_CONTENT)));
    selectedTitleIndex = MAX(selectedTitleIndex, 0);
    selectedTitleIndex = MIN(selectedTitleIndex, [[_titlesView subviews] count] - 1);
    
    [UIView animateWithDuration:.3 animations:^{
        [self updateViewsPositions];
    }];
}

@end
