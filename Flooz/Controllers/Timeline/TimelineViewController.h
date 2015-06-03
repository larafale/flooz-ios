//
//  TimelineViewController.h
//  Flooz
//
//  Created by olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLFilterView.h"
#import "TransactionCellDelegate.h"
#import "FLScrollViewIndicator.h"
#import "FLTimelineTableViewController.h"
#import "TimelineDelegate.h"
#import "WYPopoverController.h"

@interface TestScrollView : UIScrollView <UIGestureRecognizerDelegate>
@end

@interface TimelineViewController : GlobalViewController <UIScrollViewDelegate, TimelineDelegate, WYPopoverControllerDelegate> {
	FLTimelineTableViewController *timelineFriend;
	FLTimelineTableViewController *timelinePublic;
	FLTimelineTableViewController *timelinePrivate;
}

@end
