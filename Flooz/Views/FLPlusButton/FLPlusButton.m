//
//  FLPlusButton.m
//  Flooz
//
//  Created by Olive on 3/30/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLPlusButton.h"

@implementation FLPlusButton {
    CAShapeLayer *plusLayer;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = false;
        plusLayer = [CAShapeLayer new];
        [self.layer addSublayer:plusLayer];
        self.layer.cornerRadius = self.frame.size.width * 0.5;
        self.layer.masksToBounds = true;
        
        if ([[Flooz sharedInstance] isProd])
            self.layer.backgroundColor = [UIColor customBlue].CGColor;
        else if ([[Flooz sharedInstance] isDev])
            self.layer.backgroundColor = [UIColor customGreen].CGColor;
        else if ([[Flooz sharedInstance] isLocal])
            self.layer.backgroundColor = [UIColor customRed].CGColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self drawPlus];
}

- (void)drawPlus {
    plusLayer.frame = CGRectMakeWithSize(self.frame.size);
    plusLayer.lineCap = kCALineCapRound;
    plusLayer.strokeColor = [UIColor whiteColor].CGColor;
    plusLayer.lineWidth = 3.0;
    
    plusLayer.path = [self pathPlus].CGPath;
}

- (UIBezierPath *)pathPlus {
    CGFloat radius = self.frame.size.width * 0.5 * (20.0 / 56.0);
    CGPoint middle = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(middle.x - radius, middle.y)];
    [path addLineToPoint:CGPointMake(middle.x + radius, middle.y)];
    [path moveToPoint:CGPointMake(middle.x, middle.y - radius)];
    [path addLineToPoint:CGPointMake(middle.x, middle.y + radius)];
    
    return path;
}

@end
