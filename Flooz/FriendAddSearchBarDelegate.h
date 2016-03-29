//
//  FriendAddSearchBarDelegate.h
//  Flooz
//
//  Created by olivier on 3/6/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FriendAddSearchBarDelegate <NSObject>

- (void)didFilterChange:(NSString *)text;

@end
