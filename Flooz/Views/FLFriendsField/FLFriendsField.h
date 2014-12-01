//
//  FLFriendsField.h
//  Flooz
//
//  Created by Jonathan on 31/07/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLFriendsField : UIView <UITextFieldDelegate> {
	__weak NSMutableDictionary *_dictionary;
	NSString *_dictionaryKey;

	UILabel *_title;
	UITextField *_textfield;

	NSMutableDictionary *_dictionaryForFriendController;
}

@property (weak, nonatomic) UIViewController *delegate;

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey position:(CGPoint)position;

- (void)setInputAccessoryView:(UIView *)accessoryView;
- (void)reloadData;

@end
