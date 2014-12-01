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
    _titleMenu.font = [UIFont customTitleExtraLight:20];
	[self.contentView addSubview:_titleMenu];
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
}

- (void)prepareImageView {
    NSString *imageName = _menuDico[@"image"];
    if (imageName.length) {
        [_imageMenu setImage:[UIImage imageNamed:imageName]];
    }
    else {
        CGRectSetX(_titleMenu.frame, CGRectGetMidX(_imageMenu.frame));
    }
}

- (void)prepareTitleView {
	NSString *title = _menuDico[@"title"];
	[_titleMenu setText:title];
}

@end
