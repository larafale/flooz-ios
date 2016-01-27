//
//  NewTransactionViewController.m
//  Flooz
//
//  Created by olivier on 1/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "NewTransactionViewController.h"

#import "FLNewTransactionAmount.h"
#import "FLPaymentField.h"
#import "FLNewTransactionBar.h"
#import "FLPopupInformation.h"

#import "CreditCardViewController.h"
#import "TimelineViewController.h"
#import "NewTransactionDatePicker.h"

#import "AppDelegate.h"

#import "SecureCodeViewController.h"
#import "FLTutoPopoverViewController.h"
#import "UIView+FindFirstResponder.h"
#import "FLPopoverTutoTheme.h"

#import "FLPopupTrigger.h"
#import "GeolocViewController.h"


@interface NewTransactionViewController () {
    FLUser *presetUser;
    
    UIBarButtonItem *amountItem;
    UIBarButtonItem *cbItem;
    
    FLNewTransactionBar *transactionBar;
    FLNewTransactionBar *transactionBarKeyboard;
    FLNewTransactionBar *cameraBarKeyboard;
    
    FLPreset *currentPreset;
    
    FLPaymentField *payementField;
    
    FLNewTransactionAmountInput *amountInput;
    FLTextView *content;
    
    THContactPickerView *contactPickerView;
    
    FLUserPickerTableView *pickerTableView;
    
    FLTutoPopoverViewController *tutoPopover;
    WYPopoverController *popoverController;
    
    BOOL infoDisplayed;
    BOOL firstView;
    BOOL firstViewAmount;
    BOOL firstViewWhy;
    BOOL isDemo;
    
    NSTimer *demoTimer;
    
    BOOL contactPickerVisible;
    
    int currentDemoStep;
    
    FLCameraKeyboard *camera;
    UIView *cameraView;
    UIImageView *imageTransaction;
    UIButton *closeImage;
    
    CGFloat _offset;
    
    BOOL cameraDisplayed;
    NSTimer *timerForSlider;
    CGFloat heightTarget;
    CGFloat pictureZoneSize;
}

@end

@implementation NewTransactionViewController

@synthesize transaction;

- (id)initWithTransactionType:(TransactionType)transactionType {
    return [self initWithTransactionType:transactionType user:nil];
}

- (id)initWithTransactionType:(TransactionType)transactionType user:(FLUser *)user {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"NEW_TRANSACTION", nil);
        transaction = [NSMutableDictionary new];
        
        currentPreset = nil;
        presetUser = nil;
        
        transaction[@"random"] = [FLHelper generateRandomString];
        transaction[@"preset"] = @NO;
        
        [transaction setValue:[FLTransaction transactionTypeToParams:transactionType] forKey:@"method"];
        
        infoDisplayed = NO;
        firstView = YES;
        firstViewAmount = YES;
        firstViewWhy = NO;
        isDemo = NO;
        
        
        if (user) {
            presetUser = user;
            transaction[@"to"] = [@"@" stringByAppendingString :[user username]];
            transaction[@"toTitle"] = [user fullname];
            
            if ([user avatarURL]) {
                transaction[@"toImageUrl"] = [user avatarURL];
            }
            
            if ([user selectedFrom]) {
                [transaction setValue:@{@"selectedFrom": user.selectedFrom} forKey:@"metrics"];
            }
        }
        
        [[Flooz sharedInstance] clearLocationData];
    }
    return self;
}

