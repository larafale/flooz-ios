//
//  FriendPickerFriendCell.m
//  Flooz
//
//  Created by olivier on 2014-03-17.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FriendPickerFriendCell.h"

#define PADDING_SIDE 10.0f

@implementation FriendPickerFriendCell {
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

- (void)setUser:(FLUser *)user {
    self->_user = user;
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
    _avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(PADDING_SIDE, 8.0f, 38.0f, 38.0f)];
    [self.contentView addSubview:_avatarView];
}

- (void)createNameView {
    widthLabel = CGRectGetWidth(self.contentView.frame) - 75.0f;
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
    if (_user.userKind == PhoneUser)
        [_avatarView setImageFromData:_user.avatarData];
    else
        [_avatarView setImageFromUser:_user];
}

- (void)prepareNameView {
    _nameLabel.text = [_user.fullname uppercaseString];
}

- (void)preparePhoneView {
    NSString *s = @"";
    if (_user.userKind == PhoneUser || _user.userKind == CactusUser) {
        s = _user.phone;
    } else {
      s = [@"@" stringByAppendingString : _user.username];
    }
    _subLabel.text = s;
    CGSize expectedLabelS = [s sizeWithAttributes:
                             @{ NSFontAttributeName: _subLabel.font }];
    CGRectSetHeight(_subLabel.frame, expectedLabelS.height);
}

- (void)setSelectedCheckView:(BOOL)selected {
    UIImageView *checkView = [[self.contentView subviews] objectAtIndex:3];
    checkView.hidden = !selected;
}

@end
