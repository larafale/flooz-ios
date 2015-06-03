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
#import "FLSelectAmount.h"
#import "FLSelectFriendButton.h"
#import "FLPopupInformation.h"

#import "CreditCardViewController.h"
#import "TimelineViewController.h"
#import "NewTransactionDatePicker.h"

#import "AppDelegate.h"

#import "SecureCodeViewController.h"
#import "FLTutoPopoverViewController.h"
#import "UIView+FindFirstResponder.h"
#import "FLPopoverTutoTheme.h"

@interface NewTransactionViewController () {
    FLUser *presetUser;
    
    FLNewTransactionBar *transactionBar;
    FLNewTransactionBar *transactionBarKeyboard;
    FLNewTransactionBar *cameraBarKeyboard;
    
    FLPreset *currentPreset;
    
    FLPaymentField *payementField;
    
    FLNewTransactionAmountInput *amountInput;
    FLTextView *content;
    
    FLSelectFriendButton *friend;
    THContactPickerView *contactPickerView;
    
    FLUserPickerTableView *pickerTableView;
    
    FLTutoPopoverViewController *tutoPopover;
    WYPopoverController *popoverController;
    
    BOOL infoDisplayed;
    BOOL firstView;
    BOOL firstViewAmount;
    BOOL firstViewWhy;
    BOOL isDemo;
    
    BOOL contactPickerVisible;
    
    int currentDemoStep;
    
    FLCameraKeyboard *camera;
    UIView *cameraView;
    UIImageView *imageTransaction;
    UIButton *closeImage;
    
    CGFloat _offset;
    UIView *_blackScreen;
    
    BOOL cameraDisplayed;
    NSTimer *timerForSlider;
    CGFloat heightTarget;
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
        
        if (preset.blockBack) {
            self.navigationItem.leftBarButtonItem = nil;
        }
        
        if (preset.amount)
            transaction[@"amount"] = [preset.amount stringValue];
        
        if (preset.why)
            transaction[@"why"] = preset.why;
        
        if (preset.payload)
            transaction[@"payload"] = preset.payload;
        
        if (preset.blockAmount)
            firstViewAmount = !preset.blockAmount;
        