- (id)initWithPreset:(FLPreset *)preset {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        transaction = [NSMutableDictionary new];
        
        currentPreset = preset;
        presetUser = nil;
        
        transaction[@"preset"] = @YES;
        transaction[@"random"] = [FLHelper generateRandomString];
        
        [transaction setValue:[FLTransaction transactionTypeToParams:preset.type] forKey:@"method"];
        
        infoDisplayed = NO;
        firstView = YES;
        isDemo = preset.popup != NULL || preset.steps != NULL;
        
        if (preset.to) {
            presetUser = preset.to;
            transaction[@"to"] = [@"@" stringByAppendingString :[preset.to username]];
        }
        
        if (preset.title)
            self.title = preset.title;
        else
            self.title = NSLocalizedString(@"NEW_TRANSACTION", nil);
        
        if (preset.amount) {
            transaction[@"amount"] = [FLHelper formatedAmount:preset.amount withCurrency:NO withSymbol:NO];
        }
        
        if (preset.why)
            transaction[@"why"] = preset.why;
        
        if (preset.geo)
            transaction[@"geo"] = preset.geo;
        
        if (preset.payload)
            transaction[@"payload"] = preset.payload;
        
        if (preset.blockAmount)
            firstViewAmount = !preset.blockAmount;
        
        currentDemoStep = 0;
        firstViewAmount = preset.focusAmount;
        firstViewWhy = preset.focusWhy;
        
        [[Flooz sharedInstance] clearLocationData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor customBlue],
                                 NSFontAttributeName: [UIFont customTitleExtraLight:15]
                                 };
    
    amountItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%.2f €", [[[Flooz sharedInstance] currentUser].amount floatValue]] style:UIBarButtonItemStylePlain target:self action:@selector(amountInfos)];
    [amountItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    UIImage *cbImage = [UIImage imageNamed:@"picto-cb"];
    CGSize newImgSize = CGSizeMake(30, 20);
    
    UIGraphicsBeginImageContextWithOptions(newImgSize, NO, 0.0);
    [cbImage drawInRect:CGRectMake(0, 0, newImgSize.width, newImgSize.height)];
    cbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cbItem = [[UIBarButtonItem alloc] initWithImage:cbImage style:UIBarButtonItemStylePlain target:self action:@selector(amountInfos)];
    [cbItem setTintColor:[UIColor customBlue]];
    
    transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionSend:@selector(validSendMoney) actionCollect:@selector(validCollectMoney)];
    [transactionBar setDelegate:self];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight() - PPStatusBarHeight() - NAVBAR_HEIGHT - CGRectGetHeight(transactionBar.frame))];
    [self.view addSubview:self.contentView];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    if (currentPreset && currentPreset.blockBack)
        ((FLNavigationController*)self.parentViewController).blockBack = currentPreset.blockBack;
    
    transactionBarKeyboard = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionSend:@selector(validSendMoney) actionCollect:@selector(validCollectMoney)];
    [transactionBarKeyboard setDelegate:self];
    
    _offset = 0;
    
    {
        THContactViewStyle *contactViewStyle = [[THContactViewStyle alloc] initWithTextColor:[UIColor whiteColor] gradientTop:[UIColor customMiddleBlue] gradientBottom:[UIColor customMiddleBlue] borderColor:[UIColor customMiddleBlue] borderWidth:0 cornerRadiusFactor:10.0f];
        
        THContactViewStyle *contactViewSelectedStyle = [[THContactViewStyle alloc] initWithTextColor:[UIColor whiteColor] gradientTop:[UIColor customBlue] gradientBottom:[UIColor customBlue] borderColor:[UIColor customBlue] borderWidth:0 cornerRadiusFactor:10.0f];
        
        CGRect frameFriend = CGRectMake(0, 7, PPScreenWidth() - 100, 40);
        contactPickerView = [[THContactPickerView alloc] initWithFrame:frameFriend];
        contactPickerView.delegate = self;
        [contactPickerView setPlaceholderLabelText:NSLocalizedString(@"FIELD_TRANSACTION_TO_PLACEHOLDER", nil)];
        [contactPickerView setPlaceholderLabelTextColor:[UIColor customPlaceholder]];
        [contactPickerView setPromptLabelText:NSLocalizedString(@"FIELD_TRANSACTION_TO", nil)];
        [contactPickerView setPromptLabelTextColor:[UIColor whiteColor]];
        [contactPickerView setMaxNumberOfLines:1];
        [contactPickerView setLimitToOne:YES];
        [contactPickerView setFont:[UIFont customTitleLight:17]];
        [contactPickerView setContactViewStyle:contactViewStyle selectedStyle:contactViewSelectedStyle];
        [contactPickerView setBackgroundColor:[UIColor customBackground]];
        [contactPickerView setVerticalPadding:5.0f];
        [contactPickerView.textField addTarget:self action:@selector(contactPickerDidBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
        [contactPickerView.textField addTarget:self action:@selector(contactPickerDidEndEditing) forControlEvents:UIControlEventEditingDidEnd];
        
        if (currentPreset && currentPreset.blockTo)
            [contactPickerView setUserInteractionEnabled:NO];
        
        if (presetUser) {
            [contactPickerView addContact:presetUser withName:(presetUser.fullname ? presetUser.fullname : presetUser.username)];
        }
        
        [_contentView addSubview:contactPickerView];
        
        CGRect frameAmount = CGRectMake(CGRectGetWidth(contactPickerView.frame), CGRectGetMinY(contactPickerView.frame), PPScreenWidth() - CGRectGetWidth(contactPickerView.frame), 50);
        amountInput = [[FLNewTransactionAmountInput alloc] initWithPlaceholder:@"0" for:transaction key:@"amount" currencySymbol:NSLocalizedString(@"GLOBAL_EURO", nil) andFrame:frameAmount delegate:nil];
        [amountInput hideSeparatorTop];
        [amountInput hideSeparatorBottom];
        
        if (currentPreset && currentPreset.blockAmount)
            [amountInput disableInput];
        [amountInput.textfield addTarget:self action:@selector(amountChange) forControlEvents:UIControlEventEditingChanged];
        [amountInput.textfield addTarget:self action:@selector(amountDidBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
        {
            [amountInput setInputAccessoryView:transactionBarKeyboard];
            [_contentView addSubview:amountInput];
            _offset = CGRectGetMaxY(amountInput.frame);
        }
        
        _offset = CGRectGetHeight(amountInput.frame);
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, _offset, SCREEN_WIDTH, 1)];
        [separator setBackgroundColor:[UIColor customMiddleBlue]];
        [_contentView addSubview:separator];
        
        ++_offset;
        
        NSString *contentPlaceholder = @"FIELD_TRANSACTION_CONTENT_PLACEHOLDER";
        
        if (currentPreset && currentPreset.whyPlaceholder)
            contentPlaceholder = currentPreset.whyPlaceholder;
        
        content = [[FLTextView alloc] initWithPlaceholder:contentPlaceholder for:transaction key:@"why" frame:CGRectMake(0, _offset, PPScreenWidth(), CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame) - _offset)];
        [content setInputAccessoryView:transactionBarKeyboard];
        [content addTextChangeTarget:self action:@selector(contentChange)];
        [content addTextFocusTarget:self action:@selector(contentFocus)];
        
        [_contentView addSubview:content];
        
        [self prepareImage];
        
        if (currentPreset && currentPreset.blockWhy)
            [content setUserInteractionEnabled:!currentPreset.blockWhy];
        
        pickerTableView = [[FLUserPickerTableView alloc] initWithFrame:CGRectMake(0, _offset, PPScreenWidth(), CGRectGetHeight(_contentView.frame) - _offset)];
        [pickerTableView setPickerDelegate:self];
        
        _offset = CGRectGetMaxY(content.frame);
        
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
        [_contentView addGestureRecognizer:tapG];
    }
    
    if ([[transaction objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypePayment]]) {
        [payementField didWalletTouch];
    }
    
    CGRectSetY(transactionBar.frame,  CGRectGetHeight(self.view.frame) - CGRectGetHeight(transactionBar.frame));
    [self.view addSubview:transactionBar];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[Flooz sharedInstance] clearLocationData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [cameraView setHidden:YES];
    cameraView = nil;
    
    if ([popoverController isPopoverVisible])
        [popoverController dismissPopoverAnimated:YES];
    
    if (demoTimer) {
        [demoTimer invalidate];
        demoTimer = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(self.view.frame) - CGRectGetHeight(transactionBar.frame));
    
    NSNumber *number = transaction[@"amount"];
    [self updateBalanceIndicator:number];
    
    [self reloadTransactionBarData];
    [self validateView];
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (currentPreset) {
        if (currentPreset.image) {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:currentPreset.image] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
             {
                 if (image && !error && finished) {
                     [self rotateImageWithRadians:0 imageRotate:image andImage:nil];
                     currentPreset.image = @"";
                 }
             }];
        }
    }
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(self.view.frame) - CGRectGetHeight(transactionBar.frame));
    
    if (isDemo) {
        demoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(launchDemo) userInfo:nil repeats:NO];
    } else {
        if (firstViewAmount) {
            [amountInput becomeFirstResponder];
            firstViewAmount = NO;
        }
        
        if (firstViewWhy) {
            [content becomeFirstResponder];
            firstViewWhy = NO;
        }
    }
}

