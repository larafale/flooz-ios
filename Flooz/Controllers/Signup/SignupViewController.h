//
//  SignupViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-09-09.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SMPageControl/SMPageControl.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "FLHomeTextField.h"
#import "FLTextFieldTitle2.h"
#import "FLTextFieldSignup.h"
#import "CodePinView.h"

#import "ContactCell.h"
#import "FriendCell.h"
#import "FriendPickerContactCell.h"

@protocol SignupViewControllerDelegate;

typedef enum {
	SignupPageTuto = 0,
	SignupPageExplication,
	SignupPagePhone,
	SignupPagePseudo,
	SignupPagePhoto,
	SignupPageInfo,
	SignupPageCode,
	SignupPageCodeVerif,
	SignupPageCB,
	SignupPageAskAccess,
	SignupPageFriends
} SignupOrderPage;

@interface SignupViewController : GlobalViewController <CodePinDelegate, UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate, TTTAttributedLabelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic) NSInteger pageIndex;
@property (nonatomic) NSInteger pageIndexStart;
@property (nonatomic, weak) id <SignupViewControllerDelegate> delegate;
@property (strong, nonatomic) FLHomeTextField *phoneField;
@property (strong, nonatomic) FLTextFieldSignup *firstTextFieldToFocus;
@property (strong, nonatomic) FLTextFieldSignup *secondTextFieldToFocus;

@property (strong, nonatomic) UIScrollView *contentView;

- (void)setUserInfoDico:(NSMutableDictionary *)userInfoDico;
- (void)displayChanges;
- (void)resetUserInfoDico;

@end

@protocol SignupViewControllerDelegate <NSObject>
@optional
- (void)goToNextPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico;
- (void)goToPreviousPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico;
@end
