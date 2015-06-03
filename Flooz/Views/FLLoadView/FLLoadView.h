//
//  FLLoadView.h
//  Flooz
//
//  Created by olivier on 1/16/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLLoadView : UIView

+ (void)execute:(BOOL (^)())block completion:(void (^)(BOOL success))completion;
+ (void)execute:(BOOL (^)())block completion:(void (^)(BOOL success))completion lockScreen:(BOOL)lockScreen;

- (void)show;
- (void)hide;

@end
