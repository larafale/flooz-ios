//
//  FriendPickerContactCell.m
//  Flooz
//
//  Created by olivier on 2/11/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FriendPickerContactCell.h"

#define PADDING_SIDE 10.0f

@implementation FriendPickerContactCell {
    FLUserView *_avatarView;
    UILabel *_nameLabel;
    UILabel *_subLabel;
    
    CGFloat widthLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self createViews];
	}
	return self;
}

+ (CGFloat)getHeight {
	return 54;
}

- (void)setContact:(NSDictionary *)contact {
	self->_contact = contact;
	[self prepareViews];
}

#pragma mark - Create Views

- (void)createViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];

	[self createAvatarView];
	[self createNameView];
	[self createSubTextView];
	[self createCheckView];
}

- (void)createAvatarView {
    _avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(PADDING_SIDE, 8, 38.0f, 38.0f)];
    [self.contentView addSubview:_avatarView];
}

- (void)createNameView {
    widthLabel = CGRectGetWidth(self.contentView.frame) - (CGRectGetMaxX(_avatarView.frame) + PADDING_SIDE + 50.0f);
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarView.frame) + PADDING_SIDE, 17.0f, widthLabel, 11)];
    
    _nameLabel.font = [UIFont customContentBold:13];
    _nameLabel.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:_nameLabel];
}

- (void)createSubTextView {
    _subLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nameLabel.frame), 31, CGRectGetWidth(_nameLabel.frame), 9)];
    
    _subLabel.font = [UIFont customContentBold:11];
    _subLabel.textColor = [UIColor customGreyPseudo];
    
    [self.contentView addSubview:_subLabel];
}

- (void)createCheckView {
	UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 30, CGRectGetHeight(self.contentView.frame) / 2., 15, 10)];
	[self.contentView addSubview:view];

	view.image = [UIImage imageNamed:@"navbar-check"];
}

#pragma mark - Prepare Views

- (void)prepareViews {
	[self prepareAvatarView];
	[self prepareNameView];
	[self preparePhoneView];
}

- (void)prepareAvatarView {
	if ([_contact objectForKey:@"image"]) {
		[_avatarView setImageFromData:[_contact objectForKey:@"image"]];
	}
	else if ([_contact objectForKey:@"image_url"]) {
		[_avatarView setImageFromURL:[_contact objectForKey:@"image_url"]];
	}
	else {
		[_avatarView setImageFromData:nil];
	}
}

- (void)prepareNameView {
	_nameLabel.text = [[_contact objectForKey:@"name"] uppercaseString];
}

- (void)preparePhoneView {
	if ([_contact objectForKey:@"phone"]) {
		_subLabel.text = [_contact objectForKey:@"phone"];
	}
	else if ([_contact objectForKey:@"email"]) {
		_subLabel.text = [_contact objectForKey:@"email"];
	}
	else {
		_subLabel.text = @"";
	}
	CGSize expectedLabelS = [_subLabel.text sizeWithAttributes:
	                         @{ NSFontAttributeName: _subLabel.font }];
	CGRectSetHeight(_subLabel.frame, expectedLabelS.height);
}

- (void)setSelectedCheckView:(BOOL)selected {
	[super setSelected:selected];

	UIImageView *checkView = [[self.contentView subviews] objectAtIndex:3];
	checkView.hidden = !selected;
}

@end
