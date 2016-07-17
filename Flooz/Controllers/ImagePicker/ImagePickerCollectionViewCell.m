//
//  ImagePickerCollectionViewCell.m
//  Flooz
//
//  Created by Olive on 16/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ImagePickerCollectionViewCell.h"
#import "LBCircleView.h"

@interface ImagePickerCollectionViewCell () {
    UIProgressView *progressView;
    FLAnimatedImageView *imageView;
    LBCircleView *imageProgressView;

}

@end

@implementation ImagePickerCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        imageView = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        imageView.backgroundColor = [UIColor customBackground];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 2.0;
        
        imageProgressView = [[LBCircleView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) / 4, CGRectGetHeight(frame) / 4, CGRectGetWidth(frame) / 2, CGRectGetHeight(frame) / 2)];
        imageProgressView.percentColor = [UIColor clearColor];
        [imageProgressView setCircleColor:[UIColor customBlue]];
        [imageProgressView setBackgroundColor:[UIColor customPlaceholder]];
        
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame) - 2, CGRectGetWidth(frame), 2)];
        progressView.hidden = YES;
        
        [self.contentView addSubview:imageView];
        [imageView addSubview:imageProgressView];
        [imageView addSubview:progressView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)resetProgressBar {
    [progressView setProgress:0];
    progressView.trackTintColor = self.backgroundColor;
    progressView.tintColor = [UIColor customBlue];
    progressView.hidden = NO;
}

- (void)setItem:(NSDictionary *)item {
    imageView.image = nil;
    imageView.animatedImage = nil;
    
    [self resetProgressBar];

    [imageProgressView setHidden:YES];
    [imageProgressView setProgress:0 animated:NO];
    
    SDWebImageDownloaderProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
        CGFloat progress = ((CGFloat)receivedSize / (CGFloat)expectedSize);
        
//        [imageProgressView setHidden:NO];
//        [imageProgressView setCircleColor:[UIColor customBlue]];
        [progressView setProgress:progress];
//        [imageProgressView setProgress:progress animated:YES];
    };

    
    [imageView sd_setImageWithURL:[NSURL URLWithString:item[@"thumbnail"]] placeholderImage:nil options:0 progress:progressBlock completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            [imageProgressView setCircleColor:[UIColor redColor]];
            [imageProgressView setProgress:1 animated:YES];
            [progressView setTintColor:[UIColor redColor]];
            [progressView setProgress:1];
        }
        else {
            [imageProgressView setCircleColor:[UIColor customBlue]];
            [imageProgressView setProgress:1 animated:YES];
            [progressView setHidden:YES];

//            [imageProgressView setHidden:YES];
        }
    }];
}

@end
