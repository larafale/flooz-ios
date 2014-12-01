//
//  SignupViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-09-09.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SignupViewController.h"
#import "FLStartButton.h"
#import "FLStartItem.h"

#import "AppDelegate.h"
#import "FLKeyboardView.h"

#import <UICKeyChainStore.h>
#import "ScanPayViewController.h"
#import "WebViewController.h"
#import "3DSecureViewController.h"

#define PADDING_SIDE 20.0f
#define numberOfDigit 4

@interface SignupViewController ()
{
	CGFloat sizePicto;
	CGFloat ratioiPhones;
	CGFloat firstItemY;

	//GENERAL
	NSMutableDictionary *_userDic;
	UIView *_headerView;
	UIView *_mainBody;
	UIView *_mainContent;

	UILabel *_title;
	UIButton *_backButton;
	UIButton *_nextButton;

	UIImageView *logo;

	NSMutableArray *fieldsView;
	FLKeyboardView *inputView;

	//SIGNUP PSEUDO
	FLTextFieldSignup *_userName;

	//SIGNUP PHOTO
	FLUserView *_avatarView;
	UIButton *_avatarButton;
	UIButton *_registerFacebook;

	//SIGNUP INFORMATION
	UIView *_contentViewInfo;
	FLTextFieldSignup *_name;
	FLTextFieldSignup *_email;
	FLTextFieldSignup *_birthday;
	FLTextFieldSignup *_password;

	//SIGNUP CODE
	NSString *currentValue;
	CodePinView *_codePinView;
	SecureCodeMode currentSecureMode;

	//SIGNUP ASK ACCESS
	UILabel *_askMessage;
	UIImageView *_askImage;
	BOOL _accessContact;

	//SIGNUP INVITATION
	UITableView *_tableView;
	UIView *_footerView;
	UIButton *inviteButton;
	NSMutableArray *_contactInfoArray;
	NSMutableArray *_contactToInvite;
	NSMutableArray *_contactFromFlooz;

	BOOL hasFocus;
}

@end

@implementation SignupViewController

- (void)loadView {
	[super loadView];
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	CGRect frame    = [[UIScreen mainScreen] bounds];
	self.view.frame = frame;
	self.view.backgroundColor = [UIColor customBackgroundHeader];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	hasFocus = NO;
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
	[_nextButton setEnabled:NO];
	[_nextButton setBackgroundColor:[UIColor customBackground]];
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

#pragma mark - PREPARATION VIEWS

- (void)displayChanges {
	switch (_pageIndex) {
		case SignupPagePhone: {
			[self testPhoneNumber];
		}
		break;

		case SignupPagePhoto: {
			[_nextButton setEnabled:YES];

			if (_userDic[@"avatarURL"] && ![_userDic[@"avatarURL"] isBlank]) {
				if (!_userDic[@"picId"] || [_userDic[@"picId"] isEqual:[NSData new]]) {
					[_avatarView setImageFromURL:_userDic[@"avatarURL"]];
				}
			}
		}
		break;

		case SignupPageInfo: {
			[_email reloadTextField];
			[_birthday reloadTextField];
			[self canValidate:_email];
		}
		break;

		case SignupPagePseudo: {
			[_userName reloadTextField];
			[self canValidate:_userName];
		}
		break;

		case SignupPageCode: {
			[_userDic setValue:@"" forKey:@"secureCode"];
			[_codePinView clean];
		}
		break;

		case SignupPageCodeVerif: {
			[_codePinView clean];
		}
		break;

		case SignupPageCB: {
			if (_userDic[@"firstName"] && _userDic[@"lastName"]) {
				NSString *holder = [NSString stringWithFormat:@"%@ %@", _userDic[@"firstName"], _userDic[@"lastName"]];
				[_userDic setObject:holder forKey:@"holder"];
				[fieldsView[0] reloadData];
			}
		}
		break;

		case SignupPageAskAccess: {
			[self registerNotification:@selector(reloadAccessView) name:kNotificationAnswerAccessNotification object:nil];
			[_nextButton setEnabled:YES];
			[_nextButton setBackgroundColor:[UIColor customBlue]];
		}
		break;

		case SignupPageFriends: {
			[_nextButton setEnabled:YES];
			[_nextButton setBackgroundColor:[UIColor customBlue]];
		}
		break;

		default:
			break;
	}
}

- (void)setContent {
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

		case SignupPagePhoto: {
			[self signupPhotoView];
		}
		break;

		case SignupPageInfo: {
			[self signupInfoView];
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

		case SignupPageAskAccess: {
			[self signupAskAccessToFriends];
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
	_headerView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT + 16, PPScreenWidth(), 60.0f)];
	if (IS_IPHONE4) {
		CGRectSetHeight(_headerView.frame, 50.0f);
	}
	[self.view addSubview:_headerView];

	{
		_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_headerView.frame), CGRectGetHeight(_headerView.frame))];
		_title.font = [UIFont customTitleNav];
		_title.textColor = [UIColor customBlue];
		_title.numberOfLines = 0;
		_title.textAlignment = NSTextAlignmentCenter;
		[_headerView addSubview:_title];
	}
	{
		_backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 2, 30, CGRectGetHeight(_headerView.frame))];
		[_backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
		[_backButton addTarget:self action:@selector(goToPreviousPage) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_backButton];
	}

	_mainBody = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.frame), PPScreenWidth(), PPScreenHeight() - CGRectGetMaxY(_headerView.frame))];
	[self.view addSubview:_mainBody];

	//    [self createValidButton];
	[self createNextButton];
}

- (void)displayHeader {
	[self.view setBackgroundColor:[UIColor customBackgroundHeader]];

	CGRectSetY(_headerView.frame, STATUSBAR_HEIGHT);
	CGRectSetHeight(_headerView.frame, CGRectGetMaxY(_title.frame) + 5.0f);

	CGRectSetY(_mainBody.frame, CGRectGetMaxY(_headerView.frame));
	CGRectSetHeight(_mainBody.frame, PPScreenHeight() - CGRectGetMaxY(_headerView.frame));

	firstItemY = 25.0f / ratioiPhones;
}

- (UIButton *)ignoreButtonWithText:(NSString *)text superV:(UIView *)superV {
	UIButton *ignoreButton  = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(superV.frame) - 40 - 5, CGRectGetWidth(superV.frame), 40)];
	[ignoreButton setTitle:text forState:UIControlStateNormal];
	[ignoreButton setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
	[ignoreButton setTitleColor:[UIColor customBlueLight] forState:UIControlStateHighlighted];
	[ignoreButton.titleLabel setFont:[UIFont customTitleExtraLight:18]];
	[ignoreButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
	[superV addSubview:ignoreButton];
	return ignoreButton;
}

#pragma mark - FOCUS

- (void)focus {
	switch (_pageIndex) {
		case SignupPagePhone: {
            if (_pageIndexStart > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    SignupViewController *strongSelf = self;
                    [strongSelf.phoneField becomeFirstResponder];
                });
            }
            else {
                if (hasFocus) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        SignupViewController *strongSelf = self;
                        [strongSelf.phoneField becomeFirstResponder];
                    });
                }
                else {
                    hasFocus = YES;
                }
            }
		}
		break;

		case SignupPageInfo: {
			/*
			   if(_userDic[@"avatarURL"]){
			   [self focusOnSecond];
			   }
			   else {
			   [self focusOnFirst];
			   }
			 */
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
	    SignupViewController *strongSelf = self;
	    [strongSelf.firstTextFieldToFocus becomeFirstResponder];
	});
}

