//
//  FLPopupInformation.h
//  Flooz
//
//  Created by Arnaud on 2014-09-10.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPopupInformation : UIView {
	UIView *background;
	void (^okBlock)(void);
}

- (id)initWithTitle:(NSString *)title andMessage:(NSAttributedString *)message ok:(void (^)())ok;
- (void)show;

@end
