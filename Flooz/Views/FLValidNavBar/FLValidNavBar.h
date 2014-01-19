//
//  FLValidNavBar.h
//  Flooz
//
//  Created by jonathan on 1/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLValidNavBar : UIView{
    UIButton *cancel;
    UIButton *valid;
}

- (void)cancelAddTarget:(id)target action:(SEL)action;
- (void)validAddTarget:(id)target action:(SEL)action;

@end
