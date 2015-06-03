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
	[self createButtonView];
}

- (void)createAvatarView {
    _avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(PADDING_SIDE, 8.0f, 38.0f, 38.0f)];
    [self.contentView addSubview:_avatarView];
}

- (void)createTextView {
    widthLabel = cellWidth - (CGRectGetMaxX(_avatarView.frame) + PADDING_SIDE + 50.0f);
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

- (void)createButtonView {
	_addButton = [[FriendButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame) - 50.0f, 13, 28, 28)];

	[_addButton setImage:[UIImage imageNamed:@"friends-field-add"] forState:UIControlStateNormal];
	[_addButton setImage:[UIImage imageNamed:@"friends-field-in"] forState:UIControlStateSelected];

	[_addButton addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    
//    [_addButton.layer setBorderWidth:1.0f];
//    [_addButton.layer setBorderColor:[UIColor customBlue].CGColor];
//    [_addButton.layer setCornerRadius:5.0f];

	[self.contentView addSubview:_addButton];
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
	_nameLabel.text = [_friend.fullname uppercaseString];
}

- (void)preparePhoneView {
	NSString *s = [@"@" stringByAppendingString : _friend.username];
	_subLabel.text = s;
	CGSize expectedLabelS = [s sizeWithAttributes:
	                         @{ NSFontAttributeName: _subLabel.font }];
	CGRectSetHeight(_subLabel.frame, expectedLabelS.height);
}

- (void)prepareCheckView {
	BOOL isFriend = NO;
	if ([[[[Flooz sharedInstance] currentUser] userId] isEqualToString:[_friend userId]]) {
		isFriend = YES;
	}
	else {
		for (FLUser *friend in[[[Flooz sharedInstance] currentUser] friends]) {
			if ([[friend userId] isEqualToString:[_friend userId]]) {
				isFriend = YES;
				break;
			}
		}
	}

	_addButton.userInteractionEnabled = !isFriend;
	_addButton.selected = isFriend;
//	[_addButton setHidden:isFriend];
}

#pragma mark -

- (void)accept {
	if (_addButton.selected) {
		return;
	}
	_addButton.selected = YES;
	[_delegate acceptFriendSuggestion:[_friend userId] cell:self];
}

#pragma mark -

- (void)hideAddButton {
	[_addButton setHidden:YES];
    CGRectSetWidth(_nameLabel.frame, widthLabel - 20.0f);
}

- (void)showAddButton {
    CGRectSetWidth(_nameLabel.frame, widthLabel - 50.0f);
	[_addButton setHidden:NO];
}

@end
