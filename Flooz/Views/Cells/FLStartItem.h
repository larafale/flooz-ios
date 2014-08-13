//
//  FLStartItem.h
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLStartItem : UIView

+ (FLStartItem*) newWithTitle:(NSString*)title imageImageName:(NSString*)imageName contentText:(NSString*)contentText andSize:(CGFloat)size;

@end
