//
//  FirstLaunchContentViewController.m
//  Flooz
//
//  Created by Jérémy Lagrue on 2014-08-11.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FirstLaunchContentViewController.h"
#import "FLStartButton.h"
#import "FLStartItem.h"

#import "AppDelegate.h"
#import "FLKeyboardView.h"
#import "FLHomeTextField.h"

#import <UICKeyChainStore.h>
#import "ScanPayViewController.h"

@interface FirstLaunchContentViewController ()
{
    CGFloat sizePicto;
    CGFloat ratioiPhones;
    CGFloat firstItemY;
    
    NSMutableDictionary *_userDic;
    
    UIView *_headerView;
    UILabel *_title;
    UIView *_bar;
    UIButton *_backButton;
    UIView *_mainBody;
    UIButton *_validCBButton;
    UIImageView *logo;
    FLUserView *_avatarView;
    
    UIButton *_registerFacebook;
    FLTextFieldIcon *_userName;
    FLTextFieldIcon *_name;
    FLTextFieldIcon *_email;
    FLTextFieldIcon *_password;
    FLTextFieldIcon *_passwordConfirm;
    SecureCodeField *_secureCodeField;
    
    SecureCodeMode2 currentSecureMode;
    
    NSMutableArray *fieldsView;
    FLKeyboardView *inputView;
    UIView *_viewButtonScan;
    
    NSMutableArray *_contactInfoArray;
    NSMutableArray *_contactToInvite;
    NSMutableArray *_contactFromFlooz;
    
    UITableView *_contactsTableView;
    UIView *_footerView;
    
    BOOL _haveAnimated;
    
    UIView *_mainContent;
}

@end

@implementation FirstLaunchContentViewController

- (void)loadView {
    [super loadView];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    CGRect frame    = [[UIScreen mainScreen] bounds];
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor customBackgroundHeader];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sizePicto = 110.0f;
    ratioiPhones = 1.0f;
    if (PPScreenHeight() < 568) {
        ratioiPhones = 1.2f;
        sizePicto = sizePicto / ratioiPhones;
    }
    
    _userDic = [NSMutableDictionary new];
    fieldsView = [NSMutableArray new];
    
    [self prepareHeader];
    [self setContent];
}

- (void)setUserInfoDico:(NSMutableDictionary *)userInfoDico {
    [self resetUserInfoDico];
    [_validCBButton setEnabled:NO];
    _haveAnimated = NO;
    [_userDic addEntriesFromDictionary:userInfoDico];
}

- (void)resetUserInfoDico {
    for (NSString *key in _userDic.allKeys) {
        [_userDic setValue:@"" forKey:key];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayChanges];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self focus];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - PREPARATION VIEWS

- (void)displayChanges {
    switch (_pageIndex) {
        case SignupPageInfo: {
            if(_userDic[@"avatarURL"]){
                [_avatarView setImageFromURL:_userDic[@"avatarURL"]];
                [_avatarView setHidden:NO];
                [_registerFacebook setHidden:YES];
                [self animateValidButton];
            }
            else {
                [_avatarView setHidden:YES];
                [_registerFacebook setHidden:NO];
            }
            [_name reloadTextField];
            [_email reloadTextField];
            [self canValidate:_email];
        }
            break;
        case SignupPagePseudo: {
            [_userName reloadTextField];
            [self canValidate:_userName];
        }
            break;
        case SignupPageCode: {
            [_secureCodeField clean];
        }
            break;
        case SignupPagePassword: {
            [_userDic setValue:@"" forKey:@"password"];
            [_userDic setValue:@"" forKey:@"confirmation"];
            [_password reloadTextField];
            [_passwordConfirm reloadTextField];
            [_validCBButton setEnabled:NO];
            _haveAnimated = NO;
        }
            break;
        case SignupPageCB: {
            if (_userDic[@"firstName"] && _userDic[@"lastName"]) {
                NSString *holder = [NSString stringWithFormat:@"%@ %@",_userDic[@"firstName"],_userDic[@"lastName"]];
                [_userDic setObject:holder forKey:@"holder"];
                [fieldsView[0] reloadData];
            }
        }
            break;
        default:
            break;
    }
}

- (void)setContent
{
    switch (_pageIndex) {
        case SignupPageTuto: {
            [self signupPageTuto];
        }
            break;
        case SignupPageExplication: {
            [self signupPageExplication];
        }
            break;
        case SignupPagePhone: {
            [self signupPhoneView];
        }
            break;
        case SignupPagePseudo: {
            [self signupPseudoView];
        }
            break;
        case SignupPageInfo: {
            [self signupInfoView];
        }
            break;
        case SignupPagePassword: {
            [self signupPasswordView];
        }
            break;
        case SignupPageCode: {
            [self signupCodeView];
        }
            break;
        case SignupPageCodeVerif: {
            [self signupCodeVerifView];
        }
            break;
        case SignupPageCB: {
            [self signupCBView];
        }
            break;
        case SignupPageFriends: {
            [self signupFriendView];
        }
            break;
        default: {
            _title.text = [NSString stringWithFormat:@"%d", (int)_pageIndex];
        }
            break;
    }
}

- (void)prepareHeader {
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT + 16, PPScreenWidth(), 80.0f)];
    if (PPScreenHeight() < 500.0f) {
        CGRectSetHeight(_headerView.frame, 60.0f);
    }
    [self.view addSubview:_headerView];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_headerView.frame), 50 / ratioiPhones)];
    _title.font = [UIFont customTitleExtraLight:28];
    _title.textColor = [UIColor customBlue];
    _title.numberOfLines = 0;
    _title.textAlignment = NSTextAlignmentCenter;
    
    _bar = [[UIView alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(_title.frame) + 15.0f / ratioiPhones, 50.0f, 1.0f)];
    [_bar setBackgroundColor:[UIColor customBlue]];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMinY(_title.frame) + 12.0f, 30, 30)];
    [_backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(goToPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    if (PPScreenHeight() < 500.0f) {
        CGRectSetY(_backButton.frame, CGRectGetMinY(_title.frame) + 7.0f);
    }
    [_headerView addSubview:_title];
    //[_headerView addSubview:_bar];
    [_headerView addSubview:_backButton];
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), PPScreenWidth(), PPScreenHeight()-CGRectGetMaxY(_headerView.frame))];
    [self.view addSubview:_mainBody];
    
    [self createValidButton];
}

