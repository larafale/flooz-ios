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

//#define CGRectSetYWidth(frame, y, width) frame = CGRectMake(frame.origin.x, y, width, frame.size.height)
//#define CGRectSetYHeight(frame, y, height) frame = CGRectMake(frame.origin.x, y, frame.size.width, height)

@interface FirstLaunchContentViewController ()
{
    CGFloat sizePicto;
    CGFloat ratioiPhones;
    CGFloat firstItemY;
    
    UIImageView *logo;
    NSMutableDictionary *_userDic;
    
    FLKeyboardView *inputView;
    
    UIView *_headerView;
    UILabel *_title;
    UIView *_bar;
    UIButton *_backButton;
    
    UIView *_mainBody;
    
    SecureCodeMode2 currentSecureMode;
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
    // Do any additional setup after loading the view.
    
    sizePicto = 110.0f;
    ratioiPhones = 1.0f;
    if (PPScreenHeight() < 568) {
        ratioiPhones = 1.2f;
        sizePicto = sizePicto / ratioiPhones;
    }
    
    _userInfoDico = [NSMutableDictionary new];
    _userDic = [NSMutableDictionary new];
    
    [self prepareHeader];
	[self setContent];
}

- (void)prepareHeader {
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT + 16, PPScreenWidth(), 80.0f)];
    if (PPScreenHeight() < 500.0f) {
        CGRectSetHeight(_headerView.frame, 60.0f);
    }
    [self.view addSubview:_headerView];
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50 / ratioiPhones)];
    _title.font = [UIFont customTitleExtraLight:28];
    _title.textColor = [UIColor customBlueLight];
    _title.textAlignment = NSTextAlignmentCenter;
    
    _bar = [[UIView alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(_title.frame) + 15.0f / ratioiPhones, 50.0f, 1.0f)];
    [_bar setBackgroundColor:[UIColor customBlueLight]];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMinY(_title.frame) + 12.0f, 30, 30)];
    [_backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(goToPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    if (PPScreenHeight() < 500.0f) {
        CGRectSetY(_backButton.frame, CGRectGetMinY(_title.frame) + 7.0f);
    }
    [_headerView addSubview:_title];
    [_headerView addSubview:_bar];
    [_headerView addSubview:_backButton];
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), PPScreenWidth(), PPScreenHeight()-CGRectGetMaxY(_headerView.frame))];
    [self.view addSubview:_mainBody];
}

- (void)nextButtonWithText:(NSString *)text andWidth:(CGFloat)width {
    FLStartButton *startButton  = [[FLStartButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_mainBody.frame) / 2 - width / 2, CGRectGetHeight(_mainBody.frame) - 44 - 28 / ratioiPhones, width, 44) title:text];
    [startButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
    [_mainBody addSubview:startButton];
}

- (void) displayHeader {
    [self.view setBackgroundColor: [UIColor customBackground]];
    
    CGRectSetY(_headerView.frame, STATUSBAR_HEIGHT+44);
    if (PPScreenHeight() < 500.0f) {
        CGRectSetY(_title.frame, -5.0f);
        CGRectSetY(_bar.frame, CGRectGetMaxY(_title.frame)+2.0f);
        CGRectSetY(_backButton.frame, CGRectGetMinY(_title.frame) + 7.0f);
    }
    
    CGRectSetY(_mainBody.frame, CGRectGetMaxY(_headerView.frame));
    CGRectSetHeight(_mainBody.frame, PPScreenHeight()-CGRectGetMaxY(_headerView.frame));
    
    firstItemY = 25.0f / ratioiPhones;
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self displayChanges];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
    [self focus];
}

