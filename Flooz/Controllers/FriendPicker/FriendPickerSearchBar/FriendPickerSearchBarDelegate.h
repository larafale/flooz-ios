//
//  FriendPickerSearchBarDelegate.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendPickerSearchBarDelegate <NSObject>

- (void)dismiss;
- (void)didFilterChange:(NSString *)text;
- (void)didSourceFacebook:(BOOL)isFacebook;

@end
