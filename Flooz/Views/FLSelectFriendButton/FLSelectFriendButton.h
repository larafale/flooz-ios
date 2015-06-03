//
//  FLSelectFriendButton.h
//  Flooz
//
//  Created by olivier on 2/6/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLSelectFriendButton : UIView {
	__weak NSMutableDictionary *_dictionary;
	UILabel *fullnameView;
	UILabel *usernameView;

	UIView *separatorBottom;
    
    BOOL editable;
}

@property (weak, nonatomic) UIViewController *delegate;

- (id)initWithFrame:(CGRect)frame dictionary:(NSMutableDictionary *)dictionary editable:(BOOL)edit;
- (id)initWithFrame:(CGRect)frame dictionary:(NSMutableDictionary *)dictionary;
- (void)reloadData;

- (void)didButtonTouch;
- (void)hideSeparatorBottom;

@end
