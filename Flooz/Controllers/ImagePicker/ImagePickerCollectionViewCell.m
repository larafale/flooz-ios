//
//  ImagePickerCollectionViewCell.m
//  Flooz
//
//  Created by Olive on 16/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ImagePickerCollectionViewCell.h"
#import "DotActivityIndicatorParms.h"
#import "DotActivityIndicatorView.h"

@interface ImagePickerCollectionViewCell () {
    FLAnimatedImageView *imageView;
    DotActivityIndicatorView *imageProgressView;
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
        
        imageProgressView = [[DotActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) / 4, CGRectGetHeight(frame) / 4, CGRectGetWidth(frame) / 2, CGRectGetHeight(frame) / 2)];
        [imageProgressView setBackgroundColor:[UIColor clearColor]];
        
        DotActivityIndicatorParms *dotParms = [DotActivityIndicatorParms new];
        dotParms.activityViewWidth = imageProgressView.frame.size.width;
        dotParms.activityViewHeight = imageProgressView.frame.size.height;
        dotParms.numberOfCircles = 3;
        dotParms.internalSpacing = 3;
        dotParms.animationDelay = 0.2;
        dotParms.animationDuration = 0.6;
        dotParms.animationFromValue = 0.3;
        dotParms.defaultColor = [UIColor customBlue];
        dotParms.isDataValidationEnabled = YES;
        
        [imageProgressView setDotParms:dotParms];
        
        [self.contentView addSubview:imageView];
        [imageView addSubview:imageProgressView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setItem:(NSDictionary *)item {
    imageView.image = nil;
    imageView.animatedImage = nil;
    
    [imageProgressView setHidden:NO];
    [imageProgressView startAnimating];
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:item[@"thumbnail"]] placeholderImage:nil options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [imageProgressView stopAnimating];
        [imageProgressView setHidden:YES];
    }];
}

@end
