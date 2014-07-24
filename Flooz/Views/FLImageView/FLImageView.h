//
//  FLImageView.h
//  Flooz
//
//  Created by jonathan on 3/3/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLImageViewDelegate.h"

@interface FLImageView : UIImageView{
    NSURL *fullScreenImageURL;
    UIProgressView *progressView;
}

@property (strong, nonatomic) UITapGestureRecognizer *imageGesture;
@property (weak, nonatomic) id<FLImageViewDelegate> delegate;

- (void)setImageWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL;

@end
