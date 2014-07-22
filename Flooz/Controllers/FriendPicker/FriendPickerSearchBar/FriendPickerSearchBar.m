//
//  FriendPickerSearchBar.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendPickerSearchBar.h"

@implementation FriendPickerSearchBar

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 44);
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
//    [self createFacebookView];
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
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(42, 0, CGRectGetWidth(self.frame) - 42, CGRectGetHeight(self.frame))];
    
    _searchBar.delegate = self;
    _searchBar.placeholder = NSLocalizedString(@"FRIEND_PCIKER_PLACEHOLDER", nil);
    _searchBar.translucent = NO;
    _searchBar.barTintColor = self.backgroundColor;
    _searchBar.tintColor = [UIColor whiteColor]; // Curseur
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor customBackground]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackground:[UIImage imageWithColor:[UIColor customBackground]]];
        
    // Hack pour supprimer bordure noir
    [[[[[_searchBar subviews] firstObject] subviews] firstObject] removeFromSuperview];
    
    [self addSubview:_searchBar];
}

- (void)createFacebookView
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(42 + 240, 0, CGRectGetWidth(self.frame) - 42 - 240, CGRectGetHeight(self.frame))];
    
    view.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [view setImage:[UIImage imageNamed:@"friends-facebook"] forState:UIControlStateNormal];
    [view setImage:[UIImage imageNamed:@"friends-facebook-selected"] forState:UIControlStateSelected];
    
    [view addTarget:self action:@selector(didFacebookTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:view];
}

#pragma mark -

- (void)didBackTouch
{
    [_delegate dismiss];
}

- (void)didFacebookTouch:(UIButton *)sender
{
    sender.selected = !sender.selected;
    [_delegate didSourceFacebook:sender.selected];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [_delegate didFilterChange:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)close
{
    [_searchBar resignFirstResponder];
}

@end
