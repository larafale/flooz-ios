//
//  FLImageView.h
//  Flooz
//
//  Created by jonathan on 3/3/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLImageView : UIImageView {
	NSURL *fullScreenImageURL;
	UIProgressView *progressView;
}

@property (strong, nonatomic) UITapGestureRecognizer *imageGesture;

- (void)setImageWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL;

@end
