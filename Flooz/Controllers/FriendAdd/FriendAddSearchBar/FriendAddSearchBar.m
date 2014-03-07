//
//  FriendAddSearchBar.m
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendAddSearchBar.h"

@implementation FriendAddSearchBar


- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 44.);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createViews];
    }
    return self;
}

#pragma mark -

- (void)createViews
{
    self.backgroundColor = [UIColor customBackgroundHeader];
    
    [self createBackView];
    [self createSearchView];
}

- (void)createBackView
{
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, CGRectGetHeight(self.frame))];
    
    [back setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(didBackTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:back];
}

- (void)createSearchView
{
    UISearchBar *view = [[UISearchBar alloc] initWithFrame:CGRectMake(42, 0, 240, CGRectGetHeight(self.frame))];
    
    view.delegate = self;
    
    view.translucent = NO;
    view.barTintColor = self.backgroundColor;
    view.tintColor = [UIColor whiteColor]; // Curseur
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor customBackground]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackground:[UIImage imageWithColor:[UIColor customBackground]]];
    
    // Hack pour supprimer bordure noir
    [[[[[view subviews] firstObject] subviews] firstObject] removeFromSuperview];
    
    [self addSubview:view];
}

#pragma mark -

- (void)didBackTouch
{
    [_delegate dismiss];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [_delegate didFilterChange:searchBar.text];
}

@end
