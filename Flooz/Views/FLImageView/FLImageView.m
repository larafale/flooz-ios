//
//  FLImageView.m
//  Flooz
//
//  Created by Olivier on 3/3/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLImageView.h"

#import "AppDelegate.h"
#import "IDMPhotoBrowser.h"

@implementation FLImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor customBackgroundHeader];
        _imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setFullScreenMode)];
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:_imageGesture];
        
        self.layer.cornerRadius = 3.;
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        progressView = [[UIProgressView alloc] initWithFrame:CGRectMakeWithSize(self.frame.size)];
        progressView.hidden = YES;
        [self addSubview:progressView];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    [progressView setHidden:YES];
    [super setImage:image];
}

- (void)setImageWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL {
    //    [super sd_setImageWithURL:url];
    
    if ([url.absoluteString isEqualToString:@"/img/fake.png"]) {
        [progressView setHidden:YES];
        [self setImage:[UIImage imageNamed:@"fake"]];
    } else {
        [self resetProgressBar];
        
        SDWebImageDownloaderProgressBlock progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
            CGFloat progress = ((CGFloat)receivedSize / (CGFloat)expectedSize);
            [progressView setProgress:progress];
        };
        
        [self sd_setImageWithURL:url
                placeholderImage:nil
                         options:SDWebImageRetryFailed
                        progress:progressBlock
                       completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                           if (error) {
                               [progressView setTintColor:[UIColor redColor]];
                               [progressView setProgress:1];
                           }
                           else {
                               [progressView setHidden:YES];
                           }
                       }];
    }
    fullScreenImageURL = fullScreenURL;
}

- (void)resetProgressBar {
    [progressView setProgress:0];
    progressView.trackTintColor = self.backgroundColor;
    progressView.tintColor = [UIColor customBlue];
    CGRectSetY(progressView.frame, CGRectGetHeight(self.frame) - 1);
    progressView.hidden = NO;
}

- (void)setFullScreenMode {
    if (!fullScreenImageURL || !progressView.hidden) {
        return;
    }
    
    [appDelegate showAvatarView:self withUrl:fullScreenImageURL];
}

@end
