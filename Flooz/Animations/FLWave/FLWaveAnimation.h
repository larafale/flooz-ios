//
//  FLWaveAnimation.h
//  Flooz
//
//  Created by jonathan on 2014-04-28.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLWaveAnimation : NSObject {
}

@property (weak, nonatomic) UIView *view;

@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) UIColor *foregroundColor;

@property CGFloat gradientWidth;
@property CGFloat repeatCount;
@property NSTimeInterval duration;

- (void)start;
- (void)stop;

@end
