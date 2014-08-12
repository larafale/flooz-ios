//
//  FLStartItem.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLStartItem.h"

@implementation FLStartItem

+ (FLStartItem*) newWithTitle:(NSString*)title imageImageName:(NSString*)imageName contentText:(NSString*)contentText
{
    FLStartItem *startItem = [self newWithFrame:CGRectMake(0, 0, PPScreenWidth(), 100)];
    UIImageView *imageView = [UIImageView newWithImageName:imageName];
    imageView.contentMode = UIViewContentModeCenter;
    [imageView setSize:CGSizeMake(100.0f, 100.0f)];
    [startItem addSubview:imageView];
    return startItem;
}

@end
