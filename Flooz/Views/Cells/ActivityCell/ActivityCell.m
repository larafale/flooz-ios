//
//  ActivityCell.m
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "ActivityCell.h"

#define MIN_HEIGHT 60
#define MARGE_TOP_BOTTOM 10.
#define MARGE_LEFT 10.
#define MARGE_RIGHT 20.
#define CELL_WIDTH 290.
#define CONTENT_X 80.
#define DATE_VIEW_HEIGHT 15.

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
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){CELL_WIDTH - CONTENT_X - MARGE_RIGHT, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    height += rect.size.height;
    
    // Date
    height += DATE_VIEW_HEIGHT;
    
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
    
    [self createSeparatorViews];
    [self createReadView];
    [self createAvatarView];
    [self createContentView];
    [self createDateView];
}

- (void)createReadView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT, MARGE_TOP_BOTTOM + 22.5, 5, 5)];
    view.backgroundColor = [UIColor customBlue];
    view.layer.cornerRadius = CGRectGetHeight(view.frame) / 2.;
    [self.contentView addSubview:view];
}

- (void)createAvatarView
{
    userView = [[FLUserView alloc] initWithFrame:CGRectMake(MARGE_LEFT + 5 + MARGE_LEFT, MARGE_TOP_BOTTOM, 30, 30)];
    [self.contentView addSubview:userView];
    
    CGRectSetX(horizontalSeparator.frame, userView.center.x);
}

- (void)createContentView
{
    contentView = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_X, 0, CELL_WIDTH - CONTENT_X - MARGE_RIGHT, 0)];
    
    contentView.textColor = [UIColor whiteColor];
    contentView.numberOfLines = 0;
    contentView.font = [UIFont customContentRegular:13];
    
    [self.contentView addSubview:contentView];
    
    CGRectSetX(verticalSeparator.frame, contentView.frame.origin.x);
    CGRectSetWidth(verticalSeparator.frame, CGRectGetWidth(contentView.frame));
}

- (void)createSeparatorViews
{
    horizontalSeparator = [UIView new];
    horizontalSeparator.backgroundColor = [UIColor customSeparator];
    CGRectSetWidth(horizontalSeparator.frame, 1);
    [self.contentView addSubview:horizontalSeparator];
    
    verticalSeparator = [UIView new];
    verticalSeparator.backgroundColor = [UIColor customSeparator];
    CGRectSetHeight(verticalSeparator.frame, 1);

    [self.contentView addSubview:verticalSeparator];
}

- (void)createDateView
{
    dateView = [[UILabel alloc] initWithFrame:CGRectMakeSize(0, DATE_VIEW_HEIGHT)];

    dateView.textAlignment = NSTextAlignmentRight;
    dateView.textColor = [UIColor customPlaceholder];
    dateView.font = [UIFont customContentLight:9];
    
    [self.contentView addSubview:dateView];
}

#pragma mark - Prepare Views

- (void)prepareViews{
    height = 0;
    
    [self prepareContentView]; // Defini la hauteur du block
    [self prepareAvatarView];
    [self prepareReadView];
    [self prepareDateView];

    CGRectSetHeight(horizontalSeparator.frame, height);
    CGRectSetY(verticalSeparator.frame, height - 1);
    CGRectSetHeight(self.frame, height);
}

- (void)prepareReadView
{
    UIView *view = [[self.contentView subviews] objectAtIndex:2];
    view.hidden = _activity.isRead;
    view.center = CGPointMake(view.center.x, height / 2.);
}

- (void)prepareAvatarView{
    [userView setImageFromUser:[_activity user]];

    userView.center = CGPointMake(userView.center.x, height / 2.);
}

- (void)prepareContentView{    
    contentView.text = [_activity content];
    
    [contentView setHeightToFit];
    
    height = CGRectGetHeight(contentView.frame) + MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM + DATE_VIEW_HEIGHT;
    if(height < MIN_HEIGHT){
        height = MIN_HEIGHT;
    }
    
    contentView.center = CGPointMake(contentView.center.x, height / 2.);
}

- (void)prepareDateView
{
    dateView.text = [_activity dateText];
    [dateView setWidthToFit];
    
    CGRectSetX(dateView.frame, CELL_WIDTH - MARGE_RIGHT - CGRectGetWidth(dateView.frame));
    CGRectSetY(dateView.frame, height - DATE_VIEW_HEIGHT - 2);
}

@end