- (void)focusOnSecond {
	dispatch_async(dispatch_get_main_queue(), ^{
	    SignupViewController *strongSelf = self;
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
		expectedSize = [label.text sizeWithAttributes:@{ NSFontAttributeName: label.font }];
	}
	else if ([view isKindOfClass:[UIButton class]]) {
		UIButton *button = (UIButton *)view;
		expectedSize = [button.titleLabel.text sizeWithAttributes:@{ NSFontAttributeName: button.titleLabel.font }];
	}
	return expectedSize;
}

- (void)displayCGU {
	WebViewController *controller = [WebViewController new];
	[controller setUrl:@"https://www.flooz.me/cgu?layout=webview"];
	controller.title = NSLocalizedString(@"INFORMATIONS_TERMS", nil);
	UINavigationController *controller2 = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentViewController:controller2 animated:YES completion:NULL];
}

#pragma mark - CALLS to Delegate Methods
- (void)goToNextPage {
	if ([self.delegate respondsToSelector:@selector(goToNextPage:withUser:)]) {
		[self.delegate goToNextPage:_pageIndex withUser:_userDic];
	}
}

- (void)goToPreviousPage {
	if ([self.delegate respondsToSelector:@selector(goToPreviousPage:withUser:)]) {
		[self.delegate goToPreviousPage:_pageIndex withUser:_userDic];
	}
}

#pragma mark - VALIDATION SECTION

- (void)canValidate:(FLTextFieldSignup *)textIcon {
	BOOL canValidate = NO;
	if ([textIcon isEqual:_userName]) {
		if (_userDic[@"nick"] && ((NSString *)_userDic[@"nick"]).length >= 3) {
			canValidate = YES;
		}
	}
	else if ([textIcon isEqual:_name] || [textIcon isEqual:_email] || [textIcon isEqual:_password] || [textIcon isEqual:_birthday]) {
		if ((_userDic[@"firstName"] && ![_userDic[@"firstName"] isBlank])
		    && (_userDic[@"lastName"] && ![_userDic[@"lastName"] isBlank])
		    && (_userDic[@"password"] && [_userDic[@"password"] length] >= 6)
		    && (_userDic[@"birthdate"] && ([_userDic[@"birthdate"] length] == 12 || [_userDic[@"birthdate"] length] == 14))
		    && (_userDic[@"email"] && ![_userDic[@"email"] isBlank])) {
			canValidate = YES;
		}
	}

	if (canValidate) {
		[_nextButton setEnabled:YES];
		[_nextButton setBackgroundColor:[UIColor customBlue]];
	}
	else {
		[_nextButton setEnabled:NO];
		[_nextButton setBackgroundColor:[UIColor customBackground]];
	}
}

- (void)createNextButton {
	_nextButton = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, 34)];

	[_nextButton setTitle:NSLocalizedString(@"SIGNUP_NEXT_BUTTON", nil) forState:UIControlStateNormal];
	[_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_nextButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
	[_nextButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];

	[_nextButton setEnabled:NO];
	[_nextButton setBackgroundColor:[UIColor customBackground]];
}

