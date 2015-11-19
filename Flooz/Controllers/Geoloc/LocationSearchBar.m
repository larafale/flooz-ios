//
//  LocationSearchBar.m
//  Flooz
//
//  Created by Epitech on 11/2/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "LocationSearchBar.h"
#import "UISearchBar+Subviews.h"

@implementation LocationSearchBar

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
    
    _searchBar.placeholder = NSLocalizedString(@"SEARCH_LOCATION", nil);
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
    searchBarTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"SEARCH_LOCATION", nil) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    UIImage *image = [UIImage imageNamed:@"searchBar_icon"];
    [_searchBar setImage:image forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    [self addSubview:_searchBar];
}

#pragma mark -

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
