//
//  FLFilterView.m
//  Flooz
//
//  Created by jonathan on 1/19/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLFilterView.h"

@implementation FLFilterView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, SCREEN_WIDTH, 34)];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor customBackgroundHeader];
    currentFilterIndex = 0;
    currentFilterColorIndex = 0;
    buttonColors = [NSMutableArray new];
    filterViews = [NSMutableArray new];
    actions = [NSMutableArray new];
    
    contentView = [[UIView alloc] initWithFrame:self.frame];
    [self addSubview:contentView];
    
    {
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 1)];
        borderView.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:.2];
        [self addSubview:borderView];
        
        self.layer.shadowOffset = CGSizeMake(0, 3.5);
        self.layer.shadowOpacity = .2;
        self.layer.shadowRadius = 1;
    }
}

- (void)addFilter:(NSString *)title target:(id)target action:(SEL)action
{
    [self addFilter:title target:target action:action colors:@[[UIColor customBlue]]];
}

- (void)addFilter:(NSString *)title target:(id)target action:(SEL)action colors:(NSArray *)colors
{
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(self.frame))];
    
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(filterView.frame) - 1)];
        [button setTitle:NSLocalizedString(title, nil) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont customContentLight:11];
        
        if([filterViews count] > 0){
            [button setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
        }
        else{
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        button.tag = [buttonColors count];
        [buttonColors addObject:colors];
        
        [button addTarget:self action:@selector(didButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        
        [filterView addSubview:button];
    }
    
    {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(filterView.frame) - 1, 0, 1)];
        line.backgroundColor = [colors firstObject];
        if([filterViews count] > 0){
            line.hidden = YES;
        }
        
        [filterView addSubview:line];
    }
    
    if([colors count] > 1){
        UIImageView *arrow = [UIImageView imageNamed:@"filter-view-arrow"];
        arrow.center = CGRectGetCenter(filterView.frame);
        [filterView addSubview:arrow];
        
        UIImageView *arrow_selected = [UIImageView imageNamed:@"filter-view-arrow-selected"];
        arrow_selected.center = CGRectGetCenter(filterView.frame);
        arrow_selected.hidden = YES;
        [filterView addSubview:arrow_selected];
    }
    
    if([[contentView subviews] count] > 0){
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, ((CGRectGetHeight(self.frame) - 15) / 2.), 1, 15)];
        separator.backgroundColor = [UIColor customSeparator];

        [contentView addSubview:separator];
    }
    
    [actions addObject:@{ @"target":target, @"action": NSStringFromSelector(action) }];
    
    [contentView addSubview:filterView];
    [filterViews addObject:filterView];
    [self updateFilterViews];
}

- (void)didButtonTouch:(UIButton *)button
{
    NSArray *colors = [buttonColors objectAtIndex:button.tag];
    
    for(UIView *filterView in filterViews){
        UIButton *_button = [[filterView subviews] objectAtIndex:0];
        [_button setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        
        UIView *line = [[filterView subviews] objectAtIndex:1];
        line.hidden = YES;
        
        if([[filterView subviews] count] > 2){
            UIView *arrow = [[filterView subviews] objectAtIndex:2];
            UIView *arrow_selected = [[filterView subviews] objectAtIndex:3];
            
            arrow.hidden = NO;
            arrow_selected.hidden = YES;
        }
    }
    
    UIView *filterView = [filterViews objectAtIndex:button.tag];
    UIView *line = [[filterView subviews] objectAtIndex:1];
    line.hidden = NO;
    
    if([[filterView subviews] count] > 2){
        UIView *arrow = [[filterView subviews] objectAtIndex:2];
        UIView *arrow_selected = [[filterView subviews] objectAtIndex:3];
        
        arrow.hidden = YES;
        arrow_selected.hidden = NO;
    }
    
    currentFilterColorIndex = 0;
    
    // 1st click
    if(currentFilterIndex == button.tag && [colors count] > 1){
        currentFilterColorIndex = [colors indexOfObject:line.backgroundColor];
        currentFilterColorIndex = (currentFilterColorIndex + 1) % ([colors count]);
    }
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    line.backgroundColor = [colors objectAtIndex:currentFilterColorIndex];
    currentFilterIndex = button.tag;
    
    NSDictionary *action = [actions objectAtIndex:button.tag];
    [[action objectForKey:@"target"] performSelector:NSSelectorFromString([action objectForKey:@"action"]) withObject:[NSNumber numberWithInteger:currentFilterColorIndex]];
}

- (void)updateFilterViews
{
    NSInteger numberOfSeparators = ([[contentView subviews] count] - 1) / 2;
    NSInteger numberOfFilters = ([[contentView subviews] count] + 1) / 2;
    CGFloat widthForFilterView = (CGRectGetWidth(self.frame) / numberOfFilters) - numberOfSeparators;
    
    NSInteger index = 0;
    CGFloat offset = 0;
    for(UIView *view in [contentView subviews]){
        
        // Si FilterView
        if(index % 2 == 0){
            view.frame = CGRectSetWidth(view.frame, widthForFilterView);
            
            {
                UIView *button = [[view subviews] objectAtIndex:0];
                UIView *line = [[view subviews] objectAtIndex:1];
                
                button.frame = CGRectSetWidth(button.frame, widthForFilterView);
                line.frame = CGRectSetWidth(line.frame, widthForFilterView);
            }
            
            if([[view subviews] count] > 2){
                UIView *arrow = [[view subviews] objectAtIndex:2];
                UIView *arrow_selected = [[view subviews] objectAtIndex:3];
                
                arrow.frame = CGRectSetX(arrow.frame, widthForFilterView - 12);
                arrow_selected.frame = CGRectSetX(arrow_selected.frame, widthForFilterView - 12);
            }
        }
        
        view.frame = CGRectSetX(view.frame, offset + 1);
        offset = CGRectGetMaxX(view.frame);
        index++;
    }
}

@end
