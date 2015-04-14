//
//  FLActionButton.h
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIControlEventStateChanged  (1 << 24)

#define FLActionButtonDefaultHeight 40
#define FLActionButtonImageTag 12

@interface FLActionButton : UIButton

@property (nonatomic, retain) UIImageView *imageView;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

- (void)setImage:(UIImage *)image size:(CGSize)size;
- (void)setImageWithURL:(NSString *)imageURL size:(CGSize)size;
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;

@end
