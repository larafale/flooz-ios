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
    
//    [self createBackView];
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
//    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(42, 0, 240, CGRectGetHeight(self.frame))];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(10, 0, 300, CGRectGetHeight(self.frame))];
    
    
    _searchBar.placeholder = NSLocalizedString(@"SEARCH_FRIENDS", nil);
    
    _searchBar.delegate = self;
    
    // WARNING Gros bordel
    
    self.backgroundColor = [UIColor customBackground];
    
    _searchBar.translucent = NO;
    _searchBar.barTintColor = self.backgroundColor;
    _searchBar.tintColor = [UIColor whiteColor]; // Curseur
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:self.backgroundColor];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
//
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackground:[UIImage imageWithColor:self.backgroundColor]];
//
    // Hack pour supprimer bordure noir
    [[[[[_searchBar subviews] firstObject] subviews] firstObject] removeFromSuperview];
    
    {
        _searchBar.barTintColor = [UIColor customBackground];
        
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:self.backgroundColor];
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackground:[UIImage imageWithColor:self.backgroundColor]];
        
        self.backgroundColor = [UIColor customBackground];
    }
    
    [self addSubview:_searchBar];
}

#pragma mark -

- (void)didBackTouch
{
    [timer invalidate];
    [_delegate dismiss];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:.6 target:self selector:@selector(performRequest) userInfo:nil repeats:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [timer invalidate];
    [searchBar resignFirstResponder];
    [_delegate didFilterChange:searchBar.text];
}

- (void)performRequest
{
    [_delegate didFilterChange:_searchBar.text];
}

- (BOOL)becomeFirstResponder
{
    return [_searchBar becomeFirstResponder];
}

- (void)close
{
    [_searchBar resignFirstResponder];
}

@end
