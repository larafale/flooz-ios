//
//  UIViewController+RegisterNotification.h
//  Flooz
//
//  Created by Jonathan on 31/07/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (RegisterNotification)

- (void)registerNotification:(SEL)action name:(NSString *)name object:(id)object;

@end
