//
//  FriendPickerFriendCell.m
//  Flooz
//
//  Created by jonathan on 2014-03-17.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendPickerFriendCell.h"

@implementation FriendPickerFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeight
{
    return 54;
}

- (void)setUser:(FLUser *)user
{
    self->_user = user;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews
{
    self.backgroundColor = [UIColor customBackground];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self createAvatarView];
    [self createNameView];
    [self createPhoneView];
    [self createCheckView];
}

- (void)createAvatarView
{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(15, 8, 38, 38)];
    [self.contentView addSubview:view];
}

- (void)createNameView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, 17, CGRectGetWidth(self.frame) - 75, 11)];
    
    view.font = [UIFont customContentBold:13];
    view.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:view];
}

- (void)createPhoneView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, 31, CGRectGetWidth(self.frame) - 75, 9)];
    
    view.font = [UIFont customContentBold:11];
    view.textColor = [UIColor customPlaceholder];
    
    [self.contentView addSubview:view];
}

- (void)createCheckView
{
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 30, CGRectGetHeight(self.contentView.frame) / 2., 15, 10)];
    [self.contentView addSubview:view];
    
    view.image = [UIImage imageNamed:@"navbar-check"];
}

#pragma mark - Prepare Views

- (void)prepareViews
{
    [self prepareAvatarView];
    [self prepareNameView];
    [self preparePhoneView];
}

- (void)prepareAvatarView
{
    FLUserView *view = [[self.contentView subviews] objectAtIndex:0];
    [view setImageFromUser:_user];
}

- (void)prepareNameView
{
    UILabel *view = [[self.contentView subviews] objectAtIndex:1];
    view.text = [[_user fullname] uppercaseString];
}

- (void)preparePhoneView
{
    UILabel *view = [[self.contentView subviews] objectAtIndex:2];
    NSString *s = [NSString stringWithFormat:@"@%@", [_user username]];
    view.text = s;
    CGSize expectedLabelS = [s sizeWithAttributes:
                             @{NSFontAttributeName: view.font}];
    CGRectSetHeight(view.frame, expectedLabelS.height);
}

- (void)setSelectedCheckView:(BOOL)selected
{
    UIImageView *checkView = [[self.contentView subviews] objectAtIndex:3];
    checkView.hidden = !selected;
}

@end