- (void) displayHeader {
    [self.view setBackgroundColor: [UIColor customBackground]];
    
    [_bar setHidden:YES];
    CGRectSetY(_headerView.frame, STATUSBAR_HEIGHT + 40);
    if (PPScreenHeight() < 500.0f) {
        CGRectSetY(_title.frame, -2.0f);
        CGRectSetY(_backButton.frame, CGRectGetMinY(_title.frame) + 7.0f);
    }
    CGRectSetHeight(_headerView.frame, CGRectGetMaxY(_title.frame) + 5.0f);
    
    CGRectSetY(_mainBody.frame, CGRectGetMaxY(_headerView.frame));
    CGRectSetHeight(_mainBody.frame, PPScreenHeight()-CGRectGetMaxY(_headerView.frame));
    
    firstItemY = 25.0f / ratioiPhones;
}

- (UIButton *)ignoreButtonWithText:(NSString *)text superV:(UIView *)superV {
    UIButton *ignoreButton  = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(superV.frame) - 40 - 5, CGRectGetWidth(superV.frame), 40)];
    [ignoreButton setTitle:text forState:UIControlStateNormal];
    [ignoreButton setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
    [ignoreButton setTitleColor:[UIColor customBlueLight] forState:UIControlStateHighlighted];
    [ignoreButton.titleLabel setFont: [UIFont customTitleExtraLight:18]];
    [ignoreButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
    [superV addSubview:ignoreButton];
    return ignoreButton;
}

#pragma mark - FOCUS

- (void) focus {
    switch (_pageIndex) {
        case SignupPagePhone: {
            dispatch_async(dispatch_get_main_queue(), ^{
                FirstLaunchContentViewController *strongSelf = self;
                [strongSelf.phoneField becomeFirstResponder];
            });
        }
            break;
        case SignupPageInfo: {
            if(_userDic[@"avatarURL"]){
                [self focusOnSecond];
            }
            else {
                [self focusOnFirst];
            }
        }
            break;
        default: {
            [self focusOnFirst];
        }
            break;
    }
}

- (void)focusOnFirst {
    dispatch_async(dispatch_get_main_queue(), ^{
        FirstLaunchContentViewController *strongSelf = self;
        [strongSelf.firstTextFieldToFocus becomeFirstResponder];
    });
}

- (void)focusOnSecond {
    dispatch_async(dispatch_get_main_queue(), ^{
        FirstLaunchContentViewController *strongSelf = self;
        [strongSelf.secondTextFieldToFocus becomeFirstResponder];
    });
}

- (void)focusOnNext {
    [_secondTextFieldToFocus becomeFirstResponder];
}

#pragma mark - HELPERS METHODS

- (CGSize)sizeExpectedForView:(UIView *)view {
    CGSize expectedSize;
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)view;
        expectedSize = [label.text sizeWithAttributes:@{NSFontAttributeName: label.font}];
    }
    else if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        expectedSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    }
    return expectedSize;
}

#pragma mark - CALLS to Delegate Methods
- (void) goToNextPage {
    if ([self.delegate respondsToSelector:@selector(goToNextPage:withUser:)]) {
        [self.delegate goToNextPage:_pageIndex withUser:_userDic];
    }
}
- (void) goToPreviousPage {
    if ([self.delegate respondsToSelector:@selector(goToPreviousPage:withUser:)]) {
        [self.delegate goToPreviousPage:_pageIndex withUser:_userDic];
    }
}


#pragma mark - VALIDATION SECTION

- (void) canValidate:(FLTextFieldIcon *)textIcon {
    BOOL canValidate = NO;
    if ([textIcon isEqual:_userName]) {
        if (_userDic[@"nick"] && ((NSString *)_userDic[@"nick"]).length >= 3)
        {
            canValidate = YES;
        }
    } else if ([textIcon isEqual:_name] || [textIcon isEqual:_email]) {
        if ((_userDic[@"firstName"] && ![_userDic[@"firstName"] isBlank])
            && (_userDic[@"lastName"] && ![_userDic[@"lastName"] isBlank])
            && (_userDic[@"email"] && ![_userDic[@"email"] isBlank] && [self validateEmail:_userDic[@"email"]]))
        {
            canValidate = YES;
        }
    } else if ([textIcon isEqual:_password] || [textIcon isEqual:_passwordConfirm]) {
        if ((_userDic[@"password"] && [_userDic[@"password"] length] >= 6)
            && (_userDic[@"confirmation"] && [_userDic[@"confirmation"] length] >= 6)
            && ([_userDic[@"password"] isEqualToString:_userDic[@"confirmation"]]))
        {
            canValidate = YES;
        }
    }
    
    if (canValidate) {
        [self animateValidButton];
    } else {
        [_validCBButton setEnabled:NO];
        _haveAnimated = NO;
    }
}

- (void) createValidButton {
    UIImage *imageDisable = [UIImage imageNamed:@"Signup_Check_Disable"];
    UIImage *imageEnable = [UIImage imageNamed:@"Signup_Check_Enable"];
    _validCBButton = [[UIButton alloc] initWithFrame:CGRectMakeWithSize(imageDisable.size)];
    CGRectSetX(_validCBButton.frame, CGRectGetWidth(_mainBody.frame) - 40 - CGRectGetWidth(_validCBButton.frame));
    [_validCBButton setImage:imageDisable forState:UIControlStateDisabled];
    [_validCBButton setImage:imageEnable forState:UIControlStateNormal];
    [_validCBButton setEnabled:NO];
    _haveAnimated = NO;
    [_mainBody addSubview:_validCBButton];
}

- (void)animateValidButton
{
    if (_haveAnimated)
        return;
    _haveAnimated = YES;
    UIView *v = _validCBButton.superview;
    [_validCBButton removeFromSuperview];
    [v addSubview:_validCBButton];
    [_validCBButton setEnabled:YES];
    
    CGFloat duration = .2;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         _validCBButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:duration
                                               delay:0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              _validCBButton.transform = CGAffineTransformIdentity;
                                          }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:duration
                                                                    delay:0
                                                                  options:UIViewAnimationOptionAllowUserInteraction
                                                               animations:^{
                                                                   _validCBButton.transform = CGAffineTransformMakeScale(1.3, 1.3);
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   [UIView animateWithDuration:duration
                                                                                         delay:0
                                                                                       options:UIViewAnimationOptionAllowUserInteraction
                                                                                    animations:^{
                                                                                        _validCBButton.transform = CGAffineTransformIdentity;
                                                                                    }
                                                                                    completion:nil];
                                                               }];
                                          }];
                     }];
}


