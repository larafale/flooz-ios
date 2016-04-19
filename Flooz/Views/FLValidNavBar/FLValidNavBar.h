//
//  FLValidNavBar.h
//  Flooz
//
//  Created by Olivier on 1/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLValidNavBar : UIView {
	UIButton *cancel;
	UIButton *valid;
    UILabel *balance;
}

- (void)cancelAddTarget:(id)target action:(SEL)action;
- (void)validAddTarget:(id)target action:(SEL)action;

- (UIButton *)validView;

@end
