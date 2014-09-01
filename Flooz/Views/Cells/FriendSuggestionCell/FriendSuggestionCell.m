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
    return 54;
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
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(15, 8, 38, 38)];
    [self.contentView addSubview:view];
}

- (void)createTextView{
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


- (void)createButtonView{
    UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 50, 13, 37, 28)];
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
    NSString *s = [NSString stringWithFormat:@"@%@", [_friend username]];
    view2.text = s;
    CGSize expectedLabelS = [s sizeWithAttributes:
                             @{NSFontAttributeName: view2.font}];
    CGRectSetHeight(view2.frame, expectedLabelS.height);
}

- (void)didButtonTouch{
    [_delegate acceptFriendSuggestion:[_friend userId]];
}

@end
