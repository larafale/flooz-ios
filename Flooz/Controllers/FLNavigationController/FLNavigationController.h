//
//  FLNavigationController.h
//  Flooz
//
//  Created by Arnaud on 2014-10-14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLNavigationController : UINavigationController <UINavigationControllerDelegate>

@property (nonatomic) BOOL blockBack;

- (void)setAmount:(NSNumber *)amount;

@end