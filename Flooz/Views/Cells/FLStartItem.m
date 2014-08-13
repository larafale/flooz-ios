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

@end
