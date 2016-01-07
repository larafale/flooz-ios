//
//  FLSocialButton.h
//  Flooz
//
//  Created by Arnaud on 2014-09-29.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLSocialButton : UIButton

- (nullable id)initWithImageName:(NSString *)imageNamed color:(UIColor *)color selectedColor:(UIColor *)colorSelected title:(NSString *)title height:(CGFloat)height;
- (void)setText:(nonnull NSString *)text;

@end
