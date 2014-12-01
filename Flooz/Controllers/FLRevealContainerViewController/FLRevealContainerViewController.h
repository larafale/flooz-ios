//
//  FLRevealContainerViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-09-23.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "PPRevealSideViewController.h"
#import "TimelineViewController.h"

@interface FLRevealContainerViewController : PPRevealSideViewController

@property (nonatomic) TimelineViewController *timelineController;
@property (nonatomic, weak) UIViewController *leftViewController;
@property (nonatomic, weak) UIViewController *rightViewController;

- (void)displayTimelineForFilter:(TimelineFilter)filter withAnimation:(BOOL)animated;

- (void)popLeftController;
- (void)popCenterController;
- (void)popRightController;

@end
