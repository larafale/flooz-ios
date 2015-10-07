//
//  FriendCell.m
//  Flooz
//
//  Created by olivier on 2/20/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FriendCell.h"

#define PADDING_SIDE 10.0f

@implementation FriendButton
//
//- (void)setSelected:(BOOL)selected {
//    [super setSelected:selected];
//    if (selected) {
//        [self setBackgroundColor:[UIColor customBlue]];
//    }
//    else {
//        [self setBackgroundColor:[UIColor clearColor]];
//    }
//}

@end
@implementation FriendCell {
	UILabel *_nameLabel;
	UILabel *_subLabel;
    
    UIImageView *_certifImageView;

    CGFloat widthLabel;
    CGFloat cellWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
        cellWidth = PPScreenWidth();
		[self createViews];
	}
	return self;
}

+ (CGFloat)getHeight {
	return 54;
}

- (void)setFriend:(FLUser *)friend {
	self->_friend = friend;
	[self prepareViews];
}

#pragma mark - Create Views

- (void)createViews {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.backgroundColor = [UIColor clearColor];

	[self createAvatarView];
	[self createTextView];
	[self createSubTextView];
    [self createCertifView];
	[self createButtonView];
}

- (void)createAvatarView {
    _avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(PADDING_SIDE, 8.0f, 38.0f, 38.0f)];
    [self.contentView addSubview:_avatarView];
}

- (void)createTextView {
    widthLabel = cellWidth - (CGRectGetMaxX(_avatarView.frame) + PADDING_SIDE);
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarView.frame) + PADDING_SIDE, 17.0f, widthLabel, 14)];

	_nameLabel.font = [UIFont customContentBold:13];
	_nameLabel.textColor = [UIColor whiteColor];

	[self.contentView addSubview:_nameLabel];
}

- (void)createSubTextView {
	_subLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nameLabel.frame), 31, CGRectGetWidth(_nameLabel.frame), 12)];

	_subLabel.font = [UIFont customContentBold:11];
	_subLabel.textColor = [UIColor customGreyPseudo];

	[self.contentView addSubview:_subLabel];
}

- (void)createCertifView {
    _certifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 16.5f, 15, 15)];
    [_certifImageView setImage:[UIImage imageNamed:@"certified"]];
    [_certifImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.contentView addSubview:_certifImageView];
}

- (void)createButtonView {
    _addButton = [FLSocialHelper createMiniFriendButton:self action:@selector(accept) frame:CGRectMake(cellWidth - 45, 13, 28, 28)];
    _removeButton = [FLSocialHelper createMiniUnfriendButton:self action:@selector(accept) frame:CGRectMake(cellWidth - 45, 13, 28, 28)];

	[self.contentView addSubview:_addButton];
    [self.contentView addSubview:_removeButton];
}

#pragma mark - Prepare Views

- (void)prepareViews {
	[self prepareAvatarView];
	[self prepareNameView];
	[self preparePhoneView];

	[self prepareCheckView];
}

- (void)prepareAvatarView {
	[_avatarView setImageFromUser:_friend];
}

- (void)prepareNameView {
    _nameLabel.text = [[_friend fullname] uppercaseString];
    [_nameLabel setWidthToFit];
    
    if ([_friend isStar] || [_friend isPro]) {
        [_certifImageView setHidden:NO];
        CGRectSetX(_certifImageView.frame, CGRectGetMaxX(_nameLabel.frame) + 5);
    } else {
        [_certifImageView setHidden:YES];
    }
}

- (void)preparePhoneView {
	NSString *s = [@"@" stringByAppendingString : _friend.username];
	_subLabel.text = s;
	CGSize expectedLabelS = [s sizeWithAttributes:
	                         @{ NSFontAttributeName: _subLabel.font }];
	CGRectSetHeight(_subLabel.frame, expectedLabelS.height);
}

- (void)prepareCheckView {
	BOOL isFriend = _friend.isFriend;

    if (isFriend) {
        [_removeButton setHidden:NO];
        [_addButton setHidden:YES];
    } else {
        [_removeButton setHidden:YES];
        [_addButton setHidden:NO];
    }
}

#pragma mark -

- (void)accept {
	[_delegate acceptFriendSuggestion:_friend cell:self];
}

- (void)decline {
    [_delegate removeFriend:_friend];
}

#pragma mark -

- (void)hideAddButton {
    [_removeButton setHidden:YES];
    [_addButton setHidden:YES];
    CGRectSetWidth(_nameLabel.frame, widthLabel - 20.0f);
}

- (void)showAddButton {
    CGRectSetWidth(_nameLabel.frame, widthLabel - 50.0f);
    BOOL isFriend = _friend.isFriend;
    
    if (isFriend) {
        [_removeButton setHidden:NO];
        [_addButton setHidden:YES];
    } else {
        [_removeButton setHidden:YES];
        [_addButton setHidden:NO];
    }
}

@end
