//
//  JTLoadView.h
//  Flooz
//
//  Created by jonathan on 1/16/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTLoadView : UIView

+ (void)execute:(BOOL (^)())block completion:(void (^)(BOOL success))completion;
+ (void)execute:(BOOL (^)())block completion:(void (^)(BOOL success))completion lockScreen:(BOOL)lockScreen;

- (void)show;
- (void)hide;

@end
