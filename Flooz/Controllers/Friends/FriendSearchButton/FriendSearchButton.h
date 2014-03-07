//
//  FriendSearchButton.h
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FriendSearchButtonDelegate.h"

@interface FriendSearchButton : UIView

@property (weak, nonatomic) id<FriendSearchButtonDelegate> delegate;

@end