- (void)validateView {
    BOOL valid = YES;
    
    if (presetUser) {
        if (presetUser.blockObject != nil) {
            if ([presetUser.blockObject objectForKey:@"charge"] != nil && [[presetUser.blockObject objectForKey:@"charge"] boolValue]) {
                [self hideChargeButton:true];
                [self hidePayButton:false];
            } else if ([presetUser.blockObject objectForKey:@"pay"] != nil && [[presetUser.blockObject objectForKey:@"pay"] boolValue]) {
                [self hideChargeButton:false];
                [self hidePayButton:true];
            } else {
                [self resetPaymentButtons];
            }
        } else {
            [self resetPaymentButtons];
        }
    } else {
        [self resetPaymentButtons];
    }
    
    [transactionBar enablePaymentButtons:valid];
    [transactionBarKeyboard enablePaymentButtons:valid];
    [cameraBarKeyboard enablePaymentButtons:valid];
}

- (void)hideChargeButton:(BOOL)hidden {
    [transactionBar hideChargeButton:hidden];
    [transactionBarKeyboard hideChargeButton:hidden];
    [cameraBarKeyboard hideChargeButton:hidden];
}

- (void)hidePayButton:(BOOL)hidden {
    [transactionBar hidePayButton:hidden];
    [transactionBarKeyboard hidePayButton:hidden];
    [cameraBarKeyboard hidePayButton:hidden];
}

- (void)resetPaymentButtons {
    if ([transaction[@"preset"] boolValue]) {
        if ([transaction[@"method"] isEqualToString:@"pay"]) {
            [self hideChargeButton:true];
            [self hidePayButton:false];
        }
        else if ([transaction[@"method"] isEqualToString:@"charge"]) {
            [self hideChargeButton:false];
            [self hidePayButton:true];
        }
        else {
            [self hideChargeButton:false];
            [self hidePayButton:false];
        }
    } else {
        [self hideChargeButton:false];
        [self hidePayButton:false];
    }
}

- (void)contentChange {
    [self validateView];
}

- (void)contentFocus {
    if ([popoverController isPopoverVisible])
        [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale];
}

-(void)amountChange {
    NSNumber *number = [NSNumber numberWithFloat:[amountInput.textfield.text floatValue]];
    transaction[@"amount"] = amountInput.textfield.text;
    [self updateBalanceIndicator:number];
    [self validateView];
}

- (void)updateBalanceIndicator:(NSNumber *)amount {
    if (!currentPreset || !currentPreset.blockBalance) {
        NSNumber *balance = [Flooz sharedInstance].currentUser.amount;
        
        float tmp = [balance floatValue] - [amount floatValue];
        
        if (tmp < 0) {
            self.navigationItem.rightBarButtonItem = cbItem;
        }
        else {
            [amountItem setTitle:[FLHelper formatedAmount:@(tmp) withSymbol:NO]];
            
            if (self.navigationItem.rightBarButtonItem != amountItem)
                self.navigationItem.rightBarButtonItem = amountItem;
        }
    } else
        self.navigationItem.rightBarButtonItem = nil;
}

