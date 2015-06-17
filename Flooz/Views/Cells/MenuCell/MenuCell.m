//
//  MenuCell.m
//  Flooz
//
//  Created by Arnaud on 2014-09-22.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		[self setBackgroundColor:[UIColor clearColor]];
		[self createImage];
		[self createTitle];
        [self createIndicator];
	}
	return self;
}

+ (CGFloat)getHeight {
    if (IS_IPHONE4) {
        return 40.0f;
    }
	return 50.0f;
}

- (void)createImage {
    CGFloat pad = 10.0f;
	_imageMenu = [[UIImageView alloc] initWithFrame:CGRectMake(25.0f, pad, [MenuCell getHeight] - pad*2.0f, [MenuCell getHeight] - pad*2.0f)];
	[self.contentView addSubview:_imageMenu];
}

- (void)createTitle {
    _titleMenu = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_imageMenu.frame) + 20, 0.0f, CGRectGetWidth(self.frame) - CGRectGetMaxX(_imageMenu.frame) - 20.0f, [MenuCell getHeight])];
    _titleMenu.textColor = [UIColor whiteColor];
    _titleMenu.font = [UIFont customTitleLight:16];
	[self.contentView addSubview:_titleMenu];
}

- (void)createIndicator {
    _indicatorMenu = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 60, ([MenuCell getHeight] - 8) / 2, 8, 8)];
    [_indicatorMenu setImage:[UIImage imageNamed:@"incomplete"]];
    [_indicatorMenu setHidden:YES];
    [self.contentView addSubview:_indicatorMenu];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];
	if (highlighted) {
		[self setBackgroundColor:[UIColor customBackgroundHeader]];
	}
	else {
		[self setBackgroundColor:[UIColor clearColor]];
	}
}

#pragma mark - Set

- (void)setMenu:(NSDictionary *)menuDic {
	_menuDico = menuDic;
	[self prepareViews];
}

#pragma mark - Prepare Views

- (void)prepareViews {
	[self prepareImageView];
	[self prepareTitleView];
    [self prepareIndicatorView];
}

- (void)prepareImageView {
    NSString *imageName = _menuDico[@"image"];
    if (imageName.length) {
        [_imageMenu setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_imageMenu setTintColor:[UIColor whiteColor]];
    }
    else {
        CGRectSetX(_titleMenu.frame, CGRectGetMidX(_imageMenu.frame));
    }
}

- (void)prepareTitleView {
	NSString *title = _menuDico[@"title"];
	[_titleMenu setText:[title uppercaseString]];
}

- (void)prepareIndicatorView {
    if (_menuDico[@"incomplete"])
        [_indicatorMenu setHidden:NO];
    else
        [_indicatorMenu setHidden:YES];
}

@end
