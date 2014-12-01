//
//  FLViewDelegate.h
//  Flooz
//
//  Created by Arnaud on 2014-10-17.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLViewDelegate <NSObject>
- (void)didChangeHeight:(CGFloat)height;
@end