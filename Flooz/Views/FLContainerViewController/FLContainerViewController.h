//
//  FLContainerViewController.h
//  Flooz
//
//  Created by jonathan on 1/10/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLNavbarView.h"

@interface FLContainerViewController : UIViewController{
    UIView *contentView;
}

- (id)initWithControllers:(NSArray *)controllers;

@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, readonly) FLNavbarView *navbarView;

@end
