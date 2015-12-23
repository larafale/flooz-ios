//
//  FLTableView.m
//  Flooz
//
//  Created by olivier on 12/30/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "FLTableView.h"
#import "TimelineViewController.h"

@implementation FLTableView {
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
	self.separatorInset = UIEdgeInsetsZero; // Permet d avoir le separateur qui fait toute la ligne de large

	self.backgroundColor = [UIColor customBackgroundHeader];
	self.separatorColor = [UIColor customSeparator];
	self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.showsVerticalScrollIndicator = YES;
}

- (UIEdgeInsets)layoutMargins {
	return UIEdgeInsetsZero;
}

@end
