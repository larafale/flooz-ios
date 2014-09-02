//
//  FLStartItem.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLStartItem.h"

@implementation FLStartItem

+ (FLStartItem*) newWithTitle:(NSString*)title imageImageName:(NSString*)imageName contentText:(NSString*)contentText andSize:(CGFloat)size
{
    FLStartItem *startItem = [self newWithFrame:CGRectMake(0, 0, PPScreenWidth(), size)];
    UIImageView *imageView = [UIImageView newWithImageName:imageName];
    imageView.contentMode = UIViewContentModeCenter;
    [imageView setSize:CGSizeMake(size, size)];
    [startItem addSubview:imageView];
    return startItem;
}

- (void) setImageWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    if ([image isEqual:_imageViewIcon.image])
        return;
    
    _imageViewIcon.image = image;
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [_imageViewIcon.layer addAnimation:transition forKey:nil];
}

- (id) initWithImageName:(NSString *)imageName andSize:(CGFloat)size {
    self = [self initWithFrame:CGRectMake(0, 0, PPScreenWidth(), size)];
    _imageViewIcon = [UIImageView newWithImageName:imageName];
    _imageViewIcon.contentMode = UIViewContentModeCenter;
    [_imageViewIcon setSize:CGSizeMake(size, size)];
    [self addSubview:_imageViewIcon];
    return self;
}


@end
