//
//  FLUserView.h
//  Flooz
//
//  Created by jonathan on 1/23/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLUser.h"

@interface FLUserView : UIView{
    UIImage *placeholder;
    UIImageView *avatar;
}

- (void)setImageFromURL:(NSString *)url;
- (void)setImageFromURLAnimate:(NSString *)url;
- (void)setImageFromUser:(FLUser *)user;
- (void)setImageFromData:(NSData *)data;

- (void)hidePlaceholder;

@end
