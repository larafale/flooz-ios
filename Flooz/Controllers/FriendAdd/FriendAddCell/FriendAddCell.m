//
//  FriendAddCell.m
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendAddCell.h"

@implementation FriendAddCell

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
//    [self createPhoneView];
}

- (void)createAvatarView
{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(15, 8, 38, 38)];
    [self.contentView addSubview:view];
}

- (void)createNameView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, 18, CGRectGetWidth(self.frame) - 75, 11)];
    
    view.font = [UIFont customContentBold:11];
    view.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:view];
}

- (void)createPhoneView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, 29, CGRectGetWidth(self.frame) - 75, 9)];
    
    view.font = [UIFont customContentBold:9];
    view.textColor = [UIColor customPlaceholder];
    
    [self.contentView addSubview:view];
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
    
    view.text = [_user fullname];
}

- (void)preparePhoneView
{
//    UILabel *view = [[self.contentView subviews] objectAtIndex:2];
    
//    view.text = [_contact objectForKey:@"value"];
}

@end
