//
//  FLImageViewDelegate.h
//  Flooz
//
//  Created by olivier on 23/07/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLImageViewDelegate <NSObject>

- (void)didImageTouch:(UIView *)sender photoURL:(NSURL *)photoURL;

@end