/**
 *  SIGNUP_TUTO_EXPLICATION_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_TUTO_EXPLICATION **********

- (void)signupPageTuto {
	//[_backButton setHidden:YES];
	_title.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE", @"");

	UIView *item1 = [self placePictoAndText:@"picto_accueil_collect_money" title:@"SIGNUP_VIEW_1_TITLE_1" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_1" underView:nil];
	UIView *item2 = [self placePictoAndText:@"picto_accueil_secure" title:@"SIGNUP_VIEW_1_TITLE_2" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_2" underView:item1];
	[self placePictoAndText:@"picto_accueil_friends" title:@"SIGNUP_VIEW_1_TITLE_3" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_3" underView:item2];
	[self nextButtonWithText:NSLocalizedString(@"SIGNUP_VIEW_1_BUTTON", @"") andWidth:180];
}

- (void)signupPageExplication {
	_title.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE_2", @"");

	UIView *item1 = [self placePictoAndText:@"picto_accueil_time" title:@"SIGNUP_VIEW_2_TITLE_1" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_1" underView:nil];
	UIView *item2 = [self placePictoAndText:@"picto_accueil_credit_card" title:@"SIGNUP_VIEW_2_TITLE_2" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_2" underView:item1];
	[self placePictoAndText:@"picto_accueil_share" title:@"SIGNUP_VIEW_2_TITLE_3" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_3" underView:item2];
	[self nextButtonWithText:NSLocalizedString(@"SIGNUP_VIEW_2_BUTTON", @"") andWidth:220];
}

- (UIView *)placePictoAndText:(NSString *)pictoName title:(NSString *)title subTitle:(NSString *)subTitle underView:(UIView *)view {
	FLStartItem *item = [FLStartItem newWithTitle:@"" imageImageName:pictoName contentText:@"coucou" andSize:sizePicto];
	[item setSize:CGSizeMake(sizePicto, sizePicto)];
	if (!view)
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
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

- (void)signupPhoneView {
	_title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Phone", @"");
	[self displayHeader];

	{
		_phoneField = [[FLHomeTextField alloc] initWithPlaceholder:NSLocalizedString(@"NumMobile", @"") for:_userDic key:@"phone" position:CGPointMake(PADDING_SIDE, 200)];
		CGRectSetXY(_phoneField.frame, (SCREEN_WIDTH - _phoneField.frame.size.width) / 2., CGRectGetMaxY(logo.frame) + 35);
		if (IS_IPHONE4) {
			CGRectSetXY(_phoneField.frame, (SCREEN_WIDTH - _phoneField.frame.size.width) / 2., CGRectGetMaxY(logo.frame) + 5);
		}
		[_phoneField addForNextClickTarget:self action:@selector(testPhoneNumber)];
		[_mainBody addSubview:_phoneField];

		inputView = [FLKeyboardView new];
		[inputView noneCloseButton];
		inputView.textField = _phoneField.textfield;
		_phoneField.textfield.inputView = inputView;
	}

	{
		[_nextButton addTarget:self action:@selector(tryPhoneNumber) forControlEvents:UIControlEventTouchUpInside];
		CGRectSetY(_nextButton.frame, CGRectGetMaxY(_phoneField.frame) + 10.0f);
		[_mainBody addSubview:_nextButton];
	}

	{
		UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_nextButton.frame), PPScreenWidth() - 30, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_nextButton.frame) - 250)];
		firstTimeText.textColor = [UIColor customGrey];
		firstTimeText.font = [UIFont customTitleExtraLight:14];
		firstTimeText.numberOfLines = 0;
		firstTimeText.textAlignment = NSTextAlignmentCenter;
		firstTimeText.text = NSLocalizedString(@"SIGNUP_PAGE_PHONE_MESSAGE", nil);
		if (_pageIndexStart > 0) {
			[_mainBody addSubview:firstTimeText];
		}
        if (IS_IPHONE4) {
            CGRectSetHeight(firstTimeText.frame, 50);
        }
	}
}

- (void)testPhoneNumber {
	if (_userDic[@"phone"] && ![_userDic[@"phone"] isBlank] && ((NSString *)_userDic[@"phone"]).length >= 10) {
		[_nextButton setEnabled:YES];
		[_nextButton setBackgroundColor:[UIColor customBlue]];
	}
	else {
        [_phoneField.textfield becomeFirstResponder];
		[_nextButton setEnabled:NO];
		[_nextButton setBackgroundColor:[UIColor customBackground]];
	}
}

- (void)tryPhoneNumber {
	[self.view endEditing:YES];
	if (_userDic[@"phone"] && ![_userDic[@"phone"] isBlank] && ((NSString *)_userDic[@"phone"]).length >= 10) {
		[_nextButton setEnabled:YES];
		[_nextButton setBackgroundColor:[UIColor customBlue]];

        if (_pageIndexStart > 0) {
            UIAlertView *alertConfirmPhone = [[UIAlertView alloc] initWithTitle:@"Confirmation du numéro" message:[NSString stringWithFormat:@"\nVous allez recevoir un SMS de confirmation. Veuillez confirmer que le %@ est bien votre n° de mobile.", [[Flooz sharedInstance] clearPhoneNumber:_userDic[@"phone"]]] delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_EDIT", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_OK", nil), nil];
            alertConfirmPhone.tag = 42;
            [alertConfirmPhone show];
        }
        else {
            [[Flooz sharedInstance] showLoadView];
            [appDelegate clearSavedViewController];
            [[Flooz sharedInstance] loginWithPhone:_userDic[@"phone"]];
        }
	}
	else {
        [_phoneField.textfield becomeFirstResponder];
		[_nextButton setEnabled:NO];
		[_nextButton setBackgroundColor:[UIColor customBackground]];
	}
}

/**
 *  SIGNUP_PSEUDO_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_PSEUDO **********

- (void)signupPseudoView {
	_title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Pseudo", @"");
	[self displayHeader];
	{
		_userName = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_USERNAME" for:_userDic key:@"nick" position:CGPointMake(PADDING_SIDE, firstItemY)];

		[_userName addForNextClickTarget:self action:@selector(checkPseudo)];
		[_userName addForTextChangeTarget:self action:@selector(canValidate:)];
		_firstTextFieldToFocus = _userName;
		[_mainBody addSubview:_userName];
	}

	{
		[_nextButton addTarget:self action:@selector(checkPseudo) forControlEvents:UIControlEventTouchUpInside];
		CGRectSetY(_nextButton.frame, CGRectGetMaxY(_userName.frame) + 5);
		[_mainBody addSubview:_nextButton];
	}

	{
		UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_nextButton.frame), PPScreenWidth() - 30, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_nextButton.frame) - 216)];
		firstTimeText.textColor = [UIColor whiteColor];
		firstTimeText.font = [UIFont customTitleExtraLight:14];
		firstTimeText.numberOfLines = 0;
		firstTimeText.textAlignment = NSTextAlignmentCenter;
		firstTimeText.text = NSLocalizedString(@"SIGNUP_PSEUDO_EXPLICATION", nil);
		[_mainBody addSubview:firstTimeText];
	}
}

- (void)checkPseudo {
	if (_userDic[@"nick"] && ((NSString *)_userDic[@"nick"]).length >= 3) {
		[_nextButton setEnabled:YES];
		[_nextButton setBackgroundColor:[UIColor customBlue]];
		[[Flooz sharedInstance] showLoadView];
		[[Flooz sharedInstance] verifyPseudo:_userDic[@"nick"] success: ^(id result) {
		    [self goToNextPage];
		} failure: ^(NSError *error) {
		    [_firstTextFieldToFocus becomeFirstResponder];
		}];
	}
}

/**
 *  SIGNUP_PHOTO_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_PHOTO **********
- (void)signupPhotoView {
	_title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Photo", @"");
	[self displayHeader];

	{
		_avatarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 100.0f)];
		[_avatarButton setBackgroundColor:[UIColor customBackgroundHeader]];
		[_avatarButton addTarget:self action:@selector(showImagePicker) forControlEvents:UIControlEventTouchUpInside];
		{
			CGFloat size = CGRectGetHeight(_avatarButton.frame) - 10.0f;
			_avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(((CGRectGetWidth(_avatarButton.frame) - size) / 2.0) - 5.0f, ((CGRectGetHeight(_avatarButton.frame) - size) / 2.0), size, size)];
			_avatarView.contentMode = UIViewContentModeScaleAspectFit;
			[_avatarButton addSubview:_avatarView];
		}
		[_mainBody addSubview:_avatarButton];
	}

	UILabel *firstTimeText;
	{
		firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(_avatarButton.frame), PPScreenWidth() - PADDING_SIDE * 2, 80)];
		firstTimeText.textColor = [UIColor whiteColor];
		firstTimeText.font = [UIFont customTitleExtraLight:14];
		firstTimeText.numberOfLines = 0;
		firstTimeText.textAlignment = NSTextAlignmentCenter;
		firstTimeText.text = NSLocalizedString(@"SIGNUP_PHOTO_EXPLICATION", nil);
		[_mainBody addSubview:firstTimeText];
	}

	{
		[self createFacebookButton];
		[_mainBody addSubview:_registerFacebook];
		CGRectSetY(_registerFacebook.frame, CGRectGetMaxY(firstTimeText.frame) + 5.0f);
	}

	UIButton *captureButton;
	{
		captureButton = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(_registerFacebook.frame) + 7.0f, PPScreenWidth() - PADDING_SIDE * 2, 34)];

		[captureButton setTitle:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil) forState:UIControlStateNormal];
		[captureButton.titleLabel setFont:[UIFont customTitleExtraLight:15]];
		[captureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[captureButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
		[captureButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];

		UIImageView *image = [UIImageView imageNamed:@"bar-camera"];
		[captureButton addSubview:image];
		CGRectSetWidth(image.frame, 20.0f);
		CGRectSetHeight(image.frame, 20.0f);
		CGRectSetY(image.frame, (CGRectGetHeight(captureButton.frame) - CGRectGetHeight(image.frame)) / 2.0f);
		CGRectSetX(image.frame, 10.0f);
		[image setContentScaleFactor:UIViewContentModeScaleAspectFit];

		[captureButton addTarget:self action:@selector(presentPhoto) forControlEvents:UIControlEventTouchUpInside];
		[captureButton setBackgroundColor:[UIColor customBackground]];
		[_mainBody addSubview:captureButton];
	}

	UIButton *albumButton;
	{
		albumButton = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(captureButton.frame) + 7.0f, PPScreenWidth() - PADDING_SIDE * 2, 34)];

		[albumButton setTitle:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil) forState:UIControlStateNormal];
		[albumButton.titleLabel setFont:[UIFont customTitleExtraLight:15]];
		[albumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[albumButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
		[albumButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];

		UIImageView *image = [UIImageView imageNamed:@"camera-album"];
		[albumButton addSubview:image];
		CGRectSetWidth(image.frame, 20.0f);
		CGRectSetHeight(image.frame, 18.0f);
		CGRectSetY(image.frame, (CGRectGetHeight(albumButton.frame) - CGRectGetHeight(image.frame)) / 2.0f);
		CGRectSetX(image.frame, 10.0f);
		[image setContentScaleFactor:UIViewContentModeScaleAspectFit];

		[albumButton addTarget:self action:@selector(presentLibrary) forControlEvents:UIControlEventTouchUpInside];
		[albumButton setBackgroundColor:[UIColor customBackground]];
		[_mainBody addSubview:albumButton];
	}

	{
		CGRectSetY(_nextButton.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(_nextButton.frame) - 20.0f);
		[_nextButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
		[_nextButton setBackgroundColor:[UIColor customBackground]];
		[_mainBody addSubview:_nextButton];
	}
}

- (void)createFacebookButton {
	_registerFacebook = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, 34)];
	[_registerFacebook setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithIntegerRed:59 green:87 blue:157 alpha:.5]] forState:UIControlStateNormal];
	[_registerFacebook setTitle:NSLocalizedString(@"LOGIN_FACEBOOK", nil) forState:UIControlStateNormal];
	_registerFacebook.titleLabel.font = [UIFont customTitleExtraLight:15];

	UIImageView *image = [UIImageView imageNamed:@"facebook"];
	[_registerFacebook addSubview:image];
	CGRectSetWidth(image.frame, 16.0f);
	CGRectSetHeight(image.frame, 16.0f);
	CGRectSetY(image.frame, (CGRectGetHeight(_registerFacebook.frame) - CGRectGetHeight(image.frame)) / 2.0f);
	CGRectSetX(image.frame, 12.0f);
	[image setContentScaleFactor:UIViewContentModeScaleAspectFit];

	//    [_registerFacebook setImageEdgeInsets:UIEdgeInsetsMake(-1, 10, 0, -10)];
	[_registerFacebook addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didFacebookTouch {
	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] getInfoFromFacebook];
}

#pragma mark - imagePicker

- (void)showImagePicker {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        [self createActionSheet];
    }
    else {
        [self createAlertController];
    }
}

- (void)createAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CAMERA", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self displayImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
        }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_ALBUMS", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self displayImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
        }]];
    }
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [menus addObject:NSLocalizedString(@"GLOBAL_CAMERA", nil)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [menus addObject:NSLocalizedString(@"GLOBAL_ALBUMS", nil)];
    }
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"GLOBAL_CAMERA", nil)]) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"GLOBAL_ALBUMS", nil)]) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)displayImagePickerWithType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    cameraUI.sourceType = type;
    cameraUI.delegate = self;
    cameraUI.allowsEditing = YES;
    [self presentViewController:cameraUI animated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)presentPhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypeCamera];
    }
}

- (void)presentLibrary {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [self displayImagePickerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (UIImage *)resizeImage:(UIImage *)image {
	CGRect rect = CGRectMake(0.0, 0.0, 640.0, 640.0); // 240.0 rather then 120.0 for retina
	UIGraphicsBeginImageContext(rect.size);
	[image drawInRect:rect];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return img;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];

    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage;
    
    if (editedImage)
        resizedImage = [editedImage resize:CGSizeMake(640, 0)];
    else
        resizedImage = [originalImage resize:CGSizeMake(640, 0)];

    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);

	[_avatarView setImageFromData:imageData];

	[_userDic setValue:imageData forKey:@"picId"];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  SIGNUP_INFO_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_INFO **********

- (void)signupInfoView {
	_title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Info", @"");
	[self displayHeader];

	{
		_contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
		[_mainBody addSubview:_contentView];
	}

	_contentViewInfo = [UIView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
	[_contentView addSubview:_contentViewInfo];

	{
		_name = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_FIRSTNAME" for:_userDic key:@"firstName" position:CGPointMake(PADDING_SIDE, 0.0f) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
		[_name addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_name addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentViewInfo addSubview:_name];
	}
	{
		_email = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_EMAIL" for:_userDic key:@"email" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_name.frame) + 3.0f / ratioiPhones)];
		[_email addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_email addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentViewInfo addSubview:_email];
	}
	{
		_birthday = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_BIRTHDAY" for:_userDic key:@"birthdate" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_email.frame) + 3.0f / ratioiPhones)];
		[_birthday addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_birthday addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentViewInfo addSubview:_birthday];

		inputView = [FLKeyboardView new];
		inputView.textField = _birthday.textfield;
		_birthday.textfield.inputView = inputView;
	}
	{
		_password = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_PASSWORD" for:_userDic key:@"password" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_birthday.frame) + 3.0f / ratioiPhones)];
		[_password seTsecureTextEntry:YES];
		[_password addForNextClickTarget:self action:@selector(focusOnNextInfo)];
		[_password addForTextChangeTarget:self action:@selector(canValidate:)];
		[_contentViewInfo addSubview:_password];
	}

	{
		TTTAttributedLabel *tttLabel = [TTTAttributedLabel newWithFrame:CGRectMake(10, CGRectGetHeight(_contentView.frame) - 45.0f, PPScreenWidth() - 20, 45)];
		{
			NSString *labelText = NSLocalizedString(@"SIGNUP_READ_CGU", @"");
			[tttLabel setNumberOfLines:0];
			[tttLabel setLineBreakMode:NSLineBreakByWordWrapping];
			[tttLabel setTextAlignment:NSTextAlignmentCenter];
			[tttLabel setTextColor:[UIColor customPlaceholder]];
			[tttLabel setFont:[UIFont customTitleExtraLight:13]];
			NSRange CGURange = [labelText rangeOfString:@"conditions générales d'utilisation"];
			[tttLabel setText:labelText afterInheritingLabelAttributesAndConfiguringWithBlock: ^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
			    if (CGURange.location != NSNotFound) {
			        [mutableAttributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)@1 range:CGURange];
				}
			    return mutableAttributedString;
			}];
			[tttLabel sizeToFit];
			[tttLabel setLinkAttributes:@{ NSForegroundColorAttributeName : [UIColor customPlaceholder] }];
			[tttLabel addLinkToURL:[NSURL URLWithString:@"action://show-CGU"] withRange:CGURange];
			[tttLabel setDelegate:self];
			[_contentView addSubview:tttLabel];

			_contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(tttLabel.frame));
		}
	}

	{
		[_nextButton addTarget:self action:@selector(checkEmail) forControlEvents:UIControlEventTouchUpInside];
		CGRectSetY(_nextButton.frame, CGRectGetMaxY(_password.frame) + 15.0f);
		[_contentViewInfo addSubview:_nextButton];
	}

	[self addTapGestureForDismissKeyboard];
}

- (void)focusOnNextInfo {
	if ([_name isFirstResponder]) {
		[self canValidate:_name];
		[_name resignFirstResponder];
		[_email becomeFirstResponder];
	}
	else if ([_email isFirstResponder]) {
		[self canValidate:_email];
		[_email resignFirstResponder];
		[_birthday becomeFirstResponder];
	}
	else if ([_birthday isFirstResponder]) {
		[self canValidate:_birthday];
		[_birthday resignFirstResponder];
		[_password becomeFirstResponder];
	}
	else if ([_password isFirstResponder]) {
		[self canValidate:_password];
		[_password resignFirstResponder];
	}
	else {
		[self checkEmail];
	}
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
	if ([[url scheme] hasPrefix:@"action"]) {
		if ([[url host] hasPrefix:@"show-CGU"]) {
			[self displayCGU];
		}
	}
}

- (void)checkEmail {
	if (!_userDic[@"lastName"] || !_userDic[@"firstName"] || [_userDic[@"lastName"] isBlank] || [_userDic[@"firstName"] isBlank]) {
		[_name becomeFirstResponder];
		return;
	}
	if (!_userDic[@"email"] || [_userDic[@"email"] isBlank]) {
		[_email becomeFirstResponder];
		return;
	}
	if (!_userDic[@"birthdate"] || !([_userDic[@"birthdate"] length] == 12 || [_userDic[@"birthdate"] length] == 14)) {
		[_birthday becomeFirstResponder];
		return;
	}
	if (!_userDic[@"password"] || [_userDic[@"password"] length] < 6) {
		[_password becomeFirstResponder];
		return;
	}
	if (_userDic[@"email"] && ![_userDic[@"email"] isBlank]) {
		[_nextButton setEnabled:YES];
		[_nextButton setBackgroundColor:[UIColor customBlue]];

		[[Flooz sharedInstance] showLoadView];
		[[Flooz sharedInstance] checkSignup:_userDic success: ^(id result) {
		    [self goToNextPage];
		} failure: ^(NSError *error) {
		    [_email becomeFirstResponder];
		}];
	}
	else {
		[_email becomeFirstResponder];
	}
}

- (BOOL)validateEmail:(NSString *)candidate {
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

- (void)addTapGestureForDismissKeyboard {
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
	tapGesture.cancelsTouchesInView = NO;
	[_mainBody addGestureRecognizer:tapGesture];
	[_contentView addGestureRecognizer:tapGesture];
	[_headerView addGestureRecognizer:tapGesture];
	[_contentViewInfo addGestureRecognizer:tapGesture];
	[self registerForKeyboardNotifications];
}

/**
 *  SIGNUP_Code_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_CODE **********

- (void)signupCodeView {
	CGRectSetY(_mainBody.frame, STATUSBAR_HEIGHT);
	CGRectSetHeight(_mainBody.frame, PPScreenHeight() - STATUSBAR_HEIGHT);
	[_mainBody addSubview:_backButton];

	FLKeyboardView *keyboardView = [FLKeyboardView new];
	[keyboardView noneCloseButton];
	CGRectSetY(keyboardView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame));

	{
		_mainContent = [UIView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 0)];
	}

	UILabel *firstTimeText;
	{
		firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 50)];
		firstTimeText.textColor = [UIColor customGrey];
		firstTimeText.font = [UIFont customTitleLight:18];
		firstTimeText.numberOfLines = 0;
		firstTimeText.textAlignment = NSTextAlignmentCenter;
		firstTimeText.text = NSLocalizedString(@"SECORE_CODE_TEXT_SIGNUP_NEW", nil);
		CGSize s = [self sizeExpectedForView:firstTimeText];
		CGRectSetHeight(firstTimeText.frame, s.height * 2);

		[_mainContent addSubview:firstTimeText];
	}

	{
		_codePinView = [[CodePinView alloc] initWithNumberOfDigit:numberOfDigit andFrame:CGRectMake(PPScreenWidth() / 4.0f, CGRectGetMaxY(firstTimeText.frame) + 5.0f, PPScreenWidth() / 2.0f, 40.0f)];
		_codePinView.delegate = self;
		[_mainContent addSubview:_codePinView];
		currentSecureMode = SecureCodeModeChangeNew;

		keyboardView.delegate = _codePinView;
		[_mainBody addSubview:keyboardView];
	}

	CGRectSetHeight(_mainContent.frame, CGRectGetMaxY(_codePinView.frame));
	[_mainContent setCenter:CGPointMake(PPScreenWidth() / 2, (CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame)) / 2)];
	[_mainBody addSubview:_mainContent];
}

- (void)signupCodeVerifView {
	CGRectSetY(_mainBody.frame, STATUSBAR_HEIGHT);
	CGRectSetHeight(_mainBody.frame, PPScreenHeight() - STATUSBAR_HEIGHT);
	[_mainBody addSubview:_backButton];

	FLKeyboardView *keyboardView = [FLKeyboardView new];
	[keyboardView noneCloseButton];
	CGRectSetY(keyboardView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame));

	{
		_mainContent = [UIView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 0)];
	}

	UILabel *firstTimeText;
	{
		firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 50)];
		firstTimeText.textColor = [UIColor customGrey];
		firstTimeText.font = [UIFont customTitleLight:18];
		firstTimeText.numberOfLines = 0;
		firstTimeText.textAlignment = NSTextAlignmentCenter;
		firstTimeText.text = NSLocalizedString(@"SECORE_CODE_TEXT_SIGNUP_CONFIRM", nil);
		CGSize s = [self sizeExpectedForView:firstTimeText];
		CGRectSetHeight(firstTimeText.frame, s.height * 2);

		[_mainContent addSubview:firstTimeText];
	}

	{
		_codePinView = [[CodePinView alloc] initWithNumberOfDigit:numberOfDigit andFrame:CGRectMake(PPScreenWidth() / 4.0f, CGRectGetMaxY(firstTimeText.frame) + 5.0f, PPScreenWidth() / 2.0f, 40.0f)];
		_codePinView.delegate = self;
		[_mainContent addSubview:_codePinView];
		currentSecureMode = SecureCodeModeChangeConfirm;

		keyboardView.delegate = _codePinView;
		[_mainBody addSubview:keyboardView];
	}

	CGRectSetHeight(_mainContent.frame, CGRectGetMaxY(_codePinView.frame));
	[_mainContent setCenter:CGPointMake(PPScreenWidth() / 2, (CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(keyboardView.frame)) / 2)];
	[_mainBody addSubview:_mainContent];
}

- (NSString *)keyForSecureCode {
	return [NSString stringWithFormat:@"secureCode-%@", [[[Flooz sharedInstance] currentUser] userId]];
}

- (void)pinEnd:(NSString *)pin {
	if (currentSecureMode == SecureCodeModeChangeNew) {
		[_userDic setValue:pin forKey:@"secureCode"];
		[self goToNextPage];
	}
	else if (currentSecureMode == SecureCodeModeChangeConfirm) {
		if ([_userDic[@"secureCode"] isEqualToString:pin]) {
			[[Flooz sharedInstance] showLoadView];

			NSString *deviceToken = [appDelegate currentDeviceToken];
			if (deviceToken) {
				[_userDic setValue:deviceToken forKeyPath:@"device"];
			}
			NSData *dataPic = _userDic[@"picId"];
            
            if (dataPic && [dataPic length] > 0)
                _userDic[@"hasImage"] = @YES;
            
			[_userDic removeObjectForKey:@"picId"];

			__block NSData *weakPic = dataPic;
			[[Flooz sharedInstance] signup:_userDic success: ^(id result) {
			    [[Flooz sharedInstance] hideLoadView];
			    [UICKeyChainStore setString:pin forKey:[self keyForSecureCode]];

			    if (weakPic && ![weakPic isEqual:[NSData new]]) {
			        [[Flooz sharedInstance] showLoadView];
			        [[Flooz sharedInstance] uploadDocument:weakPic field:@"picId" success:NULL failure:NULL];
				}
			    [self goToNextPage];
			} failure: ^(NSError *error) {
			    [self goToPreviousPage];
			}];
		}
		else {
			[_codePinView animationBadPin];
			[_codePinView clean];
		}
	}
}

/**
 *  SIGNUP_CB_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_CARTE_BANCAIRE **********

- (void)signupCBView {
	[_backButton setHidden:YES];
	_title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_CB", @"");
	[self displayHeader];

	[_nextButton addTarget:self action:@selector(didValidTouch2) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_nextButton];

	_contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
	[_mainBody addSubview:_contentView];


	FLTextFieldTitle2 *ownerField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_OWNER_PLACEHOLDER" for:_userDic key:@"holder" position:CGPointMake(PADDING_SIDE, -2.0f)];
	[ownerField addForNextClickTarget:self action:@selector(didOwnerEndEditing)];
	[_contentView addSubview:ownerField];
	[fieldsView addObject:ownerField];


	FLTextFieldTitle2 *cardNumberField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_NUMBER_PLACEHOLDER" for:_userDic key:@"number" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(ownerField.frame) - 2.0f)];
	[cardNumberField setKeyboardType:UIKeyboardTypeDecimalPad];
	[cardNumberField setStyle:FLTextFieldTitle2StyleCardNumber];
	[cardNumberField addForNextClickTarget:self action:@selector(didNumberEndEditing)];
	[_contentView addSubview:cardNumberField];
	[fieldsView addObject:cardNumberField];
	{
		FLKeyboardView *inputViewField = [FLKeyboardView new];
		inputViewField.textField = cardNumberField.textfield;
		cardNumberField.textfield.inputView = inputViewField;
	}
	{
		UIImage *photo = [UIImage imageNamed:@"bar-camera"];
		UIButton *scanCardButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(cardNumberField.frame) - 50.0f, 0.0f, 50.0f, CGRectGetHeight(cardNumberField.frame))];
		[scanCardButton setImage:photo forState:UIControlStateNormal];

		CGSize size = photo.size;
		[scanCardButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, -size.height + 10.0f, -size.width)];

		[scanCardButton addTarget:self action:@selector(presentScanPayViewController) forControlEvents:UIControlEventTouchUpInside];
		if (!IS_IPHONE4) {
			//Not working with iphone 4
			[cardNumberField addSubview:scanCardButton];
		}
	}

	FLTextFieldTitle2 *expireField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_EXPIRES_PLACEHOLDER" for:_userDic key:@"expires" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(cardNumberField.frame) - 2.0f)];
	[expireField setKeyboardType:UIKeyboardTypeDecimalPad];
	[expireField setStyle:FLTextFieldTitle2StyleCardExpire];
	[expireField addForNextClickTarget:self action:@selector(didExpiresEndEditing)];
	[_contentView addSubview:expireField];
	[fieldsView addObject:expireField];
	{
		FLKeyboardView *inputViewField = [FLKeyboardView new];
		inputViewField.textField = expireField.textfield;
		expireField.textfield.inputView = inputViewField;
	}

	FLTextFieldTitle2 *cvvField = [[FLTextFieldTitle2 alloc] initWithTitle:@"" placeholder:@"SIGNUP_FIELD_CARD_CVV_PLACEHOLDER" for:_userDic key:@"cvv" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(expireField.frame) - 2.0f)];
	[cvvField setKeyboardType:UIKeyboardTypeDecimalPad];
	[cvvField setStyle:FLTextFieldTitle2StyleCVV];
	[cvvField addForNextClickTarget:self action:@selector(didCVVEndEditing)];
	[_contentView addSubview:cvvField];
	[fieldsView addObject:cvvField];
	{
		FLKeyboardView *inputViewField = [FLKeyboardView new];
		inputViewField.textField = cvvField.textfield;
		cvvField.textfield.inputView = inputViewField;
	}

	[_contentView addSubview:_nextButton];
	CGRectSetY(_nextButton.frame, CGRectGetMaxY(cvvField.frame) + 10.0f);
	[_nextButton setTitle:NSLocalizedString(@"SIGNUP_NEXT_BUTTON_ADD", @"") forState:UIControlStateNormal];

	{
		UIButton *ignoreButton = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(cvvField.frame) + 10.0f, PPScreenWidth() / 2.0f - PADDING_SIDE * 2, 34)];
		[ignoreButton setTitle:NSLocalizedString(@"SIGNUP_VIEW_IGNORE_BUTTON", @"") forState:UIControlStateNormal];
		[ignoreButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
		[ignoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];

		[ignoreButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
		[ignoreButton setBackgroundColor:[UIColor customBackground]];

		[_contentView addSubview:ignoreButton];

		CGRectSetWidth(_nextButton.frame, PPScreenWidth() / 2.0f - PADDING_SIDE * 2);
		CGRectSetX(_nextButton.frame, CGRectGetMaxX(ignoreButton.frame) + PADDING_SIDE * 2);
	}

	_contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(_nextButton.frame) + 40);

	[self addTapGestureForDismissKeyboard];
}

- (void)didOwnerEndEditing {
	[fieldsView[1] becomeFirstResponder];
	[self verifAllFieldForCB];
}

- (void)didNumberEndEditing {
	[fieldsView[2] becomeFirstResponder];
	[self verifAllFieldForCB];
}

- (void)didExpiresEndEditing {
	[fieldsView[3] becomeFirstResponder];
	[self verifAllFieldForCB];
}

- (void)didCVVEndEditing {
	[[self view] endEditing:YES];
	[self verifAllFieldForCB];
}

- (BOOL)verifAllFieldForCB {
	BOOL verifOk = YES;
	if (!_userDic[@"number"] || !_userDic[@"cvv"] || !_userDic[@"expires"] || !_userDic[@"holder"] ||
	    [_userDic[@"number"] isBlank] || [_userDic[@"cvv"] isBlank] || [_userDic[@"expires"] isBlank] || [_userDic[@"holder"] isBlank]) {
		verifOk = NO;
		[_nextButton setEnabled:NO];
		[_nextButton setBackgroundColor:[UIColor customBackground]];
	}
	else {
		[_nextButton setEnabled:YES];
		[_nextButton setBackgroundColor:[UIColor customBlue]];
	}
	return verifOk;
}

- (void)didValidTouch2 {
	if ([self verifAllFieldForCB]) {
		[[self view] endEditing:YES];

		[[Flooz sharedInstance] showLoadView];
		[[Flooz sharedInstance] createCreditCard:_userDic atSignup:YES success: ^(id result) {
            if (![Secure3DViewController getInstance]) {
                [self goToNextPage];
            }
		}];
	}
}

#pragma mark - ScanPay

- (void)presentScanPayViewController {
	ScanPayViewController *scanPayViewController = [[ScanPayViewController alloc] initWithToken:@"be38035037ed6ca3cba7089b" useConfirmationView:YES useManualEntry:YES];

	[scanPayViewController startScannerWithViewController:self success: ^(SPCreditCard *card) {
	    [_userDic setValue:card.number forKey:@"number"];
	    [_userDic setValue:card.cvc forKey:@"cvv"];

	    NSString *expires = [NSString stringWithFormat:@"%@-%@", card.month, card.year];
	    [_userDic setValue:expires forKey:@"expires"];

	    for (FLTextFieldTitle2 * view in fieldsView) {
	        [view reloadData];
		}
	    [self verifAllFieldForCB];
	} cancel: ^{
	    [fieldsView[1] becomeFirstResponder];
	}];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
	[self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
	[self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;

	_contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0);
}

- (void)keyboardWillDisappear {
	_contentView.contentInset = UIEdgeInsetsZero;
}

- (void)hideKeyboard {
	[self.view endEditing:YES];
}

/**
 *  SIGNUP_ASK_ACCESS_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_ASK_ACCESS **********

- (void)signupAskAccessToFriends {
	[_backButton setHidden:YES];
	_title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Ask1", @"");
	[self displayHeader];

	{
		_askImage = [UIImageView newWithImageName:@"access-signup-notification"];
		CGRectSetX(_askImage.frame, CGRectGetWidth(_mainBody.frame) / 2 - CGRectGetWidth(_askImage.frame) / 2);
		CGRectSetY(_askImage.frame, CGRectGetHeight(_mainBody.frame) / 4.0f - CGRectGetHeight(_askImage.frame) / 2.0f);
		[_mainBody addSubview:_askImage];
	}
	{
		_askMessage = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE + 10.0f, CGRectGetHeight(_mainBody.frame) / 2.0f, PPScreenWidth() - (PADDING_SIDE + 10.0f) * 2.0f, 80)];
		_askMessage.textColor = [UIColor whiteColor];
		_askMessage.font = [UIFont customTitleExtraLight:16];
		_askMessage.numberOfLines = 0;
		_askMessage.textAlignment = NSTextAlignmentCenter;
		_askMessage.text = NSLocalizedString(@"SIGNUP_FRIENDS_MESSAGE1", nil);
		[_mainBody addSubview:_askMessage];
	}

	{
		CGRectSetY(_nextButton.frame, CGRectGetMaxY(_askMessage.frame) + 10.0f);
		[_nextButton addTarget:self action:@selector(askAccess) forControlEvents:UIControlEventTouchUpInside];
		[_mainBody addSubview:_nextButton];
	}
	_accessContact = NO;
}

- (void)askAccess {
	if (_accessContact) {
		[self askContacts];
	}
    else {
        [appDelegate askNotification];
	}
}

- (void)askContacts {
	[[Flooz sharedInstance] grantedAccessToContacts: ^(BOOL granted) {
	    if (!granted) {
	        _pageIndex++;
	        double delayInSeconds = 0.5;
	        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
	            [self goToNextPage];
			});
		}
	    else {
	        [[Flooz sharedInstance] createContactList: ^(NSMutableArray *arrayContactAdressBook, NSMutableArray *arrayContactFlooz) {
				
			} atSignup:YES];
            _pageIndex++;
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                [self goToNextPage];
            });
        }
	}];
}

- (void)reloadAccessView {
	UIImage *contactImage = [UIImage imageNamed:@"access-signup-contact"];
	[UIView animateWithDuration:0.3 animations: ^{
	    _title.alpha = 0.0f;
	    _askMessage.alpha = 0.0f;
	    _askImage.alpha = 0.0f;
	} completion: ^(BOOL finished) {
	    _title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Ask2", @"");
	    _askMessage.text = NSLocalizedString(@"SIGNUP_FRIENDS_MESSAGE2", nil);
	    [_askImage setImage:contactImage];

	    [UIView animateWithDuration:0.5 animations: ^{
	        _askImage.frame = CGRectMake(_askImage.frame.origin.x, _askImage.frame.origin.y,
	                                     contactImage.size.width, contactImage.size.height);
	        CGRectSetX(_askImage.frame, (CGRectGetWidth(_mainBody.frame) - CGRectGetWidth(_askImage.frame)) / 2.0f);
	        CGRectSetY(_askImage.frame, (CGRectGetHeight(_mainBody.frame) / 2.0f - CGRectGetHeight(_askImage.frame)) / 2.0f);
		}];

	    [UIView animateWithDuration:0.3 animations: ^{
	        _title.alpha = 1.0f;
	        _askMessage.alpha = 1.0f;
	        _askImage.alpha = 1.0f;
		} completion: ^(BOOL finished) {
	        _accessContact = YES;
		}];
	}];
}

/**
 *  SIGNUP_FRIENDS_VIEW
 *
 *
 */
