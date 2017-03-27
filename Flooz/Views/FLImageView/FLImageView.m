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
#import "ABMediaView.h"

@implementation FLImageView {
    ABMediaView *mediaView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor customBackgroundHeader];
        _imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setFullScreenMode)];
        
        self.userInteractionEnabled = YES;
        
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

- (void)setMediaWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL mediaType:(TransactionAttachmentType)type {
    
    if (mediaView) {
        [mediaView removeFromSuperview];
        mediaView = nil;
    }

    if (type == TransactionAttachmentImage) {
        [self addGestureRecognizer:_imageGesture];

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
    } else {
        [self removeGestureRecognizer:_imageGesture];
        
        mediaView = [[ABMediaView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self initializeSettingsForMediaView];
        
        if (type == TransactionAttachmentVideo) {
            [mediaView setVideoURL:fullScreenURL.absoluteString withThumbnailURL:url.absoluteString];
        } else if (type == TransactionAttachmentAudio) {
            [mediaView setAudioURL:fullScreenURL.absoluteString withThumbnailURL:url.absoluteString];
        }

        [self addSubview:mediaView];
    }
}

- (void)setFullScreenMode {
    if (!fullScreenImageURL || (imageProgressView && !imageProgressView.hidden)) {
        return;
    }
    
    [appDelegate showAvatarView:self withUrl:fullScreenImageURL];
}

- (void) initializeSettingsForMediaView {
    mediaView.delegate = self;
    
    mediaView.backgroundColor = [UIColor blackColor];
    
    // Changing the theme color changes the color of the play indicator as well as the progress track
    [mediaView setThemeColor:[UIColor redColor]];
    
    // Enable progress track to show at the bottom of the view
    [mediaView setShowTrack:YES];
    
    // Allow video to loop once reaching the end
    [mediaView setAllowLooping:YES];
    
    // Allows toggling for funtionality which would show remaining time instead of total time on the right label on the track
    [mediaView setShowRemainingTime:YES];
    
    // Allows toggling for functionality which would allow the mediaView to be swiped away to the bottom right corner, and allows the user to interact with the underlying interface while the mediaView sits there. Video continues to play if already playing, and the user can swipe right to dismiss the minimized view.
    [mediaView setIsMinimizable: YES];
    
    /// Change the font for the labels on the track
    [mediaView setTrackFont:[UIFont customContentBold:13]];
    
    [mediaView setThemeColor:[UIColor customBlue]];
    
    mediaView.autoPlayAfterPresentation = YES;
    [mediaView setShouldDisplayFullscreen: YES];
    mediaView.presentFromOriginRect = YES;

    // Setting the contentMode to aspectFit will set the videoGravity to aspect as well
    mediaView.contentMode = UIViewContentModeScaleAspectFit;
    
    // If you desire to have the image to fill the view, however you would like the videoGravity to be aspect fit, then you can implement this functionality
    //    self.mediaView.contentMode = UIViewContentModeScaleAspectFill;
    //    [self.mediaView changeVideoToAspectFit: YES];
    
    // If the imageview is not in a reusable cell, and you wish that the image not disappear for a split second when reloaded, then you can enable this functionality
    mediaView.imageViewNotReused = YES;
    
    // Adds a offset to the views at the top of the ABMediaView, which helps to make sure that the views do not block other views (ie. UIStatusBar)
    [mediaView setTopBuffer:ABBufferStatusBar];
}

#pragma mark - ABMediaView Delegate

- (void) mediaView:(ABMediaView *)mediaView didChangeOffset:(float)offsetPercentage {
    //    NSLog(@"MediaView offset changed: %f", offsetPercentage);
}

- (void) mediaViewDidPlayVideo: (ABMediaView *) mediaView {
    //    NSLog(@"MediaView did play video");
}

- (void) mediaViewDidFailToPlayVideo:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView did fail to play video");
}

- (void) mediaViewDidPauseVideo:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView did pause video");
}

- (void) mediaViewWillPresent:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView will present");
}

- (void) mediaViewDidPresent:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView will present");
    
    // Enable rotation when the ABMediaView is presented. For this application, we want the ABMediaView to rotate when in fullscreen, in order to watch landscape videos. However, our app's interface in portrait, so when the ABMediaView is shown, that is when rotation should be enabled
    [self restrictRotation:NO];
}

- (void) mediaViewWillDismiss:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView will dismiss");
    
    // Disable rotation when the ABMediaView is being dismissed. For this application, we want the ABMediaView to rotate when in fullscreen, in order to watch landscape videos. However, our app's interface in portrait, so when leaving the ABMediaView, we want rotation to be restricted
    [self restrictRotation:YES];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void) mediaViewDidDismiss:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView did dismiss");
}

- (void) mediaViewWillChangeMinimization:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView will minimize to a certain value");
}

- (void) mediaViewDidChangeMinimization:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView did minimize to a certain value");
}

- (void) mediaViewWillEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized {
    //    NSLog(@"MediaView will snap to minimized mode? %i", isMinimized);
    
    [self restrictRotation:isMinimized];
}

- (void) mediaViewDidEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized {
    //    NSLog(@"MediaView snapped to minimized mode? %i", isMinimized);
}

- (void) mediaView:(ABMediaView *)mediaView didSetImage:(UIImage *)image {
    //    NSLog(@"Did set Image: %@", image);
}

- (void) mediaViewWillChangeDismissing:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView will change dismissing");
}

- (void) mediaViewDidChangeDismissing:(ABMediaView *)mediaView {
    //    NSLog(@"MediaView did change dismissing");
}

- (void) mediaViewWillEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss {
    //    NSLog(@"MediaView will end dismissing");
    
    [self restrictRotation:didDismiss];
}

- (void) mediaViewDidEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss {
    //    NSLog(@"MediaView did end dismissing");
}

- (void) mediaView:(ABMediaView *)mediaView didDownloadImage:(UIImage *)image {
    //    NSLog(@"Did download Image: %@", image);
}

- (void) mediaView:(ABMediaView *)mediaView didDownloadVideo:(NSString *)video {
    //    NSLog(@"Did download Video path: %@", video);
}

- (void) mediaView:(ABMediaView *)mediaView didDownloadGif:(UIImage *)gif {
    //    NSLog(@"Did download Gif: %@", gif);
}

- (void) handleTitleSelectionInMediaView:(ABMediaView *)mediaView {
    //    NSLog(@"Title label was selected");
}

- (void) handleDetailsSelectionInMediaView:(ABMediaView *)mediaView {
    //    NSLog(@"Details label was selected");
}

-(void) restrictRotation:(BOOL) restriction
{
    // An approach at determining whether the view should allow for rotation, when the ABMediaView is fullscreen, we want rotation to be enabled. However, if ABMediaView is not fullscreen, I don't want rotation to be allowed
    
    appDelegate.restrictRotation = restriction;
}

@end
