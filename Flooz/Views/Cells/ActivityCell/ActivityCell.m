//
//  ActivityCell.m
//  Flooz
//
//  Created by Olivier on 2/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "ActivityCell.h"

#define MIN_HEIGHT 60
#define MARGE_TOP_BOTTOM 10.
#define MARGE_LEFT 10.
#define MARGE_RIGHT 10.
#define CONTENT_X 80.
#define DATE_VIEW_HEIGHT 15.

@implementation ActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self createViews];
	}
	return self;
}

+ (CGFloat)getHeightForActivity:(FLNotification *)activity forWidth:(CGFloat)widthCell {
	CGFloat height = 0;

	NSAttributedString *attributedText = [[NSAttributedString alloc]
	                                      initWithString:[activity content]
	                                          attributes:@{ NSFontAttributeName: [UIFont customContentRegular:13] }];
	CGRect rect = [attributedText boundingRectWithSize:(CGSize) {widthCell - CONTENT_X - MARGE_RIGHT, CGFLOAT_MAX }
	                                           options:NSStringDrawingUsesLineFragmentOrigin
	                                           context:nil];
	height += rect.size.height + 3; // +3 pour les emojis

	// Date
	height += DATE_VIEW_HEIGHT;

	height += MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM;

	return MAX(MIN_HEIGHT, height);
}

- (void)setActivity:(FLNotification *)activity {
	self->_activity = activity;
	[self prepareViews];
}

#pragma mark - Create Views

- (void)createViews {
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.backgroundColor = [UIColor customBackgroundHeader];

	[self createSeparatorView];
	[self createReadView];
	[self createAvatarView];
	[self createTextView];
	[self createDateView];
}

- (void)createSeparatorView {
	horizontalSeparator = [UIView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 0.5f)];
	horizontalSeparator.backgroundColor = [UIColor customSeparator];
	[self.contentView addSubview:horizontalSeparator];
}

- (void)createReadView {
	readView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT, MARGE_TOP_BOTTOM + 22.5, 5, 5)];
	readView.backgroundColor = [UIColor customBlue];
	readView.layer.cornerRadius = CGRectGetHeight(readView.frame) / 2.;
	[self.contentView addSubview:readView];
}

- (void)createAvatarView {
	userView = [[FLUserView alloc] initWithFrame:CGRectMake(MARGE_LEFT + 5 + MARGE_LEFT, MARGE_TOP_BOTTOM, 38.0f, 38.0f)];
	[self.contentView addSubview:userView];
}

- (void)createTextView {
	labelText = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_X, 0, PPScreenWidth() - CONTENT_X - MARGE_RIGHT, 0)];

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

	[self prepareContentView]; // Defini la hauteur du block
	[self prepareAvatarView];
	[self prepareReadView];
	[self prepareDateView];

	CGRectSetY(horizontalSeparator.frame, height - CGRectGetHeight(horizontalSeparator.frame));
}

- (void)prepareReadView {
	readView.hidden = _activity.isRead;
	readView.center = CGPointMake(readView.center.x, height / 2.);
}

- (void)prepareAvatarView {
	[userView setImageFromUser:[_activity user]];
	userView.center = CGPointMake(userView.center.x, height / 2.);
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
	dateView.text = [FLHelper momentWithDate:[_activity date]]; //[_activity dateText];
	[dateView setWidthToFit];

	CGRectSetX(dateView.frame, PPScreenWidth() - MARGE_RIGHT - CGRectGetWidth(dateView.frame));
	CGRectSetY(dateView.frame, height - DATE_VIEW_HEIGHT - 2);
}

@end
