//
//  JTImageLabel.h
//
//  Created by jonathan on 2013-03-15.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTImageLabel : UILabel{
    UIImageView *_imageView;
    CGPoint _imageOffset;
}

@property (assign, nonatomic) BOOL imageHidden;

- (void)setImage:(UIImage *)image;
- (void)setImageOffset:(CGPoint)offset;

@end
