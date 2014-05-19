//
//  FLSelectFriendButton.h
//  Flooz
//
//  Created by jonathan on 2/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLSelectFriendButton : UIView{
    __weak NSMutableDictionary *_dictionary;
    UILabel *usernameView;
}

@property (weak, nonatomic) UIViewController *delegate;

- (id)initWithFrame:(CGRect)frame dictionary:(NSMutableDictionary *)dictionary;
- (void)reloadData;

@end