- (void)amountInfos {
    [self.view endEditing:YES];
    [self.view endEditing:NO];
    
    UIImage *cbImage = [UIImage imageNamed:@"picto-cb"];
    CGSize newImgSize = CGSizeMake(20, 14);
    
    UIGraphicsBeginImageContextWithOptions(newImgSize, NO, 0.0);
    [cbImage drawInRect:CGRectMake(0, 0, newImgSize.width, newImgSize.height)];
    cbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = cbImage;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_1", nil)];
    [string appendAttributedString:attachmentString];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_2", nil)]];
    
    [[[FLPopupInformation alloc] initWithTitle:NSLocalizedString(@"WALLET_INFOS_TITLE", nil) andMessage:string ok:nil] show];
}

- (void)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - demo handler

- (void)launchDemo {
    [demoTimer invalidate];
    demoTimer = nil;
    if (currentPreset.popup) {
        [[[FLPopupTrigger alloc] initWithData:currentPreset.popup dismiss:^{
            if (currentPreset.popup[@"triggers"]) {                
                [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:currentPreset.popup[@"triggers"]]];
            }
            
            if (currentPreset.steps) {
                [self showDemoStepPopover:currentPreset.steps[currentDemoStep]];
            }
            currentPreset.popup = nil;
        }] show];
    } else if (currentPreset.steps) {
        [self showDemoStepPopover:currentPreset.steps[currentDemoStep]];
    }
}

- (void) showDemoStepPopover:(NSDictionary*)stepData {
    tutoPopover = [[FLTutoPopoverViewController alloc] initWithTitle:stepData[@"title"] message:stepData[@"desc"] step:[NSNumber numberWithInt:currentDemoStep + 1] button:stepData[@"btn"] action:^(FLTutoPopoverViewController *viewController) {
        [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
            if ([stepData[@"focus"] isEqualToString:@"why"]) {
                [content becomeFirstResponder];
            }
            else if ([stepData[@"focus"] isEqualToString:@"to"]) {
                [contactPickerView becomeFirstResponder];
            }
            else if ([stepData[@"focus"] isEqualToString:@"scope"]) {
                [transactionBar.privacyButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            else if (currentDemoStep < currentPreset.steps.count) {
                [self showDemoStepPopover:currentPreset.steps[currentDemoStep]];
            }
        }];
    }];
    popoverController = [[WYPopoverController alloc] initWithContentViewController:tutoPopover];
    [popoverController setTheme:[FLPopoverTutoTheme theme]];
    [popoverController setDelegate:self];
    [popoverController setPassthroughViews:[self getDemoStepPopoverPassthroughViews:stepData[@"focus"]]];
    
    [popoverController presentPopoverFromRect:[self getDemoStepPopoverRect:stepData[@"focus"]] inView:[self getDemoStepPopoverView:stepData[@"focus"]] permittedArrowDirections:[self getDemoStepPopoverArrowDirection:stepData[@"focus"]] animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:nil];
    ++currentDemoStep;
    
    if (currentDemoStep == currentPreset.steps.count)
        isDemo = false;
}

- (CGRect) getDemoStepPopoverRect:(NSString*)focus {
    UIView *tmp = [self getDemoStepPopoverView:focus];
    
    CGRect retRec = tmp.bounds;
    
    if ([focus isEqualToString:@"why"]) {
        retRec = CGRectMake(retRec.origin.x, retRec.origin.y, 150, 35);
    } else if ([focus isEqualToString:@"scope"] || [focus isEqualToString:@"image"] || [focus isEqualToString:@"fb"] || [focus isEqualToString:@"pay"] || [focus isEqualToString:@"geo"]) {
        retRec = CGRectMake(retRec.origin.x, retRec.origin.y - 5, retRec.size.width, retRec.size.height);
    } else if ([focus isEqualToString:@"amount"]) {
        retRec = CGRectMake(retRec.origin.x + 15, retRec.origin.y - 5, retRec.size.width, retRec.size.height);
    }
    
    return retRec;
}

- (UIView*) getDemoStepPopoverView:(NSString*)focus {
    if ([focus isEqualToString:@"amount"]) {
        return amountInput;
    }
    if ([focus isEqualToString:@"to"]) {
        return contactPickerView;
    }
    if ([focus isEqualToString:@"fb"]) {
        return transactionBar.facebookButton;
    }
    if ([focus isEqualToString:@"image"]) {
        return transactionBar.imageButton;
    }
    if ([focus isEqualToString:@"scope"]) {
        return transactionBar.privacyButton;
    }
    if ([focus isEqualToString:@"why"]) {
        return content;
    }
    if ([focus isEqualToString:@"pay"]) {
        return transactionBar.sendButton;
    }
    if ([focus isEqualToString:@"geo"]) {
        return transactionBar.locationButton;
    }
    return nil;
}

- (WYPopoverArrowDirection) getDemoStepPopoverArrowDirection:(NSString*)focus {
    if ([focus isEqualToString:@"amount"]) {
        return WYPopoverArrowDirectionUp;
    }
    if ([focus isEqualToString:@"to"]) {
        return WYPopoverArrowDirectionUp;
    }
    if ([focus isEqualToString:@"fb"]) {
        return WYPopoverArrowDirectionDown;
    }
    if ([focus isEqualToString:@"image"]) {
        return WYPopoverArrowDirectionDown;
    }
    if ([focus isEqualToString:@"scope"]) {
        return WYPopoverArrowDirectionDown;
    }
    if ([focus isEqualToString:@"why"]) {
        return WYPopoverArrowDirectionUp;
    }
    if ([focus isEqualToString:@"pay"]) {
        return WYPopoverArrowDirectionDown;
    }
    if ([focus isEqualToString:@"geo"]) {
        return WYPopoverArrowDirectionDown;
    }
    return WYPopoverArrowDirectionAny;
}

- (NSArray*) getDemoStepPopoverPassthroughViews:(NSString*)focus {
    if ([focus isEqualToString:@"to"]) {
        return @[contactPickerView];
    }
    if ([focus isEqualToString:@"scope"]) {
        return @[transactionBar.privacyButton];
    }
    if ([focus isEqualToString:@"why"]) {
        return @[content];
    }
    if ([focus isEqualToString:@"pay"]) {
        return @[transactionBar.sendButton];
    }
    return @[];
}

#pragma mark - transaction bar delegate

- (void) scopePopoverWillAppear {
    if (isDemo && [popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:NO];
    }
}

- (void) scopePopoverDidDisappear {
    if (isDemo && currentDemoStep < currentPreset.steps.count) {
        [self showDemoStepPopover:currentPreset.steps[currentDemoStep]];
    }
}

#pragma mark - popover delegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return NO;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
{
    
}

#pragma mark - contact picker delegate

- (void)userSelected:(FLUser *)user {
    presetUser = user;
    if (user.userKind == CactusUser)
        [contactPickerView addContact:user withName:user.phone];
    else
        [contactPickerView addContact:user withName:user.fullname];
    
    if (contactPickerVisible) {
        [pickerTableView removeFromSuperview];
        contactPickerVisible = NO;
    }
    if (isDemo && currentDemoStep < currentPreset.steps.count) {
        [self.view endEditing:YES];
        [self showDemoStepPopover:currentPreset.steps[currentDemoStep]];
    }
    else if (transaction[@"why"] && ![transaction[@"why"] isBlank])
        [self.view endEditing:YES];
    else
        [content becomeFirstResponder];
    [self validateView];
}

- (void)amountDidBeginEditing {
    if (contactPickerVisible) {
        [pickerTableView removeFromSuperview];
        contactPickerVisible = NO;
    }
}

- (void)contactPickerDidBeginEditing {
    if (isDemo && [popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale];
    }
    if (!contactPickerVisible) {
        [pickerTableView initializeView];
        [self.view addSubview:pickerTableView];
        contactPickerVisible = YES;
    }
    [pickerTableView searchUser:contactPickerView.textField.text];
}

- (void)contactPickerDidEndEditing {
    if (presetUser == nil && ![contactPickerView.textField.text isBlank]) {
        NSString *text = contactPickerView.textField.text;
        text = [FLHelper formatedPhone:text];
        if (text && [FLHelper isValidPhoneNumber:text]) {
            FLUser *user = [FLUser new];
            user.username = text;
            user.phone = text;
            user.userKind = CactusUser;
            presetUser = user;
            
            [contactPickerView addContact:user withName:text];
        } else {
            [contactPickerView removeAllContacts];
        }
    }
}

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    [pickerTableView searchUser:textViewText];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    presetUser = nil;
    [pickerTableView searchUser:contactPickerView.textField.text];
    [self validateView];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    return;
}

