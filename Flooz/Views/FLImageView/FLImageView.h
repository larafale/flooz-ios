//
//  FLImageView.h
//  Flooz
//
//  Created by Olivier on 3/3/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImageView.h"
#import "FLAnimatedImageView+WebCache.h"

@interface FLImageView : FLAnimatedImageView {
	NSURL *fullScreenImageURL;
	UIProgressView *progressView;
}

@property (strong, nonatomic) UITapGestureRecognizer *imageGesture;

- (void)setImageWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL;

@end
