//
//  FriendPickerSearchBar.m
//  Flooz
//
//  Created by olivier on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FriendPickerSearchBar.h"
#import "UISearchBar+Subviews.h"

@implementation FriendPickerSearchBar

@synthesize _searchBar;

- (id)initWithFrame:(CGRect)frame {
	CGRectSetHeight(frame, 44);
	self = [super initWithFrame:frame];
	if (self) {
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
	self.backgroundColor = [UIColor customBackgroundHeader];

	[self createSearchView];
}

- (void)createSearchView {
	_searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
	_searchBar.delegate = self;
	_searchBar.placeholder = NSLocalizedString(@"FRIEND_PCIKER_PLACEHOLDER", nil);
 
    _searchBar.barTintColor = self.backgroundColor;
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

- (void)close {
	[_searchBar resignFirstResponder];
}

- (void)didFacebookTouch:(UIButton *)sender {
	sender.selected = !sender.selected;
	[_delegate didSourceFacebook:sender.selected];
}

@end
