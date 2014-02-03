//
//  FLUserView.h
//  Flooz
//
//  Created by jonathan on 1/23/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLUserView : UIView{
    UIImage *placeholder;
    UIImageView *filter;
    UIImageView *avatar;
}

- (void)setAlternativeStyle;
- (void)setImageFromURL:(NSString *)url;

@end
