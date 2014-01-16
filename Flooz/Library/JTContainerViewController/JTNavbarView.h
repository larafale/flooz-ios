//
//  JTNavbarView.h
//  Flooz
//
//  Created by jonathan on 1/10/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTNavbarView : UIView{
    UIView *_titlesView;
    NSArray *_viewControllers;
    
    NSInteger selectedTitleIndex;
    
    UIGestureRecognizer *panGesture;
    CGPoint lastTranslation;
}

- (id)initWithViewControllers:(NSArray *)viewControllers;

@end
