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
#import "SecureCodeField.h"
#import "FLTextFieldTitle2.h"

#import <AddressBookUI/AddressBookUI.h>

#import "ContactCell.h"
#import "FriendPickerContactCell.h"

#import <MessageUI/MFMessageComposeViewController.h>

@protocol FirstLaunchContentViewControllerDelegate;

typedef enum {
    SignupPageTuto = 0,
    SignupPageExplication,
    SignupPagePhone,
    SignupPagePseudo,
    SignupPageInfo,
    SignupPagePassword,
    SignupPageCode,
    SignupPageCodeVerif,
    SignupPageCB,
    SignupPageAccessToFriends,
    SignupPageFriends
} SignupOrderPage;

@interface FirstLaunchContentViewController : UIViewController <SecureCodeFieldDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate>

@property (nonatomic) NSInteger pageIndex;
@property (nonatomic, weak) id<FirstLaunchContentViewControllerDelegate> delegate;
@property (strong, nonatomic) FLHomeTextField *phoneField;
@property (strong, nonatomic) FLTextFieldIcon *firstTextFieldToFocus;
@property (strong, nonatomic) FLTextFieldIcon *secondTextFieldToFocus;

@property (strong, nonatomic) UIScrollView *contentView;

- (void)setUserInfoDico:(NSMutableDictionary *)userInfoDico;
- (void)displayChanges;
- (void)resetUserInfoDico;

@end

@protocol FirstLaunchContentViewControllerDelegate <NSObject>
@optional
- (void)firstLaunchContentViewControllerDidDAppear:(FirstLaunchContentViewController *)controller;
- (void)goToNextPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico;
- (void)goToPreviousPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico;
@end
