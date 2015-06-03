//
//  FLScannerOverlay.m
//  Flooz
//
//  Created by Olivier on 4/22/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import "FLScannerOverlay.h"

@implementation FLScannerOverlay

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIBezierPath *overlayPath = [UIBezierPath bezierPathWithRect:self.bounds];
        
        float focusViewSize;
        
        if (frame.size.width < frame.size.height)
            focusViewSize = frame.size.width - 2 * 50;
        else
            focusViewSize = frame.size.height - 2 * 50;
        
        CGRect holeRect = CGRectMake(50, frame.size.height / 2 - focusViewSize / 2, focusViewSize, focusViewSize);
        
        UIBezierPath *transparentPath = [UIBezierPath bezierPathWithRect:holeRect];
        [overlayPath appendPath:transparentPath];
        [overlayPath setUsesEvenOddFillRule:YES];
        
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = overlayPath.CGPath;
        fillLayer.fillRule = kCAFillRuleEvenOdd;
        fillLayer.fillColor = [UIColor customBackgroundHeader:0.7].CGColor;
        
        [self.layer addSublayer:fillLayer];
    }
    return self;
}



@end