- (BOOL)contactPickerTextFieldShouldReturn:(UITextField *)textField {
    NSString *text = textField.text;
    text = [FLHelper formatedPhone:text];
    if (text) {
        FLUser *user = [FLUser new];
        user.username = text;
        user.phone = text;
        user.userKind = CactusUser;
        presetUser = user;
        
        [contactPickerView addContact:user withName:text];
    } else {
        [contactPickerView removeAllContacts];
    }
    if (contactPickerVisible) {
        [pickerTableView removeFromSuperview];
        contactPickerVisible = NO;
    }
    if (isDemo && currentDemoStep < currentPreset.steps.count) {
        [self.view endEditing:YES];
        [self showDemoStepPopover:currentPreset.steps[currentDemoStep]];
    }
    else if (transaction[@"why"] && ![transaction[@"why"] isBlank])
        [self.view endEditing:YES];
    else {
        [content becomeFirstResponder];
        [self validateView];
        return NO;
    }
    [self validateView];
    return YES;
}

#pragma mark - prepare Views

- (void)prepareImage {
    pictureZoneSize = (PPScreenWidth() / 100.0f) * 40;
    
    imageTransaction = [[UIImageView alloc] initWithFrame:CGRectMake(PPScreenWidth() - 14 - pictureZoneSize, _offset + 10, 0, 0)];
    [_contentView addSubview:imageTransaction];
    [imageTransaction setMultipleTouchEnabled:YES];
    [imageTransaction setUserInteractionEnabled:YES];
    [imageTransaction addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullscreenImage)]];
    
    closeImage = [UIButton newWithFrame:CGRectMake(pictureZoneSize - 45, 0, 40, 40)];
    [closeImage setImage:[UIImage imageNamed:@"image-close"] forState:UIControlStateNormal];
    [closeImage addTarget:self action:@selector(touchImage) forControlEvents:UIControlEventTouchUpInside];
    [closeImage setImageEdgeInsets:UIEdgeInsetsMake(2, 15, 15, 2)];
    [imageTransaction addSubview:closeImage];
    
    [imageTransaction setAlpha:0.0];
}

