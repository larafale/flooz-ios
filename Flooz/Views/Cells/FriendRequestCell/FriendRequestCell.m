//
//  FriendRequestCell.m
//  Flooz
//
//  Created by olivier on 2/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FriendRequestCell.h"

#define PADDING_SIDE 10.0f

@implementation FriendRequestCell {
	UILabel *_nameLabel;
	UILabel *_subLabel;
    UIImageView *_certifImageView;
    
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

- (void)setFriendRequest:(FLFriendRequest *)friendRequest {
	self->_friendRequest = friendRequest;
	[self prepareViews];
}

#pragma mark - Create Views

- (void)createViews {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.backgroundColor = [UIColor clearColor];

	[self createAvatarView];
	[self createTextView];
    [self createCertifView];
	[self createSubTextView];
	[self createButtons];
}

- (void)createAvatarView {
	_avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(PADDING_SIDE, 8, 38.0f, 38.0f)];
	[self.contentView addSubview:_avatarView];
}

- (void)createTextView {
	_nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarView.frame) + PADDING_SIDE, 17.0f, cellWidth - (CGRectGetMaxX(_avatarView.frame) + PADDING_SIDE + 50.0f), 14)];

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

- (void)createButtons {
	_addButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_nameLabel.frame) - 50.0f, 13, 37, 28)];
	_addButton.layer.cornerRadius = 14;

	[_addButton setImage:[UIImage imageNamed:@"cell_friend_add"] forState:UIControlStateNormal];
	[_addButton setImage:[UIImage imageNamed:@"Signup_Friends_Selected"] forState:UIControlStateSelected];
    
    [_addButton.layer setBorderWidth:1.0f];
    [_addButton.layer setBorderColor:[UIColor customBlue].CGColor];
    [_addButton.layer setCornerRadius:5.0f];

	[self.contentView addSubview:_addButton];
}

#pragma mark - Prepare Views

- (void)prepareViews {
	[self prepareAvatarView];
	[self prepapreTextView];
	[self prepapreSubTextView];
}

- (void)prepareAvatarView {
	[_avatarView setImageFromUser:[_friendRequest user]];
}

- (void)prepapreTextView {
	_nameLabel.text = [[[_friendRequest user] fullname] uppercaseString];
    [_nameLabel setWidthToFit];
    
    if ([[_friendRequest user] isStar] || [[_friendRequest user] isPro]) {
        [_certifImageView setHidden:NO];
        CGRectSetX(_certifImageView.frame, CGRectGetMaxX(_nameLabel.frame) + 5);
    } else {
        [_certifImageView setHidden:YES];
    }
}

- (void)prepapreSubTextView {
	NSString *s = [NSString stringWithFormat:@"@%@", [[_friendRequest user] username]];
	_subLabel.text = s;
	CGSize expectedLabelS = [s sizeWithAttributes:
	                         @{ NSFontAttributeName: _subLabel.font }];
	CGRectSetHeight(_subLabel.frame, expectedLabelS.height);
}

- (void)accept {
	[[Flooz sharedInstance] updateFriendRequest:@{ @"id": [_friendRequest requestId], @"action": @"accept" } success: ^{
	    [_delegate didReloadData];
	}];
}

- (void)refuse {
	[[Flooz sharedInstance] updateFriendRequest:@{ @"id": [_friendRequest requestId], @"action": @"decline" } success: ^{
	    [_delegate didReloadData];
	}];
}

#pragma mark -

- (void)hideAddButton {
    [_addButton setHidden:YES];
}

- (void)showAddButton {
    [_addButton setHidden:NO];
}


@end
