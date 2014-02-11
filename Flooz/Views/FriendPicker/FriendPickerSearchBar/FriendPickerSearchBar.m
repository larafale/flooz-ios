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
    frame = CGRectSetHeight(frame, 44.);
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
    [self createFacebookView];
}

- (void)createBackView
{
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(5, 14, 20, 17)];
    
    [back setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(didBackTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:back];
}

- (void)createSearchView
{
    UISearchBar *view = [[UISearchBar alloc] initWithFrame:CGRectMake(42, 0, 240, CGRectGetHeight(self.frame))];
    
    view.translucent = NO;
    view.barTintColor = self.backgroundColor;
    view.tintColor = [UIColor whiteColor]; // Curseur
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor customBackground]];
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor whiteColor]];
    
    [self addSubview:view];
}

- (void)createFacebookView
{
    
}

#pragma mark -

- (void)didBackTouch
{
    [_delegate dismiss];
}

@end