#pragma mark -

- (void)showFullscreenImage {
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = imageTransaction.image;
    imageInfo.referenceRect = imageTransaction.frame;
    imageInfo.referenceView = imageTransaction.superview;
    imageInfo.referenceContentMode = UIViewContentModeScaleAspectFill;
    
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Blurred];
    imageViewer.interactionsDelegate = self;
    
    [imageViewer showFromViewController:[appDelegate myTopViewController] transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect {
    
}

#pragma mark - callbacks

- (void)dismiss {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)validSendMoney {
    [transaction setValue:[FLTransaction transactionTypeToParams:TransactionTypePayment] forKey:@"method"];
    [self valid];
}

- (void)validCollectMoney {
    [transaction setValue:[FLTransaction transactionTypeToParams:TransactionTypeCharge] forKey:@"method"];
    [self valid];
}

- (void)valid {
    [[self view] endEditing:YES];
    
    static Boolean showAvalaible = YES;
    
    if (presetUser) {
        if (presetUser.userKind == FloozUser) {
            transaction[@"to"] = presetUser.username;
            [transaction removeObjectForKey:@"contact"];
        } else if (presetUser.userKind == PhoneUser) {
            transaction[@"to"] = presetUser.phone;
            if (presetUser.firstname || presetUser.lastname) {
                [transaction setValue:[NSMutableDictionary new] forKey:@"contact"];
                
                if (![presetUser.firstname isBlank]) {
                    [[transaction objectForKey:@"contact"] setValue:presetUser.firstname forKey:@"firstName"];
                }
                
                if (![presetUser.lastname isBlank]) {
                    [[transaction objectForKey:@"contact"] setValue:presetUser.lastname forKey:@"lastName"];
                }
            }
        } else {
            transaction[@"to"] = presetUser.phone;
            [transaction removeObjectForKey:@"contact"];
        }
    } else {
        transaction[@"to"] = @"";
        [transaction removeObjectForKey:@"contact"];
    }
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createTransactionValidate:transaction success: ^(id result) {
        if (showAvalaible) {
            showAvalaible = NO;
            if ([result objectForKey:@"confirmationText"]) {
                FLPopup *popup = [[FLPopup alloc] initWithMessage:[result objectForKey:@"confirmationText"] accept: ^{
                    showAvalaible = YES;
                    [self didTransactionValidated];
                } refuse:^{
                    showAvalaible = YES;
                }];
                [popup show];
            }
            else {
                [self didTransactionValidated];
            }
        }
    }];
}

- (void)reloadTransactionBarData {
    [transactionBar reloadData];
    [transactionBarKeyboard reloadData];
    [cameraBarKeyboard reloadData];
}

#pragma mark - PaymentFielDelegate

- (void)didWalletSelected {
}

- (void)didCreditCardSelected {
}

- (void)presentCreditCardController {
    CreditCardViewController *controller = [CreditCardViewController new];
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
}

#pragma mark - Keyboard Management

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    pickerTableView.contentInset = UIEdgeInsetsMake(topInset,
                                                    pickerTableView.contentInset.left,
                                                    bottomInset,
                                                    pickerTableView.contentInset.right);
    pickerTableView.scrollIndicatorInsets = pickerTableView.contentInset;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:pickerTableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:pickerTableView.contentInset.top bottom:bottomInset];
}

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:pickerTableView.frame.origin.y + pickerTableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    [self reloadTransactionBarData];
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    [content setHeight:CGRectGetHeight(_contentView.frame) - keyboardHeight - CGRectGetHeight(amountInput.frame) - 1];
    
    [self dismissCamera];
}

- (void)keyboardDidDisappear:(NSNotification *)notification {
    [self reloadTransactionBarData];
    transactionBar.hidden = NO;
    
    [content setHeight:CGRectGetHeight(_contentView.frame) - CGRectGetMinY(content.frame)];
    
    if (contactPickerVisible) {
        [self adjustTableViewInsetBottom:0];
    }
}

- (void)keyboardWillDisappear {
    
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 125 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
    else if (buttonIndex == 1) {
        [self didTransactionValidated];
    }
}

