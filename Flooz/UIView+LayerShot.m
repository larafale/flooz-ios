//
//  UIView+LayerShot.m
//  Flooz
//
//  Created by Epitech on 9/25/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "UIView+LayerShot.h"

@implementation UIView (LayerShot)

- (UIImage *)imageFromLayer
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