        currentDemoStep = 0;
        firstViewAmount = preset.focusAmount;
        firstViewWhy = preset.focusWhy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.view.backgroundColor = [UIColor customBackground];
    _blackScreen = [UIView newWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight())];
    [_blackScreen setBackgroundColor:[UIColor customBackground]];
    [_blackScreen setAlpha:0.0];
    
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
            CGRectSetY(amountInput.frame, CGRectGetMinY(friend.frame));
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
        
        content = [[FLTextView alloc] initWithPlaceholder:contentPlaceholder for:transaction key:@"why" position:CGPointMake(0, _offset)];
        [content setInputAccessoryView:transactionBarKeyboard];
        [content hideSeparatorTop];
        [content addTextChangeTarget:self action:@selector(contentChange)];
        [content addTextFocusTarget:self action:@selector(contentFocus)];
        [_contentView addSubview:content];
        
        [self prepareImage];
        
        if (currentPreset && currentPreset.blockWhy)
            [content setUserInteractionEnabled:!currentPreset.blockWhy];
        
        [content setWidth:PPScreenWidth() - CGRectGetWidth(imageTransaction.frame)];
        transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionSend:@selector(validSendMoney) actionCollect:@selector(validCollectMoney)];
        [transactionBar setDelegate:self];
        
        CGRectSetHeight(_contentView.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame));
        
        pickerTableView = [[FLUserPickerTableView alloc] initWithFrame:CGRectMake(0, _offset, SCREEN_WIDTH, CGRectGetHeight(_contentView.frame) - _offset + CGRectGetHeight(transactionBar.frame))];
        [pickerTableView setPickerDelegate:self];
        
        [self.view addSubview:transactionBar];
        
        _offset = CGRectGetMaxY(content.frame);
        
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
        [_contentView addGestureRecognizer:tapG];
    }
    
    if ([[transaction objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypePayment]]) {
        [payementField didWalletTouch];
    }
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame));
    
    [appDelegate.window addSubview:_blackScreen];
    [_blackScreen setHidden:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [cameraView setHidden:YES];
    cameraView = nil;
    
    if ([popoverController isPopoverVisible])
        [popoverController dismissPopoverAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(self.view.frame) - CGRectGetHeight(transactionBar.frame));
    [friend reloadData];
    [self reloadTransactionBarData];
    [self validateView];
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (currentPreset) {
        if (currentPreset.blockBalance)
            [((FLNavigationController*)self.parentViewController) setAmountHidden:YES];
        else
            [((FLNavigationController*)self.parentViewController) setAmountHidden:NO];
        
        if (currentPreset.image) {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:currentPreset.image] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
             {
                 if (image && !error && finished) {
                     [self rotateImageWithRadians:0 imageRotate:image andImage:nil];
                     currentPreset.image = @"";
                 }
             }];
        }
    } else
        [((FLNavigationController*)self.parentViewController) setAmountHidden:NO];
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame));
    
    if (isDemo) {
        if (currentPreset.popup) {
            [[[FLPopupInformation alloc] initWithTitle:currentPreset.popup[@"title"] message:[[NSAttributedString alloc] initWithString:currentPreset.popup[@"content"]] button:currentPreset.popup[@"button"] ok:^() {
                if (currentPreset.popup[@"triggers"]) {
                    NSArray *triggers = currentPreset.popup[@"triggers"];
                    for (NSDictionary *triggerData in triggers) {
                        FLTrigger *trigger = [[FLTrigger alloc] initWithJson:triggerData];
                        [[Flooz sharedInstance] handleTrigger:trigger];
                    }
                }

                if (currentPreset.steps) {
                    [self showDemoStepPopover:currentPreset.steps[currentDemoStep]];
                }
                
                currentPreset.popup = nil;
            }] show];
        } else if (currentPreset.steps) {
            [self showDemoStepPopover:currentPreset.steps[currentDemoStep]];
        }
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
    
//    if (!presetUser)
//        valid = NO;
//    
//    if (!transaction[@"amount"] || [transaction[@"amount"] isBlank] || [transaction[@"amount"] floatValue] < 0.5f)
//        valid = NO;
//    
//    if (!transaction[@"why"] || [transaction[@"why"] isBlank])
//        valid = NO;
    
    if (presetUser) {
        if (presetUser.blockObject != nil) {
            if ([presetUser.blockObject objectForKey:@"pay"] != nil && [[presetUser.blockObject objectForKey:@"pay"] boolValue]) {
                [self hideChargeButton:false];
                [self hidePayButton:true];
            } else if ([presetUser.blockObject objectForKey:@"charge"] != nil && [[presetUser.blockObject objectForKey:@"charge"] boolValue]) {
                [self hideChargeButton:true];
                [self hidePayButton:false];
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
    FLNavigationController *nav = (FLNavigationController*)self.parentViewController;
    NSNumber *number = [NSNumber numberWithFloat:[amountInput.textfield.text floatValue]];
    transaction[@"amount"] = amountInput.textfield.text;
    [nav setAmount:number];
    [self validateView];
}

- (void)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - demo handler

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
    } else if ([focus isEqualToString:@"scope"] || [focus isEqualToString:@"image"] || [focus isEqualToString:@"fb"] || [focus isEqualToString:@"pay"]) {
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
    [pickerTableView reloadData];
}

- (void)contactPickerDidEndEditing {
    if (presetUser == nil && ![contactPickerView.textField.text isBlank]) {
        NSString *text = contactPickerView.textField.text;
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
    imageTransaction = [[UIImageView alloc] initWithFrame:CGRectMake(PPScreenWidth() - 14 - 90, _offset + 10, 0, 0)];
    [_contentView addSubview:imageTransaction];
    [imageTransaction setMultipleTouchEnabled:YES];
    [imageTransaction setUserInteractionEnabled:YES];
    [imageTransaction addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFullscreenImage)]];
    
    closeImage = [UIButton newWithFrame:CGRectMake(40, 0, 40, 40)];
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
            [transaction setValue:nil forKey:@"contact"];
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
        }
    } else {
        transaction[@"to"] = @"";
        [transaction setValue:nil forKey:@"contact"];
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
    } noCreditCard: ^() {
//        [self presentCreditCardController];
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
    
    if (keyboardHeight > 216 + CGRectGetHeight(transactionBarKeyboard.frame)) {
        keyboardHeight = 216 + CGRectGetHeight(transactionBarKeyboard.frame);
    }
    [content setMaxHeight:CGRectGetHeight(_contentView.frame) - keyboardHeight - CGRectGetMinY(content.frame)];
    
    [self dismissCamera];
}

- (void)keyboardDidDisappear:(NSNotification *)notification {
    [self reloadTransactionBarData];
    transactionBar.hidden = NO;
    
    [content setMaxHeight:CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame) - CGRectGetMinY(content.frame)];
    
    if (contactPickerVisible) {
        NSDictionary *info = [notification userInfo];
        CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
        [self adjustTableViewInsetBottom:pickerTableView.frame.origin.y + pickerTableView.frame.size.height - kbRect.origin.y];
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
                
                if (result[@"sms"] && [MFMessageComposeViewController canSendText]) {
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
        [appDelegate.revealSideViewController.timelineController reloadTable:TimelineFilterFriend andFocus:YES];
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
            UIAlertView* curr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CAMERA_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CAMERA_CONTENT", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
            [curr setTag:125];
            dispatch_async(dispatch_get_main_queue(), ^{
                [curr show];
            });
        }
    }
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
    CGRectSetHeight(imageTransaction.frame, 90);
    CGRectSetWidth(imageTransaction.frame, 90);
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