- (void)displayChanges {
    [_userDic addEntriesFromDictionary:_userInfoDico];
    switch (_pageIndex) {
        case SignupPageInfo: {
            if(_userInfoDico[@"avatarURL"]){
                [_avatarView setImageFromURL:_userInfoDico[@"avatarURL"]];
                [_avatarView setHidden:NO];
                [_registerFacebook setHidden:YES];
            }
            else {
                [_avatarView setHidden:YES];
                [_registerFacebook setHidden:NO];
            }
            [_name setTextFirstTextField:_userInfoDico[@"firstName"]];
            [_name setTextSecondTextField:_userInfoDico[@"lastName"]];
            [_email setTextFirstTextField:_userInfoDico[@"email"]];
        }
            break;
		case SignupPagePassword: {
            [_userInfoDico setValue:@"" forKey:@"password"];
            [_userInfoDico setValue:@"" forKey:@"confirmation"];
            [_userDic setValue:@"" forKey:@"password"];
            [_userDic setValue:@"" forKey:@"confirmation"];
            [_password setTextFirstTextField:@""];
            [_passwordConfirm setTextFirstTextField:@""];
        }
        default: {
            dispatch_async(dispatch_get_main_queue(), ^{
                FirstLaunchContentViewController *strongSelf = self;
                [strongSelf.userName setTextFirstTextField:_userInfoDico[@"nick"]];
                [strongSelf.secureCodeField clean];
            });
        }
            break;
    }
}

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
            if(_userInfoDico[@"avatarURL"]){
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
        [strongSelf.textFieldToFocus becomeFirstResponder];
    });
}

