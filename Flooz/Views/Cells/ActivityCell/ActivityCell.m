//
//  ActivityCell.m
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "ActivityCell.h"

#define MIN_HEIGHT 60
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
    CGFloat height = 0;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                      initWithString:[activity content]
                      attributes:@{NSFontAttributeName: [UIFont customContentRegular:13]}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){SCREEN_WIDTH - 96 - MARGE_LEFT_RIGHT, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    height += rect.size.height;
    
    height += MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM;
    
    return MAX(MIN_HEIGHT, height);
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
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(63, 0, 14, 9)];
    
    [self.contentView addSubview:view];
}

- (void)createContentView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(96, 0, CGRectGetWidth(self.frame) - 96 - MARGE_LEFT_RIGHT, 0)];
    
    view.textColor = [UIColor whiteColor];
    view.numberOfLines = 0;
    view.font = [UIFont customContentRegular:13];
    
    [self.contentView addSubview:view];
}

#pragma mark - Prepare Views

- (void)prepareViews{
    height = 0;
    
    [self prepareContentView]; // Defini la hauteur du block
    [self prepareAvatarView];
    [self prepareTypeView];
    
    self.frame = CGRectSetHeight(self.frame, height);
}

- (void)prepareAvatarView{
    FLUserView *view = [[self.contentView subviews] objectAtIndex:0];
    
    [view setImageFromUser:[_activity user]];
    
    view.center = CGPointMake(view.center.x, height / 2.);
}

- (void)prepareTypeView{
    UIImageView *view = [[self.contentView subviews] objectAtIndex:1];
    
    switch ([_activity type]) {
        case ActivityTypeCommentTransaction:
        case ActivityTypeCommentEvent:
            view.image = [UIImage imageNamed:@"activity-comment"];
            break;
        case ActivityTypeLikeTransaction:
        case ActivityTypeLikeEvent:
            view.image = [UIImage imageNamed:@"activity-like"];
            break;
        case ActivityTypeFriendRequest:
            view.image = [UIImage imageNamed:@"activity-friend-request"];
            break;
        case ActivityTypeFriendRequestAccepted:
            view.image = [UIImage imageNamed:@"activity-friend-request-accepted"];
            break;
        case ActivityTypeFriendJoined:
            view.image = [UIImage imageNamed:@"activity-friend-joined"];
            break;
        default:
            NSLog(@"ActivityCell unknown activity type");
            view.image = nil;
            break;
    }
    
    view.center = CGPointMake(view.center.x, height / 2.);
}

- (void)prepareContentView{
    UILabel *view = [[self.contentView subviews] objectAtIndex:2];
    
    view.text = [_activity content];
    
    [view setHeightToFit];
    
    height = CGRectGetHeight(view.frame) + MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM;
    if(height < MIN_HEIGHT){
        height = MIN_HEIGHT;
    }
    
    view.center = CGPointMake(view.center.x, height / 2.);
}

@end
