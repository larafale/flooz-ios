//
//  SocialViewController.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLFilterView.h"

@interface SocialViewController : UIViewController{
    NSArray *controllers;
    UIViewController *currentController;
}

@property (weak, nonatomic) IBOutlet FLFilterView *filterView;

@end
