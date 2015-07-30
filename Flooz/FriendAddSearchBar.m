//
//  FriendAddSearchBar.m
//  Flooz
//
//  Created by olivier on 3/6/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FriendAddSearchBar.h"
#import "UISearchBar+Subviews.h"

@implementation FriendAddSearchBar {
    
}

- (id)initWithStartX:(CGFloat)xStart {
    CGRect frame = CGRectMake(0.0f, 0.0f, PPScreenWidth(), 44.0f);
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor customBackgroundHeader];
        
        [self createViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self createViews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createViews];
    }
    return self;
}

#pragma mark -

- (void)createViews {
    [self createSearchView];
}

- (void)createSearchView {
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    _searchBar.placeholder = NSLocalizedString(@"SEARCH_FRIENDS", nil);
    _searchBar.delegate = self;
    _searchBar.tintColor = [UIColor whiteColor]; // Curseur
    [_searchBar setSearchBarStyle:UISearchBarStyleMinimal];
    
    UIImage *searchFieldImage = [[UIImage imageNamed:@"UISearchBarBorder"]
                                 resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [_searchBar setSearchFieldBackgroundImage:searchFieldImage forState:UIControlStateNormal];
    
    UITextField *searchBarTextField = [_searchBar retrieveTextField];
    searchBarTextField.keyboardAppearance = UIKeyboardAppearanceDark;
    searchBarTextField.borderStyle = UITextBorderStyleRoundedRect;
    searchBarTextField.backgroundColor = [UIColor customBackground];
    searchBarTextField.textColor = [UIColor whiteColor];
    searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SEARCH_FRIENDS", nil) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIImage *image = [UIImage imageNamed:@"searchBar_icon"];
    [_searchBar setImage:image forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [self addSubview:_searchBar];
}

#pragma mark -

- (void)didBackTouch {
    [timer invalidate];
    [_delegate dismiss];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(performRequest) userInfo:nil repeats:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [timer invalidate];
    [searchBar resignFirstResponder];
    [_delegate didFilterChange:searchBar.text];
}

- (void)performRequest {
    [_delegate didFilterChange:_searchBar.text];
}

- (BOOL)becomeFirstResponder {
    return [_searchBar becomeFirstResponder];
}

- (void)close {
    [_searchBar resignFirstResponder];
}

@end
