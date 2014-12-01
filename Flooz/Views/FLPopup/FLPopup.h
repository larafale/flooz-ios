//
//  FLPopup.h
//  Flooz
//
//  Created by Jonathan on 23/07/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPopup : UIView {
	UIView *background;

	void (^acceptBlock)(void);
	void (^refuseBlock)(void);
}

- (id)initWithMessage:(NSString *)message accept:(void (^)())accept refuse:(void (^)())refuse;
- (void)show;

@end
