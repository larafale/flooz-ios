//
//  FLSocialButton.h
//  Flooz
//
//  Created by Arnaud on 2014-09-29.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLSocialButton : UIButton


@property (nonatomic, strong) NSString *imageNamedNormal;
@property (nonatomic, strong) NSString *imageNamedSelected;
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *titleButton;

- (instancetype)initWithImageName:(NSString *)imageNamed imageSelected:(NSString *)imageNamedSelected title:(NSString *)title andHeight:(CGFloat)height;

@end
