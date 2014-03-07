//
//  PreviewNavBar.m
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "PreviewNavBar.h"

#define BUTTON_WIDTH 42.

@implementation PreviewNavBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 44);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews{
    self.backgroundColor = [UIColor customBackgroundHeader];
    
    [self createSkipButton];
    [self createPreviousButton];
    [self createNextButton];
    [self createDismissButton];
}

- (void)createSkipButton{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_WIDTH, 0, CGRectGetWidth(self.frame) - BUTTON_WIDTH - BUTTON_WIDTH, CGRectGetHeight(self.frame))];
    
    [button addTarget:self action:@selector(didDismissButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [button setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    
    [button setTitle:@"Skip tour" forState:UIControlStateNormal];
    
    [self addSubview:button];
}

- (void)createPreviousButton{
    {
        previousButton = [[UIButton alloc] initWithFrame:CGRectMakeSize(BUTTON_WIDTH, CGRectGetHeight(self.frame))];
        
        [previousButton addTarget:self action:@selector(didPreviousButtonTouch) forControlEvents:UIControlEventTouchUpInside];
        [previousButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
        
        [previousButton setTitle:@"<" forState:UIControlStateNormal];
        
        [self addSubview:previousButton];
    }
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(BUTTON_WIDTH, 0, 1, CGRectGetHeight(self.frame))];
        view.backgroundColor = [UIColor customSeparator];
        
        [self addSubview:view];
    }
}

- (void)createNextButton{
    {
        nextButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - BUTTON_WIDTH, 0, BUTTON_WIDTH, CGRectGetHeight(self.frame))];
        
        [nextButton addTarget:self action:@selector(didNextButtonTouch) forControlEvents:UIControlEventTouchUpInside];
        [nextButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
        
        [nextButton setTitle:@">" forState:UIControlStateNormal];
        
        [self addSubview:nextButton];
    }
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - BUTTON_WIDTH, 0, 1, CGRectGetHeight(self.frame))];
        view.backgroundColor = [UIColor customSeparator];
        
        [self addSubview:view];
    }
}

- (void)createDismissButton{
    dismissButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - BUTTON_WIDTH, 0, BUTTON_WIDTH, CGRectGetHeight(self.frame))];
    
    [dismissButton addTarget:self action:@selector(didDismissButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [dismissButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    
    [dismissButton setTitle:@"V" forState:UIControlStateNormal];
    
    [self addSubview:dismissButton];
}

#pragma mark -

- (void)didPreviousButtonTouch{
    [_delegate loadPreviousSlide];
}

- (void)didNextButtonTouch{
    [_delegate loadNextSlide];
}

- (void)didDismissButtonTouch{
    [_delegate dismiss];
}

#pragma mark -

- (void)setIsFirstPage:(BOOL)isFirstPage{
    if(isFirstPage){
        previousButton.hidden = YES;
    }
    else{
        previousButton.hidden = NO;
    }
}

- (void)setIsLastPage:(BOOL)isLastPage{
    if(isLastPage){
        nextButton.hidden = YES;
        dismissButton.hidden = NO;
    }
    else{
        nextButton.hidden = NO;
        dismissButton.hidden = YES;
    }
}

@end
