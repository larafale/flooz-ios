//
//  FriendPickerSearchBar.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendPickerSearchBarDelegate.h"

@interface FriendPickerSearchBar : UIView <UISearchBarDelegate> {

	NSTimer *timer;
}

@property (weak) IBOutlet id <FriendPickerSearchBarDelegate> delegate;
@property (nonatomic, retain) UISearchBar *_searchBar;

- (void)close;

@end
