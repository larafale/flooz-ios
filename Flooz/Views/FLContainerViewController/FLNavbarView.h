//
//  FLNavbarView.h
//  Flooz
//
//  Created by jonathan on 1/10/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLNavbarView : UIView<UIGestureRecognizerDelegate>{
    UIView *_titlesView;
    NSArray *_viewControllers;
    
    NSInteger selectedTitleIndex;
    
    UIGestureRecognizer *panGesture;
    CGPoint lastTranslation;
    
    UITapGestureRecognizer *floozGesture1;
    UITapGestureRecognizer *floozGesture2;
    UILabel *floozContianerView;
    UILabel *floozCountView;
    UILabel *floozTextView;
}

- (id)initWithViewControllers:(NSArray *)viewControllers;
- (void)loadControllerWithIndex:(NSInteger)index;

@end
