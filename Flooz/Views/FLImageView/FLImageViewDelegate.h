//
//  FLImageViewDelegate.h
//  Flooz
//
//  Created by Jonathan on 23/07/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLImageViewDelegate <NSObject>

- (void)didImageTouch:(UIView *)sender photoURL:(NSURL *)photoURL;

@end
