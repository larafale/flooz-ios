//
//  FriendSuggestionCell.m
//  Flooz
//
//  Created by jonathan on 2/28/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendSuggestionCell.h"

@implementation FriendSuggestionCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeight{
    return 50;
}

- (void)setFriend:(FLUser *)friend{
    self->_friend = friend;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor customBackground];
    
    [self createAvatarView];
    [self createTextView];
    [self createPhoneView];
//    [self createButtonView];
}

- (void)createAvatarView{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(15, 5, 40, 40)];
    [self.contentView addSubview:view];
}

- (void)createTextView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, - 5, CGRectGetWidth(self.frame) - 75, [[self class] getHeight])];
    
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont customTitleLight:13];
    
    [self.contentView addSubview:view];
}

- (void)createPhoneView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, 28, CGRectGetWidth(self.frame) - 75, 9)];
    
    view.font = [UIFont customContentBold:11];
    view.textColor = [UIColor customPlaceholder];
    
    [self.contentView addSubview:view];
}


- (void)createButtonView{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 50, 11, 37, 28)];
    [view setImage:[UIImage imageNamed:@"Signup_Friends_Plus"] forState:UIControlStateNormal];
    view.backgroundColor = [UIColor customBackgroundStatus];
    view.layer.cornerRadius = 14;
    
    [view addTarget:self action:@selector(didButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:view];
}

#pragma mark - Prepare Views

- (void)prepareViews{
    [self prepareAvatarView];
    [self prepapreTextView];
}

- (void)prepareAvatarView{
    FLUserView *view = [[self.contentView subviews] objectAtIndex:0];
    [view setImageFromUser:_friend];
}

- (void)prepapreTextView{
    UILabel *view = [[self.contentView subviews] objectAtIndex:1];
    view.text = [[_friend fullname] uppercaseString];
    
    UILabel *view2 = [[self.contentView subviews] objectAtIndex:2];
    view2.text = [NSString stringWithFormat:@"@%@", [_friend username]];
}

- (void)didButtonTouch{
    [_delegate acceptFriendSuggestion:[_friend userId]];
}

@end
