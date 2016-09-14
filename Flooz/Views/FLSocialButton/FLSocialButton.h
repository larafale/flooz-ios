//
//  FLSocialButton.h
//  Flooz
//
//  Created by Arnaud on 2014-09-29.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLSocialButton : UIButton

- (nullable id)initWithImageName:(nonnull NSString *)imageNamed color:(nonnull UIColor *)color selectedColor:(nonnull UIColor *)colorSelected title:(nonnull NSString *)title height:(CGFloat)height;
- (void)setText:(nonnull NSString *)text;

@end
