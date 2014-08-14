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

@interface FirstLaunchContentViewController ()
{
    CGFloat sizePicto;
    CGFloat ratioiPhones;
    
    UIImageView *logo;
    NSMutableDictionary *_userDic;
    
    FLKeyboardView *inputView;
}

@end

@implementation FirstLaunchContentViewController

- (void)loadView {
    [super loadView];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    CGRect frame    = [[UIScreen mainScreen] bounds];
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    //[self.view setFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight() - STATUSBAR_HEIGHT - NAVBAR_HEIGHT)];
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
    
    _userDic = [NSMutableDictionary new];
	[self setContent];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
    
	if ([self.delegate respondsToSelector:@selector(firstLaunchContentViewControllerDidDAppear:)]) {
		[self.delegate firstLaunchContentViewControllerDidDAppear:self];
	}
    
    switch (_pageIndex) {
		case SignupPagePhone: {
            dispatch_async(dispatch_get_main_queue(), ^{
                FirstLaunchContentViewController *strongSelf = self;
                [strongSelf.phoneField becomeFirstResponder];
            });
        }
            break;
        default: {
            dispatch_async(dispatch_get_main_queue(), ^{
                FirstLaunchContentViewController *strongSelf = self;
                [strongSelf.textFieldToFocus becomeFirstResponder];
            });
        }
            break;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setContent
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT + 20 / ratioiPhones, CGRectGetWidth(self.view.frame), 50 / ratioiPhones)];
    label.font = [UIFont customTitleExtraLight:28];
    label.textColor = [UIColor customBlue];
    label.textAlignment = NSTextAlignmentCenter;
    
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(label.frame) + 15.0f / ratioiPhones, 50.0f, 1.0f)];
    [bar setBackgroundColor:[UIColor customBlue]];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(11, STATUSBAR_HEIGHT + 20 / ratioiPhones, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
    [backButton setCenter:CGPointMake(26, CGRectGetMidY(label.frame) + 1)];
    [backButton addTarget:self action:@selector(goToPreviousPage) forControlEvents:UIControlEventTouchUpInside];
    
    switch (_pageIndex) {
		case SignupPageTuto: {
            [self.view addSubview:label];
            [self.view addSubview:bar];
            label.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE", @"");
            
            UIView *item1 = [self placePictoAndText:@"picto_accueil_collect_money" title:@"SIGNUP_VIEW_1_TITLE_1" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_1" underView:bar];
            UIView *item2 = [self placePictoAndText:@"picto_accueil_secure" title:@"SIGNUP_VIEW_1_TITLE_2" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_2" underView:item1];
            [self placePictoAndText:@"picto_accueil_friends" title:@"SIGNUP_VIEW_1_TITLE_3" subTitle:@"SIGNUP_VIEW_1_SUBTITLE_3" underView:item2];
            
            FLStartButton *startButton  = [[FLStartButton alloc] initWithFrame:CGRectMake(30, PPScreenHeight() - 60 / ratioiPhones, 180, 44) title:NSLocalizedString(@"SIGNUP_VIEW_1_BUTTON", @"")];
            [startButton setOrigin:CGPointMake(PPScreenWidth()/2 - startButton.frame.size.width/2, PPScreenHeight() - startButton.frame.size.height - 28 / ratioiPhones)];
            [startButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:startButton];
        }
            break;
		case SignupPageExplication: {
            [self.view addSubview:label];
            [self.view addSubview:bar];
            [self.view addSubview:backButton];
            label.text = NSLocalizedString(@"SIGNUP_HEAD_TITLE_2", @"");
            
            UIView *item1 = [self placePictoAndText:@"picto_accueil_time.png" title:@"SIGNUP_VIEW_2_TITLE_1" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_1" underView:bar];
            UIView *item2 = [self placePictoAndText:@"picto_accueil_credit_card.png" title:@"SIGNUP_VIEW_2_TITLE_2" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_2" underView:item1];
            [self placePictoAndText:@"picto_accueil_share.png" title:@"SIGNUP_VIEW_2_TITLE_3" subTitle:@"SIGNUP_VIEW_2_SUBTITLE_3" underView:item2];
            
            FLStartButton *startButton  = [[FLStartButton alloc] initWithFrame:CGRectMake(30, PPScreenHeight() - 60 / ratioiPhones, 220, 44) title:NSLocalizedString(@"SIGNUP_VIEW_2_BUTTON", @"")];
            [startButton setOrigin:CGPointMake(PPScreenWidth()/2 - startButton.frame.size.width/2, PPScreenHeight() - startButton.frame.size.height - 28 / ratioiPhones)];
            [startButton addTarget:self action:@selector(goToNextPage) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:startButton];
        }
            break;
        case SignupPagePhone: {
            [self.view addSubview:backButton];
            
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
            [self.view addSubview:backButton];
            [backButton setOrigin:CGPointMake(10, 80.0f)];
            label.text = NSLocalizedString(@"Pseudo", @"");
            [label setOrigin:CGPointMake(0, 70.0f)];
            [bar setOrigin:CGPointMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(label.frame) + 15.0f / ratioiPhones)];
            [self.view addSubview:label];
            [self.view addSubview:bar];
            FLTextFieldIcon *username = [[FLTextFieldIcon alloc] initWithIcon:@"field-username" placeholder:@"FIELD_USERNAME" for:_userDic key:@"nick" position:CGPointMake(0.0f, CGRectGetMaxY(bar.frame) + 25.0f / ratioiPhones)];
            [username addForNextClickTarget:self action:@selector(checkPseudo)];
            self.textFieldToFocus = username;
            [self.view addSubview:username];
        }
            break;
        case SignupPageInfo: {
            [self.view addSubview:backButton];
            [backButton setOrigin:CGPointMake(10, 80.0f)];
            label.text = NSLocalizedString(@"Informations", @"");
            [label setOrigin:CGPointMake(0, 70.0f)];
            [bar setOrigin:CGPointMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(label.frame) + 15.0f / ratioiPhones)];
            [self.view addSubview:label];
            [self.view addSubview:bar];
            FLTextFieldIcon *name = [[FLTextFieldIcon alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:[NSMutableDictionary new] key:@"firstName" position:CGPointMake(0.0f, CGRectGetMaxY(bar.frame) + 25.0f / ratioiPhones) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
            self.textFieldToFocus = name;
            [name addForNextClickTarget:self action:@selector(focusOnNext)];
            [self.view addSubview:name];
            
            FLTextFieldIcon *email = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_userDic key:@"email" position:CGPointMake(0.0f, CGRectGetMaxY(name.frame) + 10.0f / ratioiPhones)];
            [email addForNextClickTarget:self action:@selector(checkEmail)];
            self.secondTextFieldToFocus = email;
            [self.view addSubview:email];
        }
            break;
        case SignupPagePassword: {
            [self.view addSubview:backButton];
            [backButton setOrigin:CGPointMake(10, 80.0f)];
            label.text = NSLocalizedString(@"Mot de passe", @"");
            [label setOrigin:CGPointMake(0, 70.0f)];
            [bar setOrigin:CGPointMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(label.frame) + 15.0f / ratioiPhones)];
            [self.view addSubview:label];
            [self.view addSubview:bar];
            
            FLTextFieldIcon *password = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD" for:_userDic key:@"password" position:CGPointMake(0.0f, CGRectGetMaxY(bar.frame) + 25.0f / ratioiPhones)];
            [password seTsecureTextEntry:YES];
            [password addForNextClickTarget:self action:@selector(focusOnNext)];
            self.textFieldToFocus = password;
            [self.view addSubview:password];
            
            FLTextFieldIcon *passwordConfirm = [[FLTextFieldIcon alloc] initWithIcon:@"field-password" placeholder:@"FIELD_PASSWORD_CONFIRMATION" for:_userDic key:@"confirmation" position:CGPointMake(0.0f, CGRectGetMaxY(password.frame) + 10.0f / ratioiPhones)];
            [passwordConfirm seTsecureTextEntry:YES];
            [passwordConfirm addForNextClickTarget:self action:@selector(checkPassword)];
            self.secondTextFieldToFocus = passwordConfirm;
            [self.view addSubview:passwordConfirm];
        }
            break;
        case SignupPageCode: {
            [self.view addSubview:backButton];
            [backButton setOrigin:CGPointMake(10, 80.0f)];
            label.text = NSLocalizedString(@"Code", @"");
            [label setOrigin:CGPointMake(0, 70.0f)];
            [bar setOrigin:CGPointMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(label.frame) + 15.0f / ratioiPhones)];
            [self.view addSubview:label];
            [self.view addSubview:bar];
            
            FLHomeTextField *code = [[FLHomeTextField alloc] initWithPlaceholder:@"Code pin" for:_userDic key:@"code" position:CGPointMake(20, 200)];
            [code addForNextClickTarget:self action:@selector(didConnectTouchr)];
            self.textFieldToFocus = (FLTextFieldIcon *)code.textfield;
            [self.view addSubview:code];
            
            inputView = [FLKeyboardView new];
            inputView.textField = code.textfield;
            code.textfield.inputView = inputView;
        }
            break;
        case SignupPageCB: {
            [backButton setOrigin:CGPointMake(10, 80.0f)];
            label.text = NSLocalizedString(@"Carte bancaire", @"");
            [label setOrigin:CGPointMake(0, 70.0f)];
            [bar setOrigin:CGPointMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(label.frame) + 15.0f / ratioiPhones)];
            [self.view addSubview:label];
            [self.view addSubview:bar];
        }
            break;
        case SignupPageFriends: {
            [backButton setOrigin:CGPointMake(10, 80.0f)];
            label.text = NSLocalizedString(@"Invitez des amis", @"");
            [label setOrigin:CGPointMake(0, 70.0f)];
            [bar setOrigin:CGPointMake(PPScreenWidth() / 2 - 25.0f, CGRectGetMaxY(label.frame) + 15.0f / ratioiPhones)];
            [self.view addSubview:label];
            [self.view addSubview:bar];
            
        }
            break;
        default: {
            label.text = [NSString stringWithFormat:@"%d", (int)_pageIndex];
        }
            break;
    }
}