- (void)didTransactionValidated {
    [[Flooz sharedInstance] showLoadView];
    CompleteBlock completeBlock = ^{
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] createTransaction:transaction success: ^(NSDictionary *result) {
                transaction[@"id"] = result[@"item"][@"_id"];
                if (transaction[@"image"]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[Flooz sharedInstance] uploadTransactionPic:transaction[@"id"] image:transaction[@"image"] success:^(id result) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadTimeline object:nil];
                        } failure:nil];
                    });
                }
                
                if (result[@"sms"]) {
                    if ([MFMessageComposeViewController canSendText]) {
                        [[Flooz sharedInstance] showLoadView];
                        MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
                        message.messageComposeDelegate = self;
                        
                        [message setRecipients:[NSArray arrayWithObject:result[@"sms"][@"phone"]]];
                        [message setBody:result[@"sms"][@"message"]];
                        
                        message.modalPresentationStyle = UIModalPresentationPageSheet;
                        [self presentViewController:message animated:YES completion:^{
                            [[Flooz sharedInstance] hideLoadView];
                        }];
                    } else {
                        [[Flooz sharedInstance] showLoadView];
                        [[Flooz sharedInstance] confirmTransactionSMS:transaction[@"id"] validate:NO success:^(id result) {
                            [self dismissView];
                        } failure:^(NSError *error) {
                            [self dismissView];
                        }];
                    }
                } else {
                    [self dismissView];
                }
            } failure:NULL];
        });
    };
    
    if ([SecureCodeViewController canUseTouchID])
        [SecureCodeViewController useToucheID:completeBlock passcodeCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                SecureCodeViewController *controller = [SecureCodeViewController new];
                controller.completeBlock = completeBlock;
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
                    [[Flooz sharedInstance] hideLoadView];
                }];
            });
        } cancelCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Flooz sharedInstance] hideLoadView];
            });
        }];
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            SecureCodeViewController *controller = [SecureCodeViewController new];
            controller.completeBlock = completeBlock;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
                [[Flooz sharedInstance] hideLoadView];
            }];
        });
    }
}

- (void)dismissView {
    
    [self dismissViewControllerAnimated:YES completion: ^{
        if (currentPreset && currentPreset.isDemo) {
            [appDelegate askNotification];
        }
    }];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion: ^{
        if (result == MessageComposeResultSent) {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] confirmTransactionSMS:transaction[@"id"] validate:YES success:^(id result) {
                [self dismissView];
            } failure:^(NSError *error) {
                [self dismissView];
            }];
        }
        else if (result == MessageComposeResultCancelled) {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] confirmTransactionSMS:transaction[@"id"] validate:NO success:^(id result) {
                [self dismissView];
            } failure:^(NSError *error) {
                [self dismissView];
            }];
        }
        else if (result == MessageComposeResultFailed) {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] confirmTransactionSMS:transaction[@"id"] validate:NO success:^(id result) {
                [self dismissView];
            } failure:^(NSError *error) {
                [self dismissView];
            }];
        }
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)presentLocation {
//    UIDocumentMenuViewController *documentViewController = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[(__bridge NSString *)kUTTypePDF, (__bridge NSString *)kUTTypeImage] inMode:UIDocumentPickerModeImport];
//    
//    [self.navigationController presentViewController:documentViewController animated:YES completion:nil];
//    
        GeolocViewController *controller = [GeolocViewController new];
    [controller setDelegate:self];
    
    if (transaction[@"geo"]) {
        controller.selectedPlace = transaction[@"geo"];
    }
    
    [self.navigationController presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:nil];
}

- (void)presentCamera {
    if (cameraDisplayed) {
        [self dismissCamera];
    }
    else {
        [self.view endEditing:YES];
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (authStatus == AVAuthorizationStatusAuthorized) {
            if (!cameraView) {
                if (!cameraBarKeyboard) {
                    cameraBarKeyboard = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionSend:@selector(validSendMoney) actionCollect:@selector(validCollectMoney)];
                    [cameraBarKeyboard setDelegate:self];
                    [self validateView];
                    [cameraBarKeyboard reloadData];
                }
                if (!camera) {
                    camera = [[FLCameraKeyboard alloc] initWithController:self height:216 delegate:self];
                }
                CGRectSetY(cameraBarKeyboard.frame, 0);
                CGRectSetY(camera.frame, CGRectGetHeight(cameraBarKeyboard.frame));
                
                cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(cameraBarKeyboard.frame) + CGRectGetHeight(camera.frame))];
                [cameraView addSubview:cameraBarKeyboard];
                [cameraView addSubview:camera];
                
                CGRectSetY(cameraView.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(cameraBarKeyboard.frame));
                
                [appDelegate.window addSubview:cameraView];
            }
            
            [camera startCamera];
            [UIView animateWithDuration:0.3 animations: ^{
                CGRectSetY(cameraView.frame, CGRectGetHeight(appDelegate.window.frame) - CGRectGetHeight(cameraView.frame));
            } completion: ^(BOOL finished) {
                cameraDisplayed = YES;
            }];
        } else if (authStatus == AVAuthorizationStatusNotDetermined){
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted){
                    if (!cameraView) {
                        if (!cameraBarKeyboard) {
                            cameraBarKeyboard = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionSend:@selector(validSendMoney) actionCollect:@selector(validCollectMoney)];
                            [cameraBarKeyboard setDelegate:self];
                            [self validateView];
                            [cameraBarKeyboard reloadData];
                        }
                        if (!camera) {
                            camera = [[FLCameraKeyboard alloc] initWithController:self height:216 delegate:self];
                        }
                        CGRectSetY(cameraBarKeyboard.frame, 0);
                        CGRectSetY(camera.frame, CGRectGetHeight(cameraBarKeyboard.frame));
                        
                        cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(cameraBarKeyboard.frame) + CGRectGetHeight(camera.frame))];
                        [cameraView addSubview:cameraBarKeyboard];
                        [cameraView addSubview:camera];
                        
                        CGRectSetY(cameraView.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(cameraBarKeyboard.frame));
                        
                        [appDelegate.window addSubview:cameraView];
                    }
                    
                    [camera startCamera];
                    [UIView animateWithDuration:0.3 animations: ^{
                        CGRectSetY(cameraView.frame, CGRectGetHeight(appDelegate.window.frame) - CGRectGetHeight(cameraView.frame));
                    } completion: ^(BOOL finished) {
                        cameraDisplayed = YES;
                    }];
                } else {
                    
                }
            }];
        } else {
            UIAlertView* curr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CAMERA_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CAMERA_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
            [curr setTag:125];
            dispatch_async(dispatch_get_main_queue(), ^{
                [curr show];
            });
        }
    }
}

