//
//  PreviewNavBarDelegate.h
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PreviewNavBarDelegate <NSObject>

- (void)loadPreviousSlide;
- (void)loadNextSlide;
- (void)dismiss;

@end
