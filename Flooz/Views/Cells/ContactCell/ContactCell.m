//
//  ContactCell.m
//  Flooz
//
//  Created by Arnaud on 2014-08-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "ContactCell.h"

@implementation ContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		// Initialization code
		[self createAvatarView];
		[self createNameView];
		[self createPhoneView];

		NSString *textFlooz = NSLocalizedString(@"ALREADY_FLOOZ", nil);
		UIFont *font = [UIFont customContentLight:12];
		CGSize expectedLabelSize = [textFlooz sizeWithAttributes:@{ NSFontAttributeName: font }];
		_alreadyOnFloozLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - expectedLabelSize.width - 21, 0, expectedLabelSize.width, 50)];
		[_alreadyOnFloozLabel setText:textFlooz];
		_alreadyOnFloozLabel.textColor = [UIColor customBlueLight];
		_alreadyOnFloozLabel.font = font;
		_alreadyOnFloozLabel.numberOfLines = 2;
		_alreadyOnFloozLabel.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_alreadyOnFloozLabel];
		[_alreadyOnFloozLabel setHidden:YES];

		UIImage *imageB = [UIImage imageNamed:@"Signup_Friends_Plus"];
		_addFriendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 52, 0, 50, 50)];
		[_addFriendButton setImage:imageB forState:UIControlStateNormal];
		[_addFriendButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
		[_addFriendButton setHidden:YES];
		[self.contentView addSubview:_addFriendButton];
	}
	return self;
}

- (void)createAvatarView {
	_avatarContact = [[FLUserView alloc] initWithFrame:CGRectMake(15, 8, 38, 38)];
	[self.contentView addSubview:_avatarContact];
}

- (void)createNameView {
	_firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarContact.frame) + 20, 17, CGRectGetWidth(self.frame) - 75 - 52, 11)];
	[self.contentView addSubview:_firstNameLabel];
	_firstNameLabel.textColor = [UIColor whiteColor];
	_firstNameLabel.font = [UIFont customContentBold:13];

	_lastNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_firstNameLabel.frame), 17, 100, 11)];
	[self.contentView addSubview:_lastNameLabel];
	_lastNameLabel.textColor = [UIColor whiteColor];
	_lastNameLabel.font = [UIFont customContentBold:13];
}

- (void)createPhoneView {
	_subLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_firstNameLabel.frame), 31, 200, 9)];
	[self.contentView addSubview:_subLabel];
	_subLabel.textColor = [UIColor customPlaceholder];
	_subLabel.font = [UIFont customContentBold:11];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

#pragma mark - Set

- (void)setContact:(NSDictionary *)contact {
	_contact = contact;
	[self prepareViews];
	[_alreadyOnFloozLabel setHidden:YES];
}

- (void)setContactUser:(FLUser *)contact {
	[_firstNameLabel setText:[contact.fullname uppercaseString]];
	CGSize expectedLabelSize = [[contact.fullname uppercaseString] sizeWithAttributes:
	                            @{ NSFontAttributeName: _firstNameLabel.font }];
	CGRectSetWidth(_firstNameLabel.frame, expectedLabelSize.width);
	[_subLabel setText:contact.username];
	[_avatarContact setImageFromURL:contact.avatarURL];
	[_alreadyOnFloozLabel setHidden:NO];
}

#pragma mark - Prepare Views

- (void)prepareViews {
	[self prepareAvatarView];
	[self prepareNameView];
	[self preparePhoneView];
}

- (void)prepareAvatarView {
	if (_contact[@"image"]) {
		[_avatarContact setImageFromData:_contact[@"image"]];
	}
	else if (_contact[@"image_url"]) {
		[_avatarContact setImageFromURL:_contact[@"image_url"]];
	}
	else {
		[_avatarContact setImageFromData:nil];
	}
}

- (void)prepareNameView {
	NSString *firstName = _contact[@"name"];
	[_firstNameLabel setText:[firstName uppercaseString]];

	CGSize expectedLabelSize = [[firstName uppercaseString] sizeWithAttributes:
	                            @{ NSFontAttributeName: _firstNameLabel.font }];
	CGRectSetWidth(_firstNameLabel.frame, expectedLabelSize.width);
}

- (void)preparePhoneView {
	if (_contact[@"username"]) {
		_subLabel.text = _contact[@"username"];
	}
	else if (_contact[@"phone"]) {
		_subLabel.text = _contact[@"phone"];
	}
	else if (_contact[@"email"]) {
		_subLabel.text = _contact[@"email"];
	}
	else {
		_subLabel.text = @"";
	}
	CGSize expectedLabelS = [_subLabel.text sizeWithAttributes:
	                         @{ NSFontAttributeName: _subLabel.font }];
	CGRectSetHeight(_subLabel.frame, expectedLabelS.height);
}

@end
