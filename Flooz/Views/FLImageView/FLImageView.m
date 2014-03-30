//
//  FLImageView.m
//  Flooz
//
//  Created by jonathan on 3/3/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLImageView.h"

#import "AppDelegate.h"
#import <IDMPhotoBrowser.h>

@implementation FLImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setFullScreenMode)];
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:_imageGesture];
        
        self.layer.cornerRadius = 3.;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)setImageWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL
{
    [super setImageWithURL:url];
    fullScreenImageURL = fullScreenURL;
}

- (void)setFullScreenMode
{
    if(!fullScreenImageURL){
        return;
    }
    
    IDMPhotoBrowser *controller = [[IDMPhotoBrowser alloc] initWithPhotoURLs:@[fullScreenImageURL]];
    
    UIViewController *rootController = appDelegate.window.rootViewController;
    
    if([rootController presentedViewController]){
        [[rootController presentedViewController] presentViewController:controller animated:YES completion:NULL];
    }
    else{
        [rootController presentViewController:controller animated:YES completion:NULL];
    }
}

@end
