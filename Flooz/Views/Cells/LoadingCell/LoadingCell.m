//
//  LoadingCell.m
//  Flooz
//
//  Created by jonathan on 2014-04-22.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "LoadingCell.h"

@implementation LoadingCell

- (id)init {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LoadingCell"];
	if (self) {
		[self prepareView];
	}
	return self;
}

+ (CGFloat)getHeight {
	return 44.;
}

- (void)prepareView {
	self.backgroundColor = self.contentView.backgroundColor = [UIColor clearColor];

	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[self.contentView addSubview:activityIndicatorView];

//    activityIndicatorView.color = [UIColor customSeparator:1.0];

	[activityIndicatorView startAnimating];
	activityIndicatorView.center = self.center;
}

@end
