//
//  FirstLaunchContentViewController.h
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SMPageControl/SMPageControl.h>

#import "FLHomeTextField.h"

@protocol FirstLaunchContentViewControllerDelegate;

typedef enum {
    SignupPageTuto = 0,
    SignupPageExplication = 1,
    SignupPagePhone = 2,
    SignupPagePseudo = 3,
    SignupPageInfo = 4,
    SignupPagePassword = 5,
    SignupPageCode = 6,
    SignupPageCB = 7,
    SignupPageFriends = 8
} SignupOrderPage;

@interface FirstLaunchContentViewController : UIViewController

@property (nonatomic) NSInteger pageIndex;
@property (nonatomic, weak) id<FirstLaunchContentViewControllerDelegate> delegate;
@property (strong, nonatomic) FLHomeTextField *phoneField;
@property (strong, nonatomic) FLTextFieldIcon *textFieldToFocus;
@property (strong, nonatomic) FLTextFieldIcon *secondTextFieldToFocus;
@end

@protocol FirstLaunchContentViewControllerDelegate <NSObject>
@optional
- (void)firstLaunchContentViewControllerDidDAppear:(FirstLaunchContentViewController *)controller;
- (void)goToNextPage:(NSInteger)currentIndex;
- (void)goToPreviousPage:(NSInteger)currentIndex;
@end
