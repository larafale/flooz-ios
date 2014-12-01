//
//  NumPadAppleStyle.h
//  Flooz
//
//  Created by Arnaud on 2014-09-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NumPadAppleDelegate;

@interface NumPadAppleStyle : UIView

@property (weak, nonatomic) UIViewController <NumPadAppleDelegate> *delegate;

- (id)initWithHeight:(CGFloat)height;

@end

@protocol NumPadAppleDelegate <NSObject>

- (void)numberPressed:(NSInteger)number;

@end

@interface PadButton : UIButton

- (void)setHighlighted:(BOOL)highlighted;

@end