- (void)focusOnSecond {
    dispatch_async(dispatch_get_main_queue(), ^{
        FirstLaunchContentViewController *strongSelf = self;
        [strongSelf.secondTextFieldToFocus becomeFirstResponder];
    });
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setContent
{
    switch (_pageIndex) {
		case SignupPageTuto: {
            [_backButton setHidden:YES];
            _title.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE", @"");
            
            UIView *item1 = [self placePictoAndText:@"picto_accueil_collect_money" title:@"SIGNUP_VIEW_1_TITLE_1" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_1" underView:nil];
            UIView *item2 = [self placePictoAndText:@"picto_accueil_secure" title:@"SIGNUP_VIEW_1_TITLE_2" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_2" underView:item1];
            [self placePictoAndText:@"picto_accueil_friends" title:@"SIGNUP_VIEW_1_TITLE_3" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_3" underView:item2];
            [self nextButtonWithText:NSLocalizedString(@"SIGNUP_VIEW_1_BUTTON", @"") andWidth:180];
        }
            break;
		case SignupPageExplication: {
            _title.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE_2", @"");
            
            UIView *item1 = [self placePictoAndText:@"picto_accueil_time.png" title:@"SIGNUP_VIEW_2_TITLE_1" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_1" underView:nil];
            UIView *item2 = [self placePictoAndText:@"picto_accueil_credit_card.png" title:@"SIGNUP_VIEW_2_TITLE_2" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_2" underView:item1];
            [self placePictoAndText:@"picto_accueil_share.png" title:@"SIGNUP_VIEW_2_TITLE_3" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_3" underView:item2];
            [self nextButtonWithText:NSLocalizedString(@"SIGNUP_VIEW_2_BUTTON", @"") andWidth:220];
        }
            break;
        case SignupPagePhone: {
            [_bar setHidden:YES];
            
            logo = [UIImageView imageNamed:@"home-logo"];
            CGRectSetWidthHeight(logo.frame, 105, 105);
            CGRectSetXY(logo.frame, (SCREEN_WIDTH - logo.frame.size.width) / 2., 60);
            [self.view addSubview:logo];
            
            self.phoneField = [[FLHomeTextField alloc] initWithPlaceholder:@"06 ou code" for:_userDic key:@"phone" position:CGPointMake(20, 200)];
            
            if(SCREEN_HEIGHT < 500){
                CGRectSetXY(self.phoneField.frame, (SCREEN_WIDTH - self.phoneField.frame.size.width) / 2., CGRectGetMaxY(logo.frame) + 5);
            }
            else{
                CGRectSetXY(self.phoneField.frame, (SCREEN_WIDTH - self.phoneField.frame.size.width) / 2., CGRectGetMaxY(logo.frame) + 35);
            }
            [self.phoneField addForNextClickTarget:self action:@selector(didConnectTouchr)];
            [self.view addSubview:self.phoneField];
            
            inputView = [FLKeyboardView new];
            inputView.textField = self.phoneField.textfield;
            self.phoneField.textfield.inputView = inputView;
        }
            break;
        case SignupPagePseudo: {
            [_backButton setHidden:YES];
            _title.text = NSLocalizedString(@"Pseudo", @"");
            [self displayHeader];
            
            _userName = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:_userDic key:@"nick" position:CGPointMake(0.0f, firstItemY)];
            [_userName addForNextClickTarget:self action:@selector(checkPseudo)];
            self.textFieldToFocus = _userName;
            [_mainBody addSubview:_userName];
        }
            break;
        case SignupPageInfo: {
            _title.text = NSLocalizedString(@"Informations", @"");
            [self displayHeader];
            
            _registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(20, -5, PPScreenWidth()-40.0f, 40)];
            [_registerFacebook setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.5]] forState:UIControlStateNormal];
            [_registerFacebook setTitle:NSLocalizedString(@"LOGIN_FACEBOOK", nil) forState:UIControlStateNormal];
            _registerFacebook.titleLabel.font = [UIFont customContentRegular:15];
            [_registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateNormal];
            [_registerFacebook setImage:[UIImage imageNamed:@"facebook"] forState:UIControlStateHighlighted];
            [_registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(-1, 0, 0, 12)];
            [_registerFacebook addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
            [_mainBody addSubview:_registerFacebook];
            
            _avatarView = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_mainBody.frame) / 2.0f) - (50 / 2.0f), -10, 50, 50)];
            [_mainBody addSubview:_avatarView];
            [_avatarView setHidden:YES];
            
            _name = [[FLTextFieldIcon alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:_userDic key:@"firstName" position:CGPointMake(0.0f, firstItemY+15.0f) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
            self.textFieldToFocus = _name;
            [_name addForNextClickTarget:self action:@selector(focusOnNext)];
            [_mainBody addSubview:_name];
            
            _email = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_userDic key:@"email" position:CGPointMake(0.0f, CGRectGetMaxY(_name.frame) + 5.0f / ratioiPhones)];
            [_email addForNextClickTarget:self action:@selector(checkEmail)];
            self.secondTextFieldToFocus = _email;
            [_mainBody addSubview:_email];
        }
            break;
        case SignupPagePassword: {
            _title.text = NSLocalizedString(@"Mot de passe", @"");
            [self displayHeader];
            
            _password = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:_userDic key:@"password" position:CGPointMake(0.0f, firstItemY)];
            [_password seTsecureTextEntry:YES];
            [_password addForNextClickTarget:self action:@selector(focusOnNext)];
            self.textFieldToFocus = _password;
            [_mainBody addSubview:_password];
            
            _passwordConfirm = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD_CONFIRMATION" for:_userDic key:@"confirmation" position:CGPointMake(0.0f, CGRectGetMaxY(_password.frame) + 10.0f / ratioiPhones)];
            [_passwordConfirm seTsecureTextEntry:YES];
            [_passwordConfirm addForNextClickTarget:self action:@selector(checkPassword)];
            self.secondTextFieldToFocus = _passwordConfirm;
            [_mainBody addSubview:_passwordConfirm];
        }
            break;
        case SignupPageCode: {
            _title.text = NSLocalizedString(@"Code secret", @"");
            [self displayHeader];
            
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
            
            UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetHeight(backView.frame)-50, PPScreenWidth()-30, 50)];
            firstTimeText.textColor = [UIColor customBlueLight];
            firstTimeText.font = [UIFont customContentRegular:14];
            firstTimeText.numberOfLines = 0;
            firstTimeText.textAlignment = NSTextAlignmentCenter;
            firstTimeText.text = NSLocalizedString(@"SECORE_CODE_TEXT_FIRST_TIME", nil);
            [backView addSubview:firstTimeText];
            
            currentSecureMode = SecureCodeModeNew;
            
            CGRectSetY(self.secureCodeField.frame, CGRectGetMinY(firstTimeText.frame) - CGRectGetHeight(self.secureCodeField.frame) - 5);
        }
            break;
        case SignupPageCodeVerif: {
            _title.text = NSLocalizedString(@"Retapez code secret", @"");
            [self displayHeader];
            
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
        }
            break;
        case SignupPageCB: {
            [_backButton setHidden:YES];
            _title.text = NSLocalizedString(@"Carte bancaire", @"");
            [self displayHeader];
            
        }
            break;
        case SignupPageFriends: {
            [_backButton setHidden:YES];
            _title.text = NSLocalizedString(@"Invitez des amis", @"");
            [self displayHeader];
            
        }
            break;
        default: {
            _title.text = [NSString stringWithFormat:@"%d", (int)_pageIndex];
        }
            break;
    }
}

