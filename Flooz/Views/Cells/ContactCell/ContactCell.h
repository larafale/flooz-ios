//
//  ContactCell.h
//  Flooz
//
//  Created by Arnaud on 2014-08-18.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactCell : UITableViewCell

@property (strong, nonatomic) UILabel *firstNameLabel;
@property (strong, nonatomic) UILabel *lastNameLabel;
@property (strong, nonatomic) UILabel *subLabel;
@property (strong, nonatomic) UIButton *addFriendButton;

@property (strong, nonatomic) FLUserView *avatarContact;

- (void) setCellWithFirstName :(NSString *)firstName lastName:(NSString *)lastName subText:(NSString *)subText andDataImage:(NSData *)dataImage;
- (void) setCellWithCompleteName:(NSString *)complete subText:(NSString *)subText andImageUrl:(NSString *)imageUrl ;

@end
