//
//  JTContainerViewController.h
//  Flooz
//
//  Created by jonathan on 1/10/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTNavbarView.h"

@interface JTContainerViewController : UIViewController{
    JTNavbarView *navbarView;
    UIView *contentView;
    
    UIPercentDrivenInteractiveTransition *interactiveTransition;
}

- (id)initWithControllers:(NSArray *)controllers;

@property (strong, nonatomic) NSArray *viewControllers;

@end
