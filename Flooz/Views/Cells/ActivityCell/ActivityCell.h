//
//  ActivityCell.h
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityCell : UITableViewCell {
	CGFloat height;

    UIView *readView;
	FLUserView *userView;
	UILabel *labelText;

	UIView *horizontalSeparator;

	UILabel *dateView;
}

+ (CGFloat)getHeightForActivity:(FLActivity *)activity forWidth:(CGFloat)widthCell;

@property (weak, nonatomic) FLActivity *activity;

@end
