//
//  FLAccountUserView.h
//  Flooz
//
//  Created by jonathan on 1/23/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLAccountUserView : UIView {
	__weak FLUser *user;

	FLUserView *userView;
	UILabel *username;
	UILabel *fullname;
}

- (id)initWithWidth:(CGFloat)width;
- (void)reloadData;
- (void)addEditTarget:(id)target action:(SEL)action;
- (void)reloadAvatarWithImageData:(NSData *)imageData;

@end
