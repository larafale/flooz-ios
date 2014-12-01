//
//  FLStartItem.h
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLStartItem : UIView

@property (strong, nonatomic) UIImageView *imageViewIcon;

+ (FLStartItem *)newWithTitle:(NSString *)title imageImageName:(NSString *)imageName contentText:(NSString *)contentText andSize:(CGFloat)size;
- (void)setImageWithImageName:(NSString *)imageName;
- (id)initWithImageName:(NSString *)imageName andSize:(CGFloat)size;

@end
