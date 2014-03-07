//
//  PreviewNavBar.h
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PreviewNavBarDelegate.h"

@interface PreviewNavBar : UIView{
    UIButton *previousButton;
    UIButton *nextButton;
    UIButton *dismissButton;
}

@property (weak, nonatomic) IBOutlet id<PreviewNavBarDelegate> delegate;

- (void)setIsFirstPage:(BOOL)isFirstPage;
- (void)setIsLastPage:(BOOL)isLastPage;

@end
