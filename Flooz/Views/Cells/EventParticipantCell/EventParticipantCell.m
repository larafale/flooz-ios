//
//  EventParticipantCell.m
//  Flooz
//
//  Created by jonathan on 2/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventParticipantCell.h"

@implementation EventParticipantCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeight{
    return 70;
}

- (void)setUser:(FLUser *)user{
    self->_user = user;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor customBackground];
    
    [self createAvatarView];
    [self createTextView];
    [self createUsernameView];
    [self createAmountView];
}

- (void)createAvatarView{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(15, 15, 40, 40)];
    [self.contentView addSubview:view];
}

- (void)createTextView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, CGRectGetWidth(self.frame) - 70 - 60 - 15, [[self class] getHeight])];
    
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont customTitleLight:13];
    
    [self.contentView addSubview:view];
}


- (void)createUsernameView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, CGRectGetWidth(self.frame) - 70 - 60 - 15, [[self class] getHeight])];
    
    view.font = [UIFont customContentRegular:10];
    view.textColor = [UIColor customBlue];
    
    [self.contentView addSubview:view];
}

- (void)createAmountView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 60 - 15, 0, 60, [[self class] getHeight])];
    
    view.textColor = [UIColor customPlaceholder];
    view.font = [UIFont customContentRegular:12];
    view.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:view];
}

#pragma mark - Prepare Views

- (void)prepareViews{
    [self prepareAvatarView];
    [self prepapreTextView];
    [self prepapreUsernameView];
    [self prepapreAmountView];
}

- (void)prepareAvatarView{
    FLUserView *view = [[self.contentView subviews] objectAtIndex:0];
    [view setImageFromUser:_user];
}

- (void)prepapreTextView{
    UILabel *view = [[self.contentView subviews] objectAtIndex:1];
    view.text = [[_user fullname] uppercaseString];
    [view setWidthToFit];
}

- (void)prepapreUsernameView{
    UILabel *view = [[self.contentView subviews] objectAtIndex:2];
    view.text = [NSString stringWithFormat:@"@%@", [_user username]];
    
    UILabel *titleLabel = [[self.contentView subviews] objectAtIndex:1];
    CGRectSetX(view.frame, CGRectGetMaxX(titleLabel.frame) + 5);
}

- (void)prepapreAmountView{
    UILabel *view = [[self.contentView subviews] objectAtIndex:3];
    
    if([[_user amount] floatValue] > 0){
        view.text = [FLHelper formatedAmount:[_user amount] withSymbol:NO];
    }
    else{
        view.text = @"-";
    }
}

@end
