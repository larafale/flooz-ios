//
//  FLBorderedActionButton.h
//  Flooz
//
//  Created by Epitech on 9/17/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIControlEventStateChanged  (1 << 24)

@interface FLBorderedActionButton : UIButton

@property (nonatomic, retain) UIImageView *imageView;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

- (void)setImage:(UIImage *)image size:(CGSize)size;
- (void)setImageWithURL:(NSString *)imageURL size:(CGSize)size;
- (void)centerImage;
- (void)centerImage:(CGFloat)margin;

@end
