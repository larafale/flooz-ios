//
//  FriendAddSearchBar.h
//  Flooz
//
//  Created by Olivier on 3/6/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendAddSearchBarDelegate.h"

@interface FriendAddSearchBar : UIView <UISearchBarDelegate> {
	NSTimer *timer;
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet id <FriendAddSearchBarDelegate> delegate;

- (id)initWithStartX:(CGFloat)xStart;
- (id)initWithFrame:(CGRect)frame;
- (void)close;

@end
