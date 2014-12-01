//
//  FLRevealContainerViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-09-23.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLRevealContainerViewController.h"

#import <IDMPhotoBrowser.h>
#import "AppDelegate.h"
#import "FriendsViewController.h"
#import "AccountViewController.h"

@interface FLRevealContainerViewController ()

@end

@implementation FLRevealContainerViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	self = [super initWithRootViewController:rootViewController];
	if (self) {
		if ([rootViewController isKindOfClass:[UINavigationController class]]) {
			UIViewController *centerController = [[rootViewController childViewControllers] firstObject];
			if ([centerController isKindOfClass:[TimelineViewController class]]) {
				_timelineController = (TimelineViewController *)centerController;
			}
		}

		[self resetOption:PPRevealSideOptionsiOS7StatusBarFading];
		[self setOption:PPRevealSideOptionsNoStatusBar];

		FriendsViewController *rightPanel = [FriendsViewController new];
		[self preloadViewController:rightPanel
		                    forSide:PPRevealSideDirectionRight
		                 withOffset:PADDING_NAV];
        _rightViewController = rightPanel;

		AccountViewController *leftPanel = [AccountViewController new];
		[self preloadViewController:leftPanel
		                    forSide:PPRevealSideDirectionLeft
		                 withOffset:PADDING_NAV];
        _leftViewController = leftPanel;
	}
	return self;
}

- (void)popLeftController {
	[self pushOldViewControllerOnDirection:PPRevealSideDirectionLeft withOffset:PADDING_NAV animated:YES];
}

- (void)popRightController {
	[self pushOldViewControllerOnDirection:PPRevealSideDirectionRight withOffset:PADDING_NAV animated:YES];
}

- (void)popCenterController {
	[self.view endEditing:YES];
	[self popViewControllerAnimated:YES];
}

- (void)displayTimelineForFilter:(TimelineFilter)filter withAnimation:(BOOL)animated {
	[self popViewControllerAnimated:animated];
	[_timelineController reloadTable:filter andFocus:YES];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    if (viewControllerToPresent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [super presentViewController:viewControllerToPresent animated:flag completion:completion];
        });
    }
}

#pragma mark - IDMPhotoBrowserDelegate

- (void)didImageTouch:(UIView *)sender photoURL:(NSURL *)photoURL {
	if (!photoURL) {
		return;
	}
    
    [appDelegate showAvatarView:sender withUrl:photoURL];
}

@end