#pragma mark - ********** SIGNUP_FRIENDS **********

- (void)signupFriendView {
	[_backButton setHidden:YES];
	_title.text = NSLocalizedString(@"SIGNUP_PAGE_TITLE_Friends", @"");
	[self displayHeader];

	[_nextButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_nextButton];
	[_nextButton setEnabled:YES];
	[_nextButton setBackgroundColor:[UIColor customBlue]];

	_contactInfoArray = [NSMutableArray new];
	_contactToInvite = [NSMutableArray new];
	_contactFromFlooz = [NSMutableArray new];

	[self createTableContactUnderView:nil];
	[self createFooter];

	[[Flooz sharedInstance] grantedAccessToContacts: ^(BOOL granted) {
	    if (granted) {
	        [self createContactList];
		}
	    else {
//	        [self displayAlertWithText:NSLocalizedString(@"ALERT_CONTACT_DENIES_ACCESS", @"")];
		}
	}];
}

- (void)createFooter {
	{
		[_nextButton addTarget:self action:@selector(askAccess) forControlEvents:UIControlEventTouchUpInside];
		[_nextButton setTitle:NSLocalizedString(@"SIGNUP_VIEW_IGNORE_BUTTON_2", @"") forState:UIControlStateNormal];
		[_mainBody addSubview:_nextButton];

		CGRectSetHeight(_tableView.frame, CGRectGetHeight(_tableView.frame) - 50.0f);
		CGRectSetY(_nextButton.frame, CGRectGetHeight(_tableView.frame) + 20.0f - CGRectGetHeight(_nextButton.frame) / 2.0f);
	}
	return;

	_footerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_mainBody.frame), CGRectGetWidth(_tableView.frame), 50.0f)];
	[_footerView setBackgroundColor:[UIColor customBlue]];

	FLStartItem *inviteTitle = [FLStartItem newWithTitle:@"" imageImageName:@"Signup_Check_White" contentText:@"" andSize:50.0f];
	CGRectSetX(inviteTitle.frame, CGRectGetWidth(_footerView.frame) - 50.0f);
	[_footerView addSubview:inviteTitle];

	inviteButton = [UIButton newWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 50.0f)];
	[inviteButton setTitle:NSLocalizedString(@"SIGNUP_VIEW_IGNORE_BUTTON_2", @"") forState:UIControlStateNormal];
	[inviteButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
	[inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_footerView addSubview:inviteButton];

	CALayer *TopBorder = [CALayer layer];
	TopBorder.frame = CGRectMake(0.0f, 0.0f, _footerView.frame.size.width, 2.0f);
	TopBorder.backgroundColor = [UIColor whiteColor].CGColor;
	[_footerView.layer addSublayer:TopBorder];

	[_mainBody addSubview:_footerView];
	CGRectSetHeight(_tableView.frame, CGRectGetHeight(_tableView.frame) - 50.0f);
	CGRectSetY(_footerView.frame, CGRectGetMinY(_footerView.frame) - 50.0f);
}

