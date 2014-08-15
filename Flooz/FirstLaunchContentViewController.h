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
    SignupPageFriends
} SignupOrderPage;

typedef enum {
    SecureCodeModeNew, // Nouveau code
    SecureCodeModeConfirm // Nouveau code confirmation
} SecureCodeMode2;

@interface FirstLaunchContentViewController : UIViewController <SecureCodeFieldDelegate> {
    FLUserView *_avatarView;
}

@property (nonatomic) NSInteger pageIndex;
@property (nonatomic, weak) id<FirstLaunchContentViewControllerDelegate> delegate;
@property (strong, nonatomic) FLHomeTextField *phoneField;
@property (strong, nonatomic) FLTextFieldIcon *textFieldToFocus;
@property (strong, nonatomic) FLTextFieldIcon *secondTextFieldToFocus;
@property (strong, nonatomic) SecureCodeField *secureCodeField;
@property (strong, nonatomic) FLTextFieldIcon *userName;
@property (strong, nonatomic) UIButton *registerFacebook;
@property (strong, nonatomic) FLTextFieldIcon *name;
@property (strong, nonatomic) FLTextFieldIcon *email;
@property (strong, nonatomic) FLTextFieldIcon *password;
@property (strong, nonatomic) FLTextFieldIcon *passwordConfirm;

@property (nonatomic, strong) NSMutableDictionary *userInfoDico;

- (void)setUserInfoDico:(NSMutableDictionary *)userInfoDico;
- (void)displayChanges;

@end

@protocol FirstLaunchContentViewControllerDelegate <NSObject>
@optional
- (void)firstLaunchContentViewControllerDidDAppear:(FirstLaunchContentViewController *)controller;
- (void)goToNextPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico;
- (void)goToPreviousPage:(NSInteger)currentIndex withUser:(NSMutableDictionary *)userDico;
@end