#pragma mark - Geoloc Delegate

- (void) locationPlaceSelected:(NSDictionary *)place {
    [transaction setObject:place forKey:@"geo"];
    [self reloadTransactionBarData];
}

- (void) removeLocation {
    [transaction removeObjectForKey:@"geo"];
    [self reloadTransactionBarData];
}

#pragma mark - CameraKeyboard Delegate

- (void)goToFullScreen:(BOOL)fullScreen {
    [timerForSlider invalidate];
    CGFloat he = PPScreenHeight();
    if (!fullScreen) {
        he = 216;
    }
    heightTarget = he;
    
    CGFloat dif = ABS(he - CGRectGetHeight(camera.frame)) * 10.0f;
    timerForSlider = [NSTimer scheduledTimerWithTimeInterval:(1 / dif) target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
}

- (void)updateSlider {
    CGFloat f = CGRectGetHeight(camera.frame);
    if (heightTarget > CGRectGetHeight(camera.frame)) {
        f += 1;
    }
    else {
        f -= 1;
    }
    [self growCameraToHeight:f];
    if (PPScreenHeight() == f || 216 == f) {
        [timerForSlider invalidate];
    }
}

- (void)growCameraToHeight:(CGFloat)he {
    CGFloat heightInput = he + CGRectGetHeight(cameraBarKeyboard.frame);
    CGFloat minHeight = 216 + CGRectGetHeight(cameraBarKeyboard.frame);
    if (minHeight > heightInput) {
        heightInput = minHeight;
    }
    else if (he > PPScreenHeight()) {
        heightInput = PPScreenHeight() + CGRectGetHeight(cameraBarKeyboard.frame);
    }
    CGRectSetY(cameraView.frame, PPScreenHeight() - heightInput);
    CGRectSetHeight(camera.frame, heightInput - CGRectGetHeight(cameraBarKeyboard.frame));
    [camera setCameraHeight:heightInput - CGRectGetHeight(cameraBarKeyboard.frame)];
    CGRectSetHeight(cameraView.frame, heightInput);
    cameraDisplayed = YES;
}

- (void)presentCameraRoll:(UIImagePickerController *)cameraRoll {
    [self dismissCamera];
    [self presentViewController:cameraRoll animated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)rotateImageWithRadians:(CGFloat)radian imageRotate:(UIImage *)rotateImage andImage:(UIImage *)image {
    [imageTransaction setAlpha:1.0];
    [imageTransaction setImage:rotateImage];
    CGRectSetHeight(imageTransaction.frame, pictureZoneSize);
    CGRectSetWidth(imageTransaction.frame, pictureZoneSize);
    [imageTransaction setContentMode:UIViewContentModeScaleAspectFit];
    
    CGFloat scaleFactor = [self scaleFactor];
    CGRectSetHeight(imageTransaction.frame, imageTransaction.image.size.height / scaleFactor);
    CGRectSetWidth(imageTransaction.frame, imageTransaction.image.size.width / scaleFactor);
    
    CGRectSetY(imageTransaction.frame, 60);
    CGRectSetX(imageTransaction.frame, PPScreenWidth() - 14 - CGRectGetWidth(imageTransaction.frame));
    
    CGRectSetX(closeImage.frame, CGRectGetWidth(imageTransaction.frame) - CGRectGetWidth(closeImage.frame));
    
    [transaction setValue:UIImageJPEGRepresentation(rotateImage, 0.7) forKey:@"image"];
    [content setInputView:nil];
    [content setWidth:PPScreenWidth() - CGRectGetWidth(imageTransaction.frame) - 14];
}

- (CGFloat)scaleFactor {
    if (imageTransaction.image.size.width >= imageTransaction.image.size.height) {
        return [self scaleFactorWidth];
    }
    else {
        return [self scaleFactorHeight];
    }
}

- (CGFloat)scaleFactorWidth {
    return imageTransaction.image.size.width / CGRectGetWidth(imageTransaction.frame);
}

- (CGFloat)scaleFactorHeight {
    return imageTransaction.image.size.height / CGRectGetHeight(imageTransaction.frame);
}

- (void)touchImage {
    CGRectSetHeight(imageTransaction.frame, 0);
    CGRectSetWidth(imageTransaction.frame, 0);
    [content setWidth:PPScreenWidth() - CGRectGetWidth(imageTransaction.frame)];
    [imageTransaction setImage:nil];
    [imageTransaction setAlpha:0.0];
    [transaction setValue:@"" forKey:@"image"];
}

- (void)dismissCamera {
    if (cameraDisplayed) {
        [UIView animateWithDuration:0.3 animations: ^{
            CGRectSetY(cameraView.frame, CGRectGetHeight(appDelegate.window.frame));
        } completion: ^(BOOL finished) {
            [camera stopCamera];
            cameraDisplayed = NO;
        }];
    }
}

@end