/**
 *  SIGNUP_TUTO_EXPLICATION_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_TUTO_EXPLICATION **********

- (void)signupPageTuto {
    [_backButton setHidden:YES];
    [_validCBButton setHidden:YES];
    _title.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE", @"");
    
    UIView *item1 = [self placePictoAndText:@"picto_accueil_collect_money" title:@"SIGNUP_VIEW_1_TITLE_1" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_1" underView:nil];
    UIView *item2 = [self placePictoAndText:@"picto_accueil_secure" title:@"SIGNUP_VIEW_1_TITLE_2" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_2" underView:item1];
    [self placePictoAndText:@"picto_accueil_friends" title:@"SIGNUP_VIEW_1_TITLE_3" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_3" underView:item2];
    [self nextButtonWithText:NSLocalizedString(@"SIGNUP_VIEW_1_BUTTON", @"") andWidth:180];
}

- (void)signupPageExplication {
    [_validCBButton setHidden:YES];
    _title.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE_2", @"");
    
    UIView *item1 = [self placePictoAndText:@"picto_accueil_time.png" title:@"SIGNUP_VIEW_2_TITLE_1" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_1" underView:nil];
    UIView *item2 = [self placePictoAndText:@"picto_accueil_credit_card.png" title:@"SIGNUP_VIEW_2_TITLE_2" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_2" underView:item1];
    [self placePictoAndText:@"picto_accueil_share.png" title:@"SIGNUP_VIEW_2_TITLE_3" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_3" underView:item2];
    [self nextButtonWithText:NSLocalizedString(@"SIGNUP_VIEW_2_BUTTON", @"") andWidth:220];
}

- (UIView *)placePictoAndText:(NSString *)pictoName title:(NSString *)title subTitle:(NSString *)subTitle underView:(UIView *)view {
    FLStartItem *item = [FLStartItem newWithTitle:@"" imageImageName:pictoName contentText:@"coucou" andSize:sizePicto];
    [item setSize:CGSizeMake(sizePicto, sizePicto)];
    if (!view)
        view = [[UIView alloc] initWithFrame:CGRectMake(0, -25, 0, 0)];
    [item setOrigin:CGPointMake(10, CGRectGetMaxY(view.frame) + 10 / ratioiPhones)];
    [_mainBody addSubview:item];
    
    [self placeTextBesidePicto:item
                     titleText:NSLocalizedString(title, @"")
                  subtitleText:NSLocalizedString(subTitle, @"")];
    
    return item;
}

- (void)nextButtonWithText:(NSString *)text andWidth:(CGFloat)width {
    FLStartButton *startButton  = [[FLStartButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_mainBody.frame) / 2 - width / 2, CGRectGetHeight(_mainBody.frame) - 44 - 28 / ratioiPhones, width, 44) title:text];
    [startButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
    [_mainBody addSubview:startButton];
}

- (void)placeTextBesidePicto:(UIView *)picto titleText:(NSString *)titleText subtitleText:(NSString *)subText {
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(picto.frame), CGRectGetMinY(picto.frame), PPScreenWidth() - CGRectGetMaxX(picto.frame) - 15, CGRectGetHeight(picto.frame))];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(textView.frame), 40)];
    [titleLabel setFont:[UIFont fontWithName:titleLabel.font.fontName size:15]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:titleText];
    [titleLabel setNumberOfLines:0];
    [titleLabel sizeToFit];
    [textView addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(titleLabel.frame), CGRectGetHeight(titleLabel.frame) + 5.0f / ratioiPhones, CGRectGetWidth(textView.frame), CGRectGetHeight(textView.frame) - titleLabel.frame.size.height)];
    [subtitleLabel setFont:[UIFont fontWithName:titleLabel.font.fontName size:13]];
    [subtitleLabel setTextColor:[UIColor lightGrayColor]];
    [subtitleLabel setText:subText];
    [subtitleLabel setNumberOfLines:0];
    [subtitleLabel sizeToFit];
    [textView addSubview:subtitleLabel];
    
    [textView setSize:CGSizeMake(CGRectGetWidth(textView.frame), CGRectGetHeight(titleLabel.frame) + CGRectGetHeight(subtitleLabel.frame) + 5.0f / ratioiPhones)];
    [textView setCenter:CGPointMake(CGRectGetMidX(textView.frame), CGRectGetMidY(picto.frame))];
    
    [_mainBody addSubview:textView];
}

/**
 *  SIGNUP_PHONE_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_PHONE **********

- (void) signupPhoneView {
    [_bar setHidden:YES];
    [_validCBButton setHidden:YES];
    logo = [UIImageView imageNamed:@"home-logo"];
    CGRectSetWidthHeight(logo.frame, 105, 105);
    CGRectSetXY(logo.frame, (SCREEN_WIDTH - logo.frame.size.width) / 2., 60);
    [self.view addSubview:logo];
    
    _phoneField = [[FLHomeTextField alloc] initWithPlaceholder:NSLocalizedString(@"NumMobile", @"") for:_userDic key:@"phone" position:CGPointMake(20, 200)];
    CGRectSetXY(_phoneField.frame, (SCREEN_WIDTH - _phoneField.frame.size.width) / 2., CGRectGetMaxY(logo.frame) + 35);
    if(SCREEN_HEIGHT < 500){
        CGRectSetXY(_phoneField.frame, (SCREEN_WIDTH - _phoneField.frame.size.width) / 2., CGRectGetMaxY(logo.frame) + 5);
    }
    [_phoneField addForNextClickTarget:self action:@selector(didConnectTouchr)];
    [self.view addSubview:_phoneField];
    
    inputView = [FLKeyboardView new];
    inputView = [inputView setKeyboardPhoneLoginWithTarget:self action:@selector(didConnectTouchr)];
    [inputView enableValidateButton:NO];
    
    inputView.textField = _phoneField.textfield;
    _phoneField.textfield.inputView = inputView;
}

- (void)didConnectTouchr
{
    [[self view] endEditing:YES];
    
    if(_userDic[@"phone"] && ![_userDic[@"phone"] isBlank] && ((NSString*)_userDic[@"phone"]).length == 10){
        [inputView enableValidateButton:YES];
        
        [[Flooz sharedInstance] showLoadView];
        [appDelegate clearSavedViewController];
        [[Flooz sharedInstance] loginWithPhone:_userDic[@"phone"]];
    }
    else {
        [inputView enableValidateButton:NO];
    }
}

/**
 *  SIGNUP_PSEUDO_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_PSEUDO **********

- (void) signupPseudoView {
    [_backButton setHidden:YES];
    _title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Pseudo", @"");
    [self displayHeader];
    [_validCBButton addTarget:self action:@selector(checkPseudo) forControlEvents:UIControlEventTouchUpInside];
    
    _userName = [[FLTextFieldIcon alloc] initWithIcon:@"" placeholder:@"FIELD_USERNAME" for:_userDic key:@"nick" position:CGPointMake(0.0f, firstItemY)];
    
    [_userName addForNextClickTarget:self action:@selector(checkPseudo)];
    [_userName addForTextChangeTarget:self action:@selector(canValidate:)];
    _firstTextFieldToFocus = _userName;
    [_mainBody addSubview:_userName];
    
    UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_userName.frame)+5, PPScreenWidth()-30, 60)];
    firstTimeText.textColor = [UIColor customPlaceholder];
    firstTimeText.font = [UIFont customTitleExtraLight:14];
    firstTimeText.numberOfLines = 0;
    firstTimeText.textAlignment = NSTextAlignmentCenter;
    firstTimeText.text = NSLocalizedString(@"SIGNUP_PSEUDO_EXPLICATION", nil);
    [_mainBody addSubview:firstTimeText];
    
    _validCBButton.center = CGPointMake(CGRectGetMidX(_validCBButton.frame), CGRectGetMidY(_userName.frame));
    [_mainBody addSubview:_validCBButton];
}

- (void) checkPseudo {
    if (_userDic[@"nick"] && ((NSString *)_userDic[@"nick"]).length >= 3) {
        [self animateValidButton];
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] verifyPseudo:_userDic[@"nick"] success:^(id result) {
            [self goToNextPage];
        } failure:^(NSError *error) {
            [_firstTextFieldToFocus becomeFirstResponder];
        }];
    }
}

/**
 *  SIGNUP_INFO_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_INFO **********

- (void) signupInfoView {
    _title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Info", @"");
    [self displayHeader];
    [_validCBButton addTarget:self action:@selector(checkEmail) forControlEvents:UIControlEventTouchUpInside];
    
    [self createFacebookButton];
    [_mainBody addSubview:_registerFacebook];
    
    _avatarView = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_mainBody.frame) / 2.0f) - (50 / 2.0f), -10, 50, 50)];
    [_mainBody addSubview:_avatarView];
    [_avatarView setHidden:YES];
    
    _name = [[FLTextFieldIcon alloc] initWithIcon:@"" placeholder:@"FIELD_FIRSTNAME" for:_userDic key:@"firstName" position:CGPointMake(0.0f, CGRectGetMaxY(_registerFacebook.frame)+12.0f) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
    _firstTextFieldToFocus = _name;
    [_name addForNextClickTarget:self action:@selector(focusOnNext)];
    [_name addForTextChangeTarget:self action:@selector(canValidate:)];
    [_mainBody addSubview:_name];
    
    _email = [[FLTextFieldIcon alloc] initWithIcon:@"" placeholder:@"FIELD_EMAIL" for:_userDic key:@"email" position:CGPointMake(0.0f, CGRectGetMaxY(_name.frame) + 5.0f / ratioiPhones)];
    [_email addForNextClickTarget:self action:@selector(checkEmail)];
    [_email addForTextChangeTarget:self action:@selector(canValidate:)];
    _secondTextFieldToFocus = _email;
    [_mainBody addSubview:_email];
    
    _validCBButton.center = CGPointMake(CGRectGetMidX(_validCBButton.frame), CGRectGetMidY(_email.frame));
}

- (void)createFacebookButton {
    _registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(15, 5, PPScreenWidth()-30.0f, 45)];
    [_registerFacebook setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.5]] forState:UIControlStateNormal];
    [_registerFacebook setTitle:NSLocalizedString(@"LOGIN_FACEBOOK", nil) forState:UIControlStateNormal];
    _registerFacebook.titleLabel.font = [UIFont customContentRegular:15];
    [_registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
    [_registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateHighlighted];
    [_registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 12)];
    [_registerFacebook addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didFacebookTouch
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] connectFacebook];
}

- (void) checkEmail {
    if (!_userDic[@"lastName"] || !_userDic[@"firstName"] || [_userDic[@"lastName"] isBlank] || [_userDic[@"lastName"] isBlank]) {
        [_firstTextFieldToFocus becomeFirstResponder];
        return;
    }
    
    if (_userDic[@"email"] && ![_userDic[@"email"] isBlank] && [self validateEmail:_userDic[@"email"]]) {
        [self animateValidButton];
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] verifyEmail:_userDic[@"email"] success:^(id result) {
            [self goToNextPage];
        } failure:^(NSError *error) {
            [_secondTextFieldToFocus becomeFirstResponder];
        }];
    }
    else {
        [_secondTextFieldToFocus becomeFirstResponder];
    }
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

/**
 *  SIGNUP_Password_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_PASSWORD **********

- (void) signupPasswordView {
    _title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Password", @"");
    [self displayHeader];
    [_validCBButton addTarget:self action:@selector(checkPassword) forControlEvents:UIControlEventTouchUpInside];
    
    _password = [[FLTextFieldIcon alloc] initWithIcon:@"" placeholder:@"FIELD_PASSWORD" for:_userDic key:@"password" position:CGPointMake(0.0f, firstItemY)];
    [_password seTsecureTextEntry:YES];
    [_password addForNextClickTarget:self action:@selector(focusOnNext)];
    [_password addForTextChangeTarget:self action:@selector(canValidate:)];
    _firstTextFieldToFocus = _password;
    [_mainBody addSubview:_password];
    
    _passwordConfirm = [[FLTextFieldIcon alloc] initWithIcon:@"" placeholder:@"FIELD_PASSWORD_CONFIRMATION" for:_userDic key:@"confirmation" position:CGPointMake(0.0f, CGRectGetMaxY(_password.frame) + 10.0f / ratioiPhones)];
    [_passwordConfirm seTsecureTextEntry:YES];
    [_passwordConfirm addForNextClickTarget:self action:@selector(checkPassword)];
    [_passwordConfirm addForTextChangeTarget:self action:@selector(canValidate:)];
    _secondTextFieldToFocus = _passwordConfirm;
    [_mainBody addSubview:_passwordConfirm];
    
    UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_passwordConfirm.frame)+2, PPScreenWidth()-30, 50)];
    firstTimeText.textColor = [UIColor customPlaceholder];
    firstTimeText.font = [UIFont customTitleExtraLight:14];
    firstTimeText.numberOfLines = 0;
    firstTimeText.textAlignment = NSTextAlignmentCenter;
    firstTimeText.text = NSLocalizedString(@"SIGNUP_PASSWORD_EXPLICATION", nil);
    [_mainBody addSubview:firstTimeText];
    
    _validCBButton.center = CGPointMake(CGRectGetMidX(_validCBButton.frame), CGRectGetMidY(_passwordConfirm.frame));
}

- (void) checkPassword {
    if (!_userDic[@"password"] || [_userDic[@"password"] length] < 6) {
        [_firstTextFieldToFocus becomeFirstResponder];
        return;
    }
    
    if (!_userDic[@"confirmation"] || [_userDic[@"confirmation"] length] < 6) {
        [_secondTextFieldToFocus becomeFirstResponder];
        return;
    }
    
    if (_userDic[@"password"] && _userDic[@"confirmation"] && [_userDic[@"password"] length] >= 6 && [_userDic[@"confirmation"] length] >= 6 && [_userDic[@"password"] isEqualToString:_userDic[@"confirmation"]]) {
        [self animateValidButton];
        
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] signup:_userDic success:^(id result) {
            [[Flooz sharedInstance] hideLoadView];
            [self goToNextPage];
        } failure:NULL];
    }
    else {
        [_firstTextFieldToFocus becomeFirstResponder];
    }
}

/**
 *  SIGNUP_Code_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_CODE **********

- (void) signupCodeView {
    [_backButton setHidden:YES];
    _title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Code", @"");
    [self displayHeader];
    [_validCBButton setHidden:YES];
    
    FLKeyboardView *keyboardView = [FLKeyboardView new];
    CGRectSetY(keyboardView.frame, CGRectGetHeight(_mainBody.frame)-CGRectGetHeight(keyboardView.frame));
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(),  CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame))];
    [backView setBackgroundColor:[UIColor customBackground]];
    [_mainBody addSubview:backView];
    
    _secureCodeField = [SecureCodeField new];
    [backView addSubview:_secureCodeField];
    
    [_mainBody addSubview:keyboardView];
    keyboardView.delegate = _secureCodeField;
    _secureCodeField.delegate = self;
    
    UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(14, CGRectGetHeight(backView.frame)-50, PPScreenWidth()-28, 50)];
    firstTimeText.textColor = [UIColor customPlaceholder];
    firstTimeText.font = [UIFont customTitleExtraLight:14];
    firstTimeText.numberOfLines = 0;
    firstTimeText.textAlignment = NSTextAlignmentCenter;
    firstTimeText.text = NSLocalizedString(@"SECORE_CODE_TEXT_FIRST_TIME", nil);
    [backView addSubview:firstTimeText];
    
    currentSecureMode = SecureCodeModeNew;
    
    CGRectSetY(_secureCodeField.frame, CGRectGetMinY(firstTimeText.frame) - CGRectGetHeight(_secureCodeField.frame) - 5);
    
    
    _mainContent = [UIView newWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    CGRectSetY(_secureCodeField.frame, 0);
    CGRectSetY(firstTimeText.frame, CGRectGetHeight(_secureCodeField.frame));
    [_mainContent addSubview:_secureCodeField];
    [_mainContent addSubview:firstTimeText];
    CGSize s = [self sizeExpectedForView:firstTimeText];
    CGRectSetHeight(firstTimeText.frame, s.height*2);
    CGRectSetHeight(_mainContent.frame, CGRectGetMaxY(firstTimeText.frame));
    [_mainContent setCenter:CGPointMake(PPScreenWidth()/2, CGRectGetMidY(backView.frame) - 4)];
    [backView addSubview:_mainContent];
}

- (void) signupCodeVerifView {
    _title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_CodeVerif", @"");
    [self displayHeader];
    [_validCBButton setHidden:YES];
    
    FLKeyboardView *keyboardView = [FLKeyboardView new];
    CGRectSetY(keyboardView.frame, CGRectGetHeight(_mainBody.frame)-CGRectGetHeight(keyboardView.frame));
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(),  CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame))];
    [backView setBackgroundColor:[UIColor customBackground]];
    [_mainBody addSubview:backView];
    
    _secureCodeField = [SecureCodeField new];
    [backView addSubview:_secureCodeField];
    CGRectSetY(_secureCodeField.frame, CGRectGetHeight(backView.frame) / 2 - CGRectGetHeight(_secureCodeField.frame) / 2 + 4);
    
    [_mainBody addSubview:keyboardView];
    keyboardView.delegate = _secureCodeField;
    _secureCodeField.delegate = self;
    
    currentSecureMode = SecureCodeModeConfirm;
    
    
    _mainContent = [UIView newWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    CGRectSetY(_secureCodeField.frame, 0);
    [_mainContent addSubview:_secureCodeField];
    CGRectSetHeight(_mainContent.frame, CGRectGetMaxY(_secureCodeField.frame));
    [_mainContent setCenter:CGPointMake(PPScreenWidth()/2, CGRectGetMidY(backView.frame) - 4)];
    [backView addSubview:_mainContent];
}

- (void)didSecureCodeEnter:(NSString *)secureCode {
    if(currentSecureMode == SecureCodeModeNew){
        [_userDic setValue:secureCode forKey:@"passcode"];
        [self goToNextPage];
    }
    else if(currentSecureMode == SecureCodeModeConfirm){
        if ([_userDic[@"passcode"] isEqualToString:secureCode]) {
            [UICKeyChainStore setString:secureCode forKey:[self keyForSecureCode]];
            [self goToNextPage];
        }
        else {
            [self startAnmiationBadCode];
            [_secureCodeField clean];
        }
    }
}

- (NSString *)keyForSecureCode
{
    return [NSString stringWithFormat:@"secureCode-%@", [[[Flooz sharedInstance] currentUser] userId]];
}

- (void)startAnmiationBadCode
{
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5., 0., 0.)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5., 0., 0.)]
                    ];
    anim.autoreverses = YES;
    anim.repeatCount = 2.;
    anim.delegate = self;
    anim.duration = 0.08;
    [_secureCodeField.layer addAnimation:anim forKey:nil];
}

/**
 *  SIGNUP_CB_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_CARTE_BANCAIRE **********

- (void) signupCBView {
    [_backButton setHidden:YES];
    _title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_CB", @"");
    [self displayHeader];
    
    [_validCBButton addTarget:self action:@selector(didValidTouch2) forControlEvents:UIControlEventTouchUpInside];
    [_validCBButton removeFromSuperview];
    CGRectSetY(_validCBButton.frame, CGRectGetMidY(_title.frame) - CGRectGetHeight(_validCBButton.frame) / 2.0f + 2.0f);
    CGRectSetX(_validCBButton.frame, CGRectGetWidth(_headerView.frame) - 20 - CGRectGetWidth(_validCBButton.frame));
    [_headerView addSubview:_validCBButton];
    
    _contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0 - 10.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [_mainBody addSubview:_contentView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [_contentView addGestureRecognizer:tapGesture];
    [_headerView addGestureRecognizer:tapGesture];
    [_mainBody addGestureRecognizer:tapGesture];
    
    [self registerForKeyboardNotifications];
    
    _viewButtonScan = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(_mainBody.frame), 60)];
    CGRectSetY(_viewButtonScan.frame, 5.0f);
    _viewButtonScan.backgroundColor = [UIColor customBackgroundHeader];
    [_contentView addSubview:_viewButtonScan];
    {
        CGFloat MARGE_LEFT_RIGHT = 28;
        CGFloat MARGE_TOP_BOTTOM = 10;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP_BOTTOM, CGRectGetWidth(_viewButtonScan.frame) - (2 * MARGE_LEFT_RIGHT), CGRectGetHeight(_viewButtonScan.frame) - (2 * MARGE_TOP_BOTTOM))];
        button.backgroundColor = [UIColor customBackgroundStatus];
        [button setTitle:NSLocalizedString(@"CREDIT_CARD_SCAN", Nil) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont customTitleExtraLight:14];
        [button addTarget:self action:@selector(presentScanPayViewController) forControlEvents:UIControlEventTouchUpInside];
        [_viewButtonScan addSubview:button];
    }
    
    FLTextFieldTitle2 *ownerField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_OWNER_PLACEHOLDER" for:_userDic key:@"holder" position:CGPointMake(20, 60)];
    [ownerField addForNextClickTarget:self action:@selector(didOwnerEndEditing)];
    [_contentView addSubview:ownerField];
    [fieldsView addObject:ownerField];
    
    
    FLTextFieldTitle2 *cardNumberField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_NUMBER_PLACEHOLDER" for:_userDic key:@"number" position:CGPointMake(20, CGRectGetMaxY(ownerField.frame) + 2)];
    [cardNumberField setKeyboardType:UIKeyboardTypeDecimalPad];
    [cardNumberField setStyle:FLTextFieldTitle2StyleCardNumber];
    [cardNumberField addForNextClickTarget:self action:@selector(didNumberEndEditing)];
    [_contentView addSubview:cardNumberField];
    [fieldsView addObject:cardNumberField];
    
    
    FLTextFieldTitle2 *expireField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_EXPIRES_PLACEHOLDER" for:_userDic key:@"expires" position:CGPointMake(20, CGRectGetMaxY(cardNumberField.frame) + 2)];
    [expireField setKeyboardType:UIKeyboardTypeDecimalPad];
    [expireField setStyle:FLTextFieldTitle2StyleCardExpire];
    [expireField addForNextClickTarget:self action:@selector(didExpiresEndEditing)];
    [_contentView addSubview:expireField];
    [fieldsView addObject:expireField];
    
    
    FLTextFieldTitle2 *cvvField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_CVV_PLACEHOLDER" for:_userDic key:@"cvv" position:CGPointMake(20, CGRectGetMaxY(expireField.frame) + 2)];
    [cvvField setKeyboardType:UIKeyboardTypeDecimalPad];
    [cvvField setStyle:FLTextFieldTitle2StyleCVV];
    [cvvField addForNextClickTarget:self action:@selector(didCVVEndEditing)];
    [_contentView addSubview:cvvField];
    [fieldsView addObject:cvvField];
    
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(cvvField.frame) + 100);
    [self ignoreButtonWithText:NSLocalizedString(@"SIGNUP_VIEW_IGNORE_BUTTON", @"") superV:_contentView];
}

- (void)didOwnerEndEditing
{
    [fieldsView[1] becomeFirstResponder];
    [self verifAllFieldForCB];
}

- (void)didNumberEndEditing
{
    [fieldsView[2] becomeFirstResponder];
    [self verifAllFieldForCB];
}

- (void)didExpiresEndEditing
{
    [fieldsView[3] becomeFirstResponder];
    [self verifAllFieldForCB];
}

- (void)didCVVEndEditing
{
    [[self view] endEditing:YES];
    [self verifAllFieldForCB];
}

- (BOOL)verifAllFieldForCB {
    BOOL verifOk = YES;
    if (!_userDic[@"number"] || !_userDic[@"cvv"] || !_userDic[@"expires"] || !_userDic[@"holder"] ||
        [_userDic[@"number"] isBlank] || [_userDic[@"cvv"] isBlank] || [_userDic[@"expires"] isBlank] || [_userDic[@"holder"] isBlank]) {
        verifOk = NO;
        [_validCBButton setEnabled:NO];
        _haveAnimated = NO;
    }
    else {
        [self animateValidButton];
    }
    return verifOk;
}

- (void)didValidTouch2
{
    if ([self verifAllFieldForCB]) {
        [[self view] endEditing:YES];
        
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] createCreditCard:_userDic success:^(id result) {
            [self goToNextPage];
        }];
    }
}

#pragma mark - ScanPay

- (void)presentScanPayViewController
{
    ScanPayViewController * scanPayViewController = [[ScanPayViewController alloc] initWithToken:@"be38035037ed6ca3cba7089b" useConfirmationView:YES useManualEntry:YES];
    
    [scanPayViewController startScannerWithViewController:self success:^(SPCreditCard * card){
        
        [_userDic setValue:card.number forKey:@"number"];
        [_userDic setValue:card.cvc forKey:@"cvv"];
        
        NSString *expires = [NSString stringWithFormat:@"%@-%@", card.month, card.year];
        
        [_userDic setValue:expires forKey:@"expires"];
        
        [_viewButtonScan setHidden:YES];
        for(FLTextFieldTitle2 *view in fieldsView){
            [view reloadData];
            CGRectSetY(view.frame, CGRectGetMinY(view.frame)-CGRectGetHeight(_viewButtonScan.frame));
        }
        [self verifAllFieldForCB];
    } cancel:^{
        [fieldsView[1] becomeFirstResponder];
    }];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications
{
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillDisappear
{
    _contentView.contentInset = UIEdgeInsetsZero;
}

-(void)hideKeyboard
{
    [self.view endEditing:YES];
}

/**
 *  SIGNUP_FRIENDS_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_FRIENDS **********

- (void) signupFriendView {
    [_backButton setHidden:YES];
    [_validCBButton setHidden:YES];
    _title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Friends", @"");
    [self displayHeader];
    
    UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(10, -5, PPScreenWidth()-20, 50)];
    firstTimeText.textColor = [UIColor customPlaceholder];
    firstTimeText.font = [UIFont customTitleExtraLight:14];
    firstTimeText.numberOfLines = 0;
    firstTimeText.textAlignment = NSTextAlignmentCenter;
    firstTimeText.text = NSLocalizedString(@"SIGNUP_FRIENDS_MESSAGE", nil);
    [_mainBody addSubview:firstTimeText];
    
    CGRectSetHeight(firstTimeText.frame, [self sizeExpectedForView:firstTimeText].height*3);
    //TODO: supprimer si on veut le texte d'explication
    CGRectSetHeight(firstTimeText.frame, 0);
    
    UIButton *butt = [self ignoreButtonWithText:NSLocalizedString(@"SIGNUP_VIEW_IGNORE_BUTTON_2", @"") superV:_mainBody];
    CGRectSetWidth(butt.frame, [self sizeExpectedForView:butt].width + 30.0f);
    CGRectSetX(butt.frame, CGRectGetWidth(_mainBody.frame) - CGRectGetWidth(butt.frame));
    CGRectSetY(butt.frame, CGRectGetMaxY(firstTimeText.frame));
    CGRectSetHeight(butt.frame, [self sizeExpectedForView:butt].height + 10.0f);
    
    if (_contactInfoArray == nil) {
        _contactInfoArray = [NSMutableArray new];
    }
    _contactToInvite = [NSMutableArray new];
    _contactFromFlooz = [NSMutableArray new];
    
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // If the app is authorized to access the first time then add the contact
                
                [self createTableContactUnderView: butt];
                [self createContactList];
            } else {
                // Show an alert here if user denies access telling that the contact cannot be added because you didn't allow it to access the contacts
                [self displayAlertWithText:NSLocalizedString(@"ALERT_CONTACT_DENIES_ACCESS_PREVIOUS", @"")];
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // If the user user has earlier provided the access, then add the contact
        [self createTableContactUnderView: butt];
        [self createContactList];
    }
    else {
        // If the user user has NOT earlier provided the access, create an alert to tell the user to go to Settings app and allow access
        [self displayAlertWithText:NSLocalizedString(@"ALERT_CONTACT_DENIES_ACCESS", @"")];
    }
}

- (void) displayAlertWithText:(NSString *)alertMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GLOBAL_ERROR", nil)
                                                    message:alertMessage
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil)
                                          otherButtonTitles:nil
                          ];
    alert.delegate = self;
    alert.tag = 25;
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
}

- (void) createTableContactUnderView:(UIView *)topView {
    _contactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(topView.frame)) style:UITableViewStylePlain];
    [_contactsTableView setBackgroundColor:[UIColor customBackground]];
    [_contactsTableView setSeparatorColor:[UIColor customBackgroundHeader]];
    [_contactsTableView setSeparatorInset:UIEdgeInsetsZero];
    [_contactsTableView setAllowsMultipleSelection: YES];
    
    [_mainBody addSubview:_contactsTableView];
    
    [_contactsTableView setDataSource:self];
    [_contactsTableView setDelegate:self];
}

- (void) createContactList {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createContactList:^(NSMutableArray *arrayContacts, NSMutableArray *arrayServer) {
        _contactInfoArray = [[self sortedArray:arrayContacts withKey:@"firstName" ascending:YES] mutableCopy];
        [[Flooz sharedInstance] hideLoadView];
        
        NSDictionary *params = @{@"phones": arrayServer};
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] sendContactsWithParams:params success:^(id result) {
            _contactFromFlooz = [[Flooz sharedInstance] createFriendsArrayFromResult:result];
            [self removeFloozerToMyContact];
            [[Flooz sharedInstance] hideLoadView];
        } failure:^(NSError *error) {
            [self removeFloozerToMyContact];
            [[Flooz sharedInstance] hideLoadView];
        }];
    }];
}

- (void) removeFloozerToMyContact {
    if (_contactFromFlooz.count) {
        [_contactsTableView beginUpdates];
        for (FLUser *contact in _contactFromFlooz) {
            int index = [self findUserInAllMyContacts:contact];
            if (index != -1) {
                [_contactInfoArray removeObjectAtIndex:index];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
                [_contactsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        NSIndexSet *index = [[NSIndexSet alloc] initWithIndex:0];
        [_contactsTableView reloadSections:index withRowAnimation:UITableViewRowAnimationTop];
        [_contactsTableView endUpdates];
    }
}

- (int) findUserInAllMyContacts:(FLUser *)contact {
    int i = 0;
    for (NSDictionary *infoContact in _contactInfoArray) {
        for (NSString *phone in infoContact[@"phones"]) {
            if ([phone isEqualToString:contact.phone]) {
                return i;
            }
        }
        i ++;
    }
    return -1;
}

- (NSArray *) sortedArray:(NSArray *)array withKey:(NSString *)key ascending:(BOOL)ascending {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                 ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [array sortedArrayUsingDescriptors:sortDescriptors];
}

#pragma mark - UIAlertView Delegate

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 25) {
        [self goToNextPage];
    }
}

#pragma mark - TableView Delegate & Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return _contactFromFlooz.count;
    else
        return _contactInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ContactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor customBackground];
    }
    
    if (indexPath.section == 0) {
        FLUser *contact = _contactFromFlooz[indexPath.row];
        [cell setCellWithCompleteName:contact.fullname subText:contact.username andImageUrl:contact.avatarURL];
        [cell.addFriendButton addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = nil;
    }
    else {
        NSDictionary *contact = _contactInfoArray[indexPath.row];
        
        NSString *phones = @"";
        for (NSString *phone in contact[@"phones"]) {
            phones = [phones stringByAppendingString:phone];
            phones = [phones stringByAppendingString:@", "];
        }
        phones = [phones substringToIndex:phones.length-2];
        
        [cell setCellWithFirstName:contact[@"firstName"] lastName:contact[@"lastName"] subText:phones andDataImage:contact[@"imageData"]];
        
        cell.accessoryView = nil;
        if ([contact[@"selected"] boolValue]) {
            cell.accessoryView = [UIImageView imageNamed:@"Signup_Box_Check"];
        }
        else {
            cell.accessoryView = [UIImageView imageNamed:@"Signup_Box_Uncheck"];
        }
        
        [cell.addFriendButton setHidden:YES];
    }
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0){
        return NSLocalizedString(@"CONTACT_PICKER_FLOOZ", nil);
    }
    return NSLocalizedString(@"CONTACT_PICKER_NON_FLOOZ", nil);
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0 && !_contactFromFlooz.count){
        return 0;
    }
    else if(section == 1 && !_contactInfoArray.count){
        return 0;
    }
    return 28;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat heigth = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), heigth)];
    
    view.backgroundColor = [UIColor customBackgroundHeader];
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 0, CGRectGetHeight(view.frame))];
        
        label.textColor = [UIColor customBlueLight];
        
        label.font = [UIFont customContentRegular:10];
        label.text = [self tableView:tableView titleForHeaderInSection:section];
        [label setWidthToFit];
        
        [view addSubview:label];
    }
    
    {
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame), CGRectGetWidth(view.frame), 1)];
        
        separator.backgroundColor = [UIColor customSeparator];
        
        [view addSubview:separator];
    }
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        ContactCell *cell = (ContactCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:![cell isSelected]];
        
        NSMutableDictionary *contact = [_contactInfoArray[indexPath.row] mutableCopy];
        
        cell.accessoryView = nil;
        if (![contact[@"selected"] boolValue]) {
            [contact setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
            cell.accessoryView = [UIImageView imageNamed:@"Signup_Box_Check"];
            [_contactToInvite addObject:contact];
        }
        else {
            [_contactToInvite removeObject:contact];
            [contact setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
            cell.accessoryView = [UIImageView imageNamed:@"Signup_Box_Uncheck"];
        }
        [_contactInfoArray replaceObjectAtIndex:indexPath.row withObject:contact];
        [self displaySendButtonOrNot];
    }
}

- (void)displaySendButtonOrNot {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_mainBody.frame), CGRectGetWidth(_contactsTableView.frame), 50.0f)];
        
        FLStartItem *item = [FLStartItem newWithTitle:@"" imageImageName:@"Signup_Check_Enable" contentText:@"" andSize:50.0f];
        CGRectSetX(item.frame, CGRectGetWidth(_footerView.frame)-50.0f);
        [_footerView addSubview:item];
        
        UIButton *b = [UIButton newWithFrame:CGRectMake(0, 0, CGRectGetWidth(_contactsTableView.frame), 50.0f)];
        [b setTitle:NSLocalizedString(@"Invite_Friends_Button", @"") forState:UIControlStateNormal];
        [b addTarget:self action:@selector(inviteFriends) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:b];
        
        CALayer *TopBorder = [CALayer layer];
        TopBorder.frame = CGRectMake(0.0f, 0.0f, _footerView.frame.size.width, 2.0f);
        TopBorder.backgroundColor = [UIColor customBlue].CGColor;
        [_footerView.layer addSublayer:TopBorder];
        
        [_mainBody addSubview:_footerView];
    }
    if (_contactToInvite.count > 0) {
        if (CGRectGetMinY(_footerView.frame) >= CGRectGetHeight(_mainBody.frame)) {
            [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                CGRectSetHeight(_contactsTableView.frame, CGRectGetHeight(_contactsTableView.frame) - 50.0f);
                CGRectSetY(_footerView.frame, CGRectGetMinY(_footerView.frame)-50.0f);
            } completion:nil];
        }
    }
    else {
        if (CGRectGetHeight(_mainBody.frame) > CGRectGetMinY(_footerView.frame)) {
            [UIView animateWithDuration:.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                CGRectSetHeight(_contactsTableView.frame, CGRectGetHeight(_contactsTableView.frame) + 50.0f);
                CGRectSetY(_footerView.frame, CGRectGetHeight(_mainBody.frame));
            } completion:nil];
        }
    }
}

- (void) inviteFriends {
    MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
    if ([MFMessageComposeViewController canSendText]) {
        message.messageComposeDelegate = self;
        
        NSMutableArray *listOfPhone = [NSMutableArray new];
        for (NSDictionary *contact in _contactToInvite) {
            for (NSString *phone in contact[@"phones"]) {
                [listOfPhone addObject:phone];
            }
        }
        [message setRecipients: listOfPhone];
        [message setBody:@"Rejoins moi sur Flooz"];
        
        message.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:message animated:YES completion:nil];
    }
}

- (void) addFriend:(UIButton *)button {
    UITableViewCell *cell = (UITableViewCell *)[self findFirstViewInHierarchyOfClass:[UITableViewCell class] object:button];
    NSIndexPath *indexPath = [_contactsTableView indexPathForCell:cell];
    
    NSDictionary *contact = _contactFromFlooz[indexPath.row];
    [[Flooz sharedInstance] friendAcceptSuggestion:contact[@"_id"] success:^{
        [_contactFromFlooz removeObjectAtIndex:indexPath.row];
        [_contactsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (UIView*)findFirstViewInHierarchyOfClass:(Class)classToLookFor object:(UIView *)v
{
    UIView *sView = v.superview;
    while (sView) {
        if ([sView isKindOfClass:classToLookFor]) {
            return sView;
        }
        sView = [sView superview];
    }
    return sView;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:^{
        if (result == MessageComposeResultSent) {
            [self goToNextPage];
        }
        else if (result == MessageComposeResultFailed) {
            [self displayAlertWithText:NSLocalizedString(@"ALERT_CONTACT_DENIES_ACCESS_PREVIOUS", @"")];
        }
    }];
}

@end
