//
//  FriendPickerSearchBarDelegate.h
//  Flooz
//
//  Created by olivier on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendPickerSearchBarDelegate <NSObject>

- (void)dismiss;
- (void)didFilterChange:(NSString *)text;
- (void)didSourceFacebook:(BOOL)isFacebook;

@end
