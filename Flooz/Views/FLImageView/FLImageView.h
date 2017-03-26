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
#import "DotActivityIndicatorView.h"
#import "DotActivityIndicatorParms.h"
#import "FLTransaction.h"
#import "ABMediaView.h"

@interface FLImageView : FLAnimatedImageView<ABMediaViewDelegate> {
	NSURL *fullScreenImageURL;

    DotActivityIndicatorView *imageProgressView;
}

@property (strong, nonatomic) UITapGestureRecognizer *imageGesture;

- (void)setMediaWithURL:(NSURL *)url fullScreenURL:(NSURL *)fullScreenURL mediaType:(TransactionAttachmentType)type;

@end