- (UIView *)placePictoAndText:(NSString *)pictoName title:(NSString *)title subTitle:(NSString *)subTitle underView:(UIView *)view {
    FLStartItem *item = [FLStartItem newWithTitle:@"" imageImageName:pictoName contentText:@"coucou" andSize:sizePicto];
    [item setSize:CGSizeMake(sizePicto, sizePicto)];
    [item setOrigin:CGPointMake(10, CGRectGetMaxY(view.frame) + 15 / ratioiPhones)];
    [self.view addSubview:item];
    
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
    
    [self.view addSubview:textView];
}


- (void)didConnectTouchr
{
    [[self view] endEditing:YES];
    
    if(_userDic[@"phone"] && ![_userDic[@"phone"] isBlank]){
        inputView = [inputView setKeyboardValidateWithTarget:self action:@selector(didConnectTouchr)];
        
        [[Flooz sharedInstance] showLoadView];
        [appDelegate clearSavedViewController];
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
            [self goToNextPage];
        } failure:^(NSError *error) {
            [self.textFieldToFocus becomeFirstResponder];
        }];
    }
}

- (void) checkEmail {
    if (_userDic[@"email"] && ![_userDic[@"email"] isBlank] && [self validateEmail:_userDic[@"email"]]) {
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] verifyEmail:_userDic[@"email"] success:^(id result) {
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
    if (_userDic[@"password"] && _userDic[@"confirmation"] && ![_userDic[@"password"] isBlank] && ![_userDic[@"confirmation"] isBlank] && [_userDic[@"password"] isEqualToString:_userDic[@"confirmation"]]) {
        [self goToNextPage];
    }
    else {
        [self.textFieldToFocus becomeFirstResponder];
    }
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

#pragma mark - button methods
- (void) goToNextPage {
    if ([self.delegate respondsToSelector:@selector(goToNextPage:)]) {
		[self.delegate goToNextPage:_pageIndex];
	}
}
- (void) goToPreviousPage {
    if ([self.delegate respondsToSelector:@selector(goToPreviousPage:)]) {
		[self.delegate goToPreviousPage:_pageIndex];
	}
}

- (void)didUsernameEndEditing {
    if ([self.delegate respondsToSelector:@selector(goToNextPage:)]) {
		[self.delegate goToNextPage:_pageIndex];
	}
}
- (void)didEmailEndEditing {
    if ([self.delegate respondsToSelector:@selector(goToNextPage:)]) {
		[self.delegate goToNextPage:_pageIndex];
	}
}

@end
