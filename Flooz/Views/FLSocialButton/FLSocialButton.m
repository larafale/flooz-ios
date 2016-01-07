//
//  FLSocialButton.m
//  Flooz
//
//  Created by Arnaud on 2014-09-29.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLSocialButton.h"

@implementation FLSocialButton {
    NSString *imageName;
    NSString *titleText;
    UIColor *defaultColor;
    UIColor *selectedColor;
    
    UIImageView *image;
    UILabel *titleButton;
}

- (nullable id)initWithImageName:(NSString *)imageNamed color:(UIColor *)color selectedColor:(UIColor *)colorSelected title:(NSString *)title height:(CGFloat)height {
    self = [super initWithFrame:CGRectMake(0, 0, 0, height)];
    if (self) {
        imageName = imageNamed;
        
        defaultColor = color;
        if (!defaultColor)
            defaultColor = [UIColor whiteColor];
        
        selectedColor = colorSelected;
        
        if (!defaultColor)
            defaultColor = [UIColor customBackgroundSocial];

        titleText = title;
        
        [self createViews];
    }
    return self;
}

- (void)createViews {
    CGRectSetHeight(self.frame, 22.5);
    [self.layer setCornerRadius:5];
    [self createImage];
    [self createTitle];
}

- (void)createImage {
    image = [UIImageView newWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
    [image setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [image setTintColor:defaultColor];
    [image setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:image];
}

- (void)createTitle {
    titleButton = [UILabel newWithFrame:CGRectMake(CGRectGetMaxX(image.frame) + 3.0f, 0.0f, 10.0f, CGRectGetHeight(self.frame))];
    [titleButton setFont:[UIFont customContentRegular:12]];
    [titleButton setTextColor:defaultColor];
    [titleButton setNumberOfLines:1];
    
    [titleButton setText:titleText];
    CGRectSetWidth(titleButton.frame, [titleButton widthToFit]);
    CGRectSetHeight(titleButton.frame, [titleButton heightToFit]);
    [self addSubview:titleButton];
    
    CGRectSetY(titleButton.frame, CGRectGetHeight(self.frame) / 2 - CGRectGetHeight(titleButton.frame) / 2 + 1);
    
    CGRectSetWidth(self.frame, CGRectGetMaxX(titleButton.frame) + 5.0f);
}

- (void)setText:(nonnull NSString *)text {
    titleText = text;
    
    [titleButton setText:titleText];
    CGRectSetWidth(titleButton.frame, [titleButton widthToFit]);
    CGRectSetHeight(titleButton.frame, [titleButton heightToFit]);

    CGRectSetWidth(self.frame, CGRectGetMaxX(titleButton.frame) + 5.0f);
    CGRectSetY(titleButton.frame, CGRectGetHeight(self.frame) / 2 - CGRectGetHeight(titleButton.frame) / 2 + 1);
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [super addTarget:target action:action forControlEvents:controlEvents];
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [super addGestureRecognizer:gestureRecognizer];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (!selected) {
        [image setTintColor:defaultColor];
        [titleButton setTextColor:defaultColor];
    }
    else {
        [image setTintColor:selectedColor];
        [titleButton setTextColor:selectedColor];
    }
}

@end