- (void)displayAlertWithText:(NSString *)alertMessage {
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

- (void)createTableContactUnderView:(UIView *)topView {
	if (!topView)
		topView = [[UIView alloc] initWithFrame:CGRectMake(0, -5, 0, 0)];
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(topView.frame)) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor customBackgroundHeader]];
	[_tableView setSeparatorColor:[UIColor customBackgroundHeader]];
	[_tableView setSeparatorInset:UIEdgeInsetsZero];
	[_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
	[_tableView setAllowsMultipleSelection:YES];

	[_mainBody addSubview:_tableView];

	[_tableView setDataSource:self];
	[_tableView setDelegate:self];
}

- (void)createContactList {
	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] createContactList: ^(NSMutableArray *arrayContactAdressBook, NSMutableArray *arrayContactFlooz) {
	    _contactInfoArray = arrayContactAdressBook;
	    _contactFromFlooz = arrayContactFlooz;
	    [_tableView reloadData];
	} atSignup:YES];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 25) {
		[self goToNextPage];
	}
    else if (alertView.tag == 42) {
        [_phoneField.textfield becomeFirstResponder];
        [_nextButton setEnabled:NO];
        [_nextButton setBackgroundColor:[UIColor customBackground]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 42 && buttonIndex == 1) {
        [[Flooz sharedInstance] showLoadView];
        [appDelegate clearSavedViewController];
        [[Flooz sharedInstance] loginWithPhone:_userDic[@"phone"]];
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
	if (indexPath.section == 0) {
		static NSString *cellIdentifier = @"FriendAddCell";
		FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if (!cell) {
			cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}

		FLUser *user = [_contactFromFlooz objectAtIndex:indexPath.row];
		[cell setFriend:user];

		return cell;
	}
	else {
		static NSString *cellIdentifier = @"ContactCell";
		ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

		if (!cell) {
			cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor customBackground];
		}

		NSDictionary *contact = _contactInfoArray[indexPath.row];
		[cell setContact:contact];

		cell.accessoryView = nil;
		if ([contact[@"selected"] boolValue]) {
			cell.accessoryView = [UIImageView imageNamed:@"Signup_Friends_Selected"];
		}
		else {
			cell.accessoryView = [UIImageView imageNamed:@"Signup_Friends_Plus"];
		}

		[cell.addFriendButton setHidden:YES];
		return cell;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 54.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return NSLocalizedString(@"CONTACT_PICKER_FLOOZ", nil);
	}
	return NSLocalizedString(@"CONTACT_PICKER_NON_FLOOZ", nil);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0 && _contactFromFlooz.count) {
		return 28;
	}
	else if (section == 1 && _contactInfoArray.count) {
		return 28;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	CGFloat heigth = [self tableView:tableView heightForHeaderInSection:section];

	UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(tableView.frame), heigth)];

	view.backgroundColor = [UIColor customBackgroundHeader];

	{
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 0, CGRectGetHeight(view.frame))];

		label.textColor = [UIColor customBlueLight];

		label.font = [UIFont customContentRegular:14];
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
			cell.accessoryView = [UIImageView imageNamed:@"Signup_Friends_Selected"];
			[_contactToInvite addObject:contact];
		}
		else {
			[_contactToInvite removeObject:contact];
			[contact setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
			cell.accessoryView = [UIImageView imageNamed:@"Signup_Friends_Plus"];
		}
		[_contactInfoArray replaceObjectAtIndex:indexPath.row withObject:contact];
		[self displaySendButtonOrNot];
	}
}

