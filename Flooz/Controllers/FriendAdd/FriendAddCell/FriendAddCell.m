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
    return 50;
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
    [self createButtons];
}

- (void)createAvatarView
{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(15, 5, 40, 40)];
    [self.contentView addSubview:view];
}

- (void)createNameView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, - 5, CGRectGetWidth(self.frame) - 75, [[self class] getHeight])];
    
    view.font = [UIFont customTitleLight:13];
    view.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:view];
}

- (void)createPhoneView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, 28, CGRectGetWidth(self.frame) - 75, 9)];
    
    view.font = [UIFont customContentBold:11];
    view.textColor = [UIColor customPlaceholder];
    
    [self.contentView addSubview:view];
}

- (void)createButtons
{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 50, 11, 37, 28)];
    view.backgroundColor = [UIColor customBackgroundStatus];
    view.layer.cornerRadius = 14;
    
    [view setImage:[UIImage imageNamed:@"friends-add"] forState:UIControlStateNormal];
    [view setImage:[UIImage imageNamed:@"friend-accept"] forState:UIControlStateSelected];
    
    [view addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:view];
}

#pragma mark - Prepare Views

- (void)prepareViews
{
    [self prepareAvatarView];
    [self prepareNameView];
    [self preparePhoneView];
    
    [self prepareCheckView];
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
    UILabel *view = [[self.contentView subviews] objectAtIndex:2];
    view.text = [NSString stringWithFormat:@"@%@", [_user username]];
}

- (void)prepareCheckView
{
    UIButton *view = [[self.contentView subviews] objectAtIndex:3];
    view.selected = NO;
}

#pragma mark -

- (void)accept
{
    [[Flooz sharedInstance] friendAcceptSuggestion:[_user userId] success:nil];
    
    UIButton *view = [[self.contentView subviews] objectAtIndex:3];
    view.selected = YES;
}


@end