- (UIView *)placePictoAndText:(NSString *)pictoName title:(NSString *)title subTitle:(NSString *)subTitle underView:(UIView *)view {
    FLStartItem *item = [FLStartItem newWithTitle:@"" imageImageName:pictoName contentText:@"coucou" andSize:sizePicto];
    [item setSize:CGSizeMake(sizePicto, sizePicto)];
    if (!view)
        view = [[UIView alloc] initWithFrame:CGRectMake(0, -15, 0, 0)];
    [item setOrigin:CGPointMake(10, CGRectGetMaxY(view.frame) + 15 / ratioiPhones)];
    [_mainBody addSubview:item];
    
    [self placeTextBesidePicto:item
                     titleText:NSLocalizedString(title, @"")
                  subtitleText:NSLocalizedString(subTitle, @"")];
    
    return item;
}

- (void)placeTextBesidePicto:(UIView *)picto titleText:(NSString *)titleText subtitleText:(NSString *)subText {
    UIView *textView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(picto.frame), CGRectGetMinY(picto.frame), PPScreenWidth() - CGRectGetMaxX(picto.frame) - 15, CGRectGetHeight(picto.frame))];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(textView.frame), 40)];
    [titleLabel setFont:[UIFont fontWithName:titleLabel.font.fontName size:12]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:titleText];
    [titleLabel setNumberOfLines:0];
    [titleLabel sizeToFit];
    [textView addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(titleLabel.frame), CGRectGetHeight(titleLabel.frame) + 5.0f / ratioiPhones, CGRectGetWidth(textView.frame), CGRectGetHeight(textView.frame) - titleLabel.frame.size.height)];
    [subtitleLabel setFont:[UIFont fontWithName:titleLabel.font.fontName size:11]];
    [subtitleLabel setTextColor:[UIColor lightGrayColor]];
    [subtitleLabel setText:subText];
    [subtitleLabel setNumberOfLines:0];
    [subtitleLabel sizeToFit];
    [textView addSubview:subtitleLabel];
    
    [textView setSize:CGSizeMake(CGRectGetWidth(textView.frame), CGRectGetHeight(titleLabel.frame) + CGRectGetHeight(subtitleLabel.frame) + 5.0f / ratioiPhones)];
    [textView setCenter:CGPointMake(CGRectGetMidX(textView.frame), CGRectGetMidY(picto.frame))];
    
    [_mainBody addSubview:textView];
}