- (void)displaySendButtonOrNot {
	if (_contactToInvite.count > 0) {
		[_nextButton setTitle:NSLocalizedString(@"Invite_Friends_Button", @"") forState:UIControlStateNormal];
		[_nextButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
		[_nextButton addTarget:self action:@selector(inviteFriends) forControlEvents:UIControlEventTouchUpInside];
	}
	else {
		[_nextButton setTitle:NSLocalizedString(@"SIGNUP_VIEW_IGNORE_BUTTON_2", @"") forState:UIControlStateNormal];
		[_nextButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
		[_nextButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)inviteFriends {
	MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
	if ([MFMessageComposeViewController canSendText]) {
		message.messageComposeDelegate = self;

		NSMutableArray *listOfPhone = [NSMutableArray new];
		for (NSDictionary *contact in _contactToInvite) {
			for (NSString *phone in contact[@"phones"]) {
				[listOfPhone addObject:phone];
			}
		}
		[message setRecipients:listOfPhone];
		NSString *textMessage = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Invite_Friends_Message_SMS", @""), [[[Flooz sharedInstance] currentUser] invitCode]];
		[message setBody:textMessage];

		message.modalPresentationStyle = UIModalPresentationPageSheet;
		[self presentViewController:message animated:YES completion:nil];
	}
}

- (void)addFriend:(UIButton *)button {
	UITableViewCell *cell = (UITableViewCell *)[self findFirstViewInHierarchyOfClass:[UITableViewCell class] object:button];
	NSIndexPath *indexPath = [_tableView indexPathForCell:cell];

	FLUser *contact = _contactFromFlooz[indexPath.row];
	[[Flooz sharedInstance] friendAcceptSuggestion:contact.userId success: ^{
	    [_contactFromFlooz removeObjectAtIndex:indexPath.row];
	    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
	}];
}

- (UIView *)findFirstViewInHierarchyOfClass:(Class)classToLookFor object:(UIView *)v {
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
	[self dismissViewControllerAnimated:YES completion: ^{
	    if (result == MessageComposeResultSent) {
	        [self goToNextPage];
		}
	    else if (result == MessageComposeResultFailed) {
	        [self displayAlertWithText:NSLocalizedString(@"ALERT_CONTACT_DENIES_ACCESS_PREVIOUS", @"")];
		}
	}];
}

@end
