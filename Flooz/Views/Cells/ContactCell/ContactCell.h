//
//  ContactCell.h
//  Flooz
//
//  Created by Arnaud on 2014-08-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell

@property (strong, nonatomic) UILabel *firstNameLabel;
@property (strong, nonatomic) UILabel *lastNameLabel;
@property (strong, nonatomic) UILabel *subLabel;
@property (strong, nonatomic) UILabel *alreadyOnFloozLabel;
@property (strong, nonatomic) UIButton *addFriendButton;

@property (strong, nonatomic) FLUserView *avatarContact;
@property (weak, nonatomic) NSDictionary *contact;

- (void)setContact:(NSDictionary *)contact;
- (void)setContactUser:(FLUser *)contact;

@end
