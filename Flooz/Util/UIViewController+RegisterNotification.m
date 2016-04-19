//
//  UIViewController+RegisterNotification.m
//  Flooz
//
//  Created by Olivier on 31/07/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "UIViewController+RegisterNotification.h"

@implementation UIViewController (RegisterNotification)

- (void)registerNotification:(SEL)action name:(NSString *)name object:(id)object {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:action name:name object:object];
}

@end
