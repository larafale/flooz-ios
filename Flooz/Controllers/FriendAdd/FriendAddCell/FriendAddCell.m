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
    [self createPhoneView];
    [self createButtons];
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

- (void)createButtons
{
    _addButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 50, 13, 37, 28)];
    //view.backgroundColor = [UIColor customBackgroundStatus];
    _addButton.layer.cornerRadius = 14;
    
    [_addButton setImage:[UIImage imageNamed:@"Signup_Friends_Plus"] forState:UIControlStateNormal];
    [_addButton setImage:[UIImage imageNamed:@"Signup_Friends_Selected"] forState:UIControlStateSelected];
    
    [_addButton addTarget:self action:@selector(accept) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_addButton];
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

- (void)prepareCheckView
{
    UIButton *view = [[self.contentView subviews] objectAtIndex:3];
    
    BOOL isFriend = NO;
    if([[[[Flooz sharedInstance] currentUser] userId] isEqualToString:[_user userId]]){
        isFriend = YES;
    }
    else{
        for(FLUser *friend in [[[Flooz sharedInstance] currentUser] friends]){
            if([[friend userId] isEqualToString:[_user userId]]){
                isFriend = YES;
                break;
            }
        }
    }
    
    view.userInteractionEnabled = !isFriend;
    view.selected = isFriend;
}

#pragma mark -

- (void)accept
{
    UIButton *view = [[self.contentView subviews] objectAtIndex:3];
    
    if(view.selected){
        return;
    }
    
    [[Flooz sharedInstance] friendAcceptSuggestion:[_user userId] success:nil];
    view.selected = YES;
}

#pragma mark -

- (void) hideAddButton {
    [_addButton setHidden:YES];
}


@end
