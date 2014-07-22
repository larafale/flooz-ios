//
//  FriendPickerSearchBar.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendPickerSearchBarDelegate.h"

@interface FriendPickerSearchBar : UIView<UISearchBarDelegate>{
    UISearchBar *_searchBar;
}

@property (weak) IBOutlet id<FriendPickerSearchBarDelegate> delegate;

- (void)close;

@end
