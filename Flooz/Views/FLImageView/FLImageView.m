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
        
        imageProgressView = [[DotActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) / 2 - CGRectGetHeight(self.frame) / 4, CGRectGetHeight(self.frame) / 3, CGRectGetHeight(self.frame) / 2, CGRectGetHeight(self.frame) / 3)];
        [imageProgressView setBackgroundColor:[UIColor clearColor]];
        [imageProgressView setHidden:YES];
        
        DotActivityIndicatorParms *dotParms = [DotActivityIndicatorParms new];
        dotParms.activityViewWidth = imageProgressView.frame.size.width;
        dotParms.activityViewHeight = imageProgressView.frame.size.height;
        dotParms.numberOfCircles = 3;
        dotParms.internalSpacing = 5;
        dotParms.animationDelay = 0.2;
        dotParms.animationDuration = 0.6;
        dotParms.animationFromValue = 0.3;
        dotParms.defaultColor = [UIColor customBlue];
        dotParms.isDataValidationEnabled = YES;
        
        [imageProgressView setDotParms:dotParms];
        
        [self addSubview:imageProgressView];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    if (imageProgressView && image)
        [imageProgressView setHidden:YES];
    
    [super setImage:image];
}

- (void)setImageWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL {
    if ([url.absoluteString isEqualToString:@"/img/fake.png"]) {
        if (imageProgressView)
            [imageProgressView setHidden:NO];
        
        [self setImage:[UIImage imageNamed:@"fake"]];
    } else {
        [imageProgressView setHidden:NO];
        [imageProgressView stopAnimating];
        [imageProgressView startAnimating];
        
        self.image = nil;
        self.animatedImage = nil;
        
        [self sd_setImageWithURL:url placeholderImage:nil options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error) {
                [imageProgressView stopAnimating];
            }
            else {
                [imageProgressView stopAnimating];
                [imageProgressView setHidden:YES];
            }
        }];
    }
    fullScreenImageURL = fullScreenURL;
}

- (void)setFullScreenMode {
    if (!fullScreenImageURL || (imageProgressView && !imageProgressView.hidden)) {
        return;
    }
    
    [appDelegate showAvatarView:self withUrl:fullScreenImageURL];
}

@end
