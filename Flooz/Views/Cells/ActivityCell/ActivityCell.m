//
//  ActivityCell.m
//  Flooz
//
//  Created by Olive on 4/20/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ActivityCell.h"

#define MIN_HEIGHT 60
#define MARGE_TOP_BOTTOM 10.
#define MARGE_LEFT 10.
#define MARGE_RIGHT 10.
#define CONTENT_X 80.
#define DATE_VIEW_HEIGHT 15.

@interface ActivityCell () {
    
    CGFloat height;
    
    UIImageView *iconView;
    UILabel *labelText;
    
    UIView *horizontalSeparator;
    
    UILabel *dateView;
}

@end

@implementation ActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeightForActivity:(FLActivity *)activity {
    CGFloat height = 0;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                                          initWithString:[activity content]
                                          attributes:@{ NSFontAttributeName: [UIFont customContentRegular:13] }];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize) {PPScreenWidth() - CONTENT_X - MARGE_RIGHT, CGFLOAT_MAX }
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    height += rect.size.height + 3; // +3 pour les emojis
    
    // Date
    height += DATE_VIEW_HEIGHT;
    
    height += MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM;
    
    return MAX(MIN_HEIGHT, height);
}

- (void)setActivity:(FLActivity *)activity {
    self->_activity = activity;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor customBackgroundHeader];
    
    [self createIconView];
    [self createTextView];
    [self createDateView];
}

- (void)createIconView {
    iconView = [[UIImageView alloc] initWithFrame:CGRectMake(MARGE_LEFT, MARGE_TOP_BOTTOM, 38.0f, 38.0f)];
    iconView.contentMode = UIViewContentModeCenter;
    iconView.layer.cornerRadius = CGRectGetHeight(iconView.frame) / 2;
    iconView.layer.masksToBounds = YES;
    iconView.tintColor = [UIColor whiteColor];
    
    [self.contentView addSubview:iconView];
}

- (void)createTextView {
    labelText = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxY(iconView.frame) + MARGE_RIGHT, 0, PPScreenWidth() - CGRectGetMaxY(iconView.frame) - 2 * MARGE_RIGHT, 0)];
    
    labelText.textColor = [UIColor whiteColor];
    labelText.numberOfLines = 0;
    labelText.font = [UIFont customContentRegular:13];
    
    [self.contentView addSubview:labelText];
}

- (void)createDateView {
    dateView = [[UILabel alloc] initWithFrame:CGRectMakeSize(0, DATE_VIEW_HEIGHT)];
    
    dateView.textAlignment = NSTextAlignmentRight;
    dateView.textColor = [UIColor customPlaceholder];
    dateView.font = [UIFont customContentLight:9];
    
    [self.contentView addSubview:dateView];
}


#pragma mark - Prepare Views

- (void)prepareViews {
    height = 0;
    
    [self prepareContentView];
    [self prepareIconView];
    [self prepareDateView];
}

- (void)prepareIconView {
    [iconView setImage:[[FLHelper imageWithImage:[UIImage imageNamed:[_activity icon]] scaledToSize:CGSizeMake(20, 20)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [iconView setBackgroundColor:_activity.backIconColor];
    
    if ([_activity imgURL] && ![[_activity imgURL] isBlank]) {
        [iconView sd_setImageWithURL:[NSURL URLWithString:[_activity imgURL]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image && !error) {
                [iconView setImage:[[FLHelper imageWithImage:image scaledToSize:CGSizeMake(20, 20)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            }
        }];
    }
    
    iconView.center = CGPointMake(iconView.center.x, height / 2.);
}

- (void)prepareContentView {
    labelText.text = [_activity content];
    [labelText setHeightToFit];
    CGRectSetHeight(labelText.frame, CGRectGetHeight(labelText.frame) + 3); // + 3 pour emojis
    
    height = CGRectGetHeight(labelText.frame) + MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM + DATE_VIEW_HEIGHT;
    if (height < MIN_HEIGHT) {
        height = MIN_HEIGHT;
    }
    
    labelText.center = CGPointMake(labelText.center.x, height / 2.);
}

- (void)prepareDateView {
    dateView.text = [FLHelper momentWithDate:[_activity date]];
    [dateView setWidthToFit];
    
    CGRectSetX(dateView.frame, PPScreenWidth() - MARGE_RIGHT - CGRectGetWidth(dateView.frame));
    CGRectSetY(dateView.frame, height - DATE_VIEW_HEIGHT - 2);
}

@end
