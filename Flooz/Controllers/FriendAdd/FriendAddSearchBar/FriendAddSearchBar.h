//
//  FriendAddSearchBar.h
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendAddSearchBarDelegate.h"

@interface FriendAddSearchBar : UIView <UISearchBarDelegate> {
	UISearchBar *_searchBar;
	NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet id <FriendAddSearchBarDelegate> delegate;

- (id)initWithStartX:(CGFloat)xStart;
- (void)close;

@end
