//
//  ActivityCell.m
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "ActivityCell.h"

#define MARGE_TOP_BOTTOM 5.
#define MARGE_LEFT_RIGHT 10.

@implementation ActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeightForActivity:(FLActivity *)activity{
    return 53;
}

- (void)setActivity:(FLActivity *)activity{
    self->_activity = activity;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor customBackground];
    
    [self createAvatarView];
    [self createTypeView];
    [self createContentView];
}

- (void)createAvatarView{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP_BOTTOM, 42, 42)];
    [self.contentView addSubview:view];
}

- (void)createTypeView{
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(60, 0, 0, 0)];
    
    [self.contentView addSubview:view];
}

- (void)createContentView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [self.contentView addSubview:view];
}

#pragma mark - Prepare Views

- (void)prepareViews{
    height = 0;
    
    [self prepareAvatarView];
    [self prepareTypeView];
    [self prepareContentView];
    
    self.frame = CGRectSetHeight(self.frame, height);
}

- (void)prepareAvatarView{
    FLUserView *view = [[self.contentView subviews] objectAtIndex:0];
    
    [view setImageFromUser:[_activity user]];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareTypeView{
    UIImageView *view = [[self.contentView subviews] objectAtIndex:1];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareContentView{
    UILabel *view = [[self.contentView subviews] objectAtIndex:2];
    
    height = CGRectGetMaxY(view.frame);
}

@end