- (void)didConnectTouchr
{
    [[self view] endEditing:YES];
    
    if(_userDic[@"phone"] && ![_userDic[@"phone"] isBlank]){
        inputView = [inputView setKeyboardValidateWithTarget:self action:@selector(didConnectTouchr)];
        
        [[Flooz sharedInstance] showLoadView];
        [appDelegate clearSavedViewController];
        [_userInfoDico addEntriesFromDictionary:_userDic];
        [[Flooz sharedInstance] loginWithPhone:_userDic[@"phone"]];
    }
}

- (void)focusOnNext {
    [self.secondTextFieldToFocus becomeFirstResponder];
}

- (void) checkPseudo {
    if (_userDic[@"nick"] && ![_userDic[@"nick"] isBlank]) {
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] verifyPseudo:_userDic[@"nick"] success:^(id result) {
            [_userInfoDico addEntriesFromDictionary:_userDic];
            [self goToNextPage];
        } failure:^(NSError *error) {
            [self.textFieldToFocus becomeFirstResponder];
        }];
    }
}

- (void) checkEmail {
    if (!_userDic[@"lastName"] || !_userDic[@"firstName"] || [_userDic[@"lastName"] isBlank] || [_userDic[@"lastName"] isBlank]) {
        [self.textFieldToFocus becomeFirstResponder];
        return;
    }
    
    if (_userDic[@"email"] && ![_userDic[@"email"] isBlank] && [self validateEmail:_userDic[@"email"]]) {
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] verifyEmail:_userDic[@"email"] success:^(id result) {
            [_userInfoDico addEntriesFromDictionary:_userDic];
            [self goToNextPage];
        } failure:^(NSError *error) {
            [self.secondTextFieldToFocus becomeFirstResponder];
        }];
    }
    else {
        [self.secondTextFieldToFocus becomeFirstResponder];
    }
}

- (void) checkPassword {
    if (!_userDic[@"password"] || [_userDic[@"password"] isBlank]) {
        [self.textFieldToFocus becomeFirstResponder];
        return;
    }
    
    if (!_userDic[@"confirmation"] || [_userDic[@"confirmation"] isBlank]) {
        [self.secondTextFieldToFocus becomeFirstResponder];
        return;
    }
    
    if (_userDic[@"password"] && _userDic[@"confirmation"] && ![_userDic[@"password"] isBlank] && ![_userDic[@"confirmation"] isBlank] && [_userDic[@"password"] isEqualToString:_userDic[@"confirmation"]]) {
        [_userInfoDico addEntriesFromDictionary:_userDic];
        
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] signup:_userInfoDico success:^(id result) {
            [self goToNextPage];
        } failure:NULL];
    }
    else {
        [self.textFieldToFocus becomeFirstResponder];
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

#pragma mark - button methods
- (void) goToNextPage {
    if ([self.delegate respondsToSelector:@selector(goToNextPage:withUser:)]) {
		[self.delegate goToNextPage:_pageIndex withUser:_userInfoDico];
	}
}
- (void) goToPreviousPage {
    if ([self.delegate respondsToSelector:@selector(goToPreviousPage:withUser:)]) {
		[self.delegate goToPreviousPage:_pageIndex withUser:_userInfoDico];
	}
}

- (void)didFacebookTouch
{
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] connectFacebook];
}

#pragma mark - securecode delegate

- (void)didSecureCodeEnter:(NSString *)secureCode {
    if(currentSecureMode == SecureCodeModeNew){
        [_userInfoDico setValue:secureCode forKey:@"passcode"];
        [self goToNextPage];
    }
    else if(currentSecureMode == SecureCodeModeConfirm){
        if ([_userInfoDico[@"passcode"] isEqualToString:secureCode]) {
            [UICKeyChainStore setString:secureCode forKey:[self keyForSecureCode]];
        }
        else {
            [self startAnmiationBadCode];
            [_secureCodeField clean];
        }
    }
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

#pragma mark - SecureCode

- (NSString *)keyForSecureCode
{
    return [NSString stringWithFormat:@"secureCode-%@", [[[Flooz sharedInstance] currentUser] userId]];
}

@end
