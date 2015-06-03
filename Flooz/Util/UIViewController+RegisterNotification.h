//
//  UIViewController+RegisterNotification.h
//  Flooz
//
//  Created by olivier on 31/07/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (RegisterNotification)

- (void)registerNotification:(SEL)action name:(NSString *)name object:(id)object;

@end
