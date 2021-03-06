//
//  ActivityCell.h
//  Flooz
//
//  Created by Olivier on 2/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCell : UITableViewCell {
	CGFloat height;

    UIView *readView;
	FLUserView *userView;
	UILabel *labelText;

	UIView *horizontalSeparator;

	UILabel *dateView;
}

+ (CGFloat)getHeightForNotification:(FLNotification *)notification forWidth:(CGFloat)widthCell;

@property (weak, nonatomic) FLNotification *notification;

@end
