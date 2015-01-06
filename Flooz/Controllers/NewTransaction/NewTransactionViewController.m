//
//  NewTransactionViewController.m
//  Flooz
//
//  Created by jonathan on 1/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "NewTransactionViewController.h"

#import "FLNewTransactionAmount.h"
#import "FLPaymentField.h"
#import "FLNewTransactionBar.h"
#import "FLSelectAmount.h"
#import "FLSelectFriendButton.h"
#import "NewTransactionSelectTypeView.h"

#import "CreditCardViewController.h"
#import "TimelineViewController.h"
#import "NewTransactionDatePicker.h"

#import "AppDelegate.h"

#import "SecureCodeViewController.h"

#import "UIView+FindFirstResponder.h"

@interface NewTransactionViewController () {
    FLNewTransactionBar *transactionBar;
    FLNewTransactionBar *transactionBarKeyboard;
    FLNewTransactionBar *cameraBarKeyboard;
    
    FLPreset *currentPreset;
    
    FLPaymentField *payementField;
    
    FLNewTransactionAmountInput *amountInput;
    FLTextView *content;
    
    FLSelectFriendButton *friend;
    BOOL infoDisplayed;
    BOOL firstView;
    BOOL firstViewAmount;
    BOOL firstViewWhy;
    
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
       
        transaction[@"random"] = [FLHelper generateRandomString];
        transaction[@"preset"] = @NO;
        
        [transaction setValue:[FLTransaction transactionTypeToParams:transactionType] forKey:@"method"];
        
        infoDisplayed = NO;
        firstView = YES;
        firstViewAmount = YES;
        firstViewWhy = NO;
        
        if (user) {
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
        
        transaction[@"preset"] = @YES;
        transaction[@"random"] = [FLHelper generateRandomString];
        
        [transaction setValue:[FLTransaction transactionTypeToParams:preset.type] forKey:@"method"];
        
        infoDisplayed = NO;
        firstView = YES;
        
        if (preset.to) {
            transaction[@"to"] = [@"@" stringByAppendingString :[preset.to username]];
            transaction[@"toTitle"] = [preset.to fullname];
            
            if ([preset.to avatarURL]) {
                transaction[@"toImageUrl"] = [preset.to avatarURL];
            }
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
    
    _offset = 0;
    
    {
        CGRect frameFriend = CGRectMake(0, 0, PPScreenWidth() - 125, 50);
        if (currentPreset)
            friend = [[FLSelectFriendButton alloc] initWithFrame:frameFriend dictionary:transaction editable:!currentPreset.blockTo];
        else
            friend = [[FLSelectFriendButton alloc] initWithFrame:frameFriend dictionary:transaction];
        
        friend.delegate = self;
        [friend hideSeparatorBottom];
        
        [_contentView addSubview:friend];
        
        _offset = CGRectGetMaxY(friend.frame);
        
        CGRect frameAmount = CGRectMake(CGRectGetMaxX(friend.frame), CGRectGetMinY(friend.frame), PPScreenWidth() - CGRectGetMaxX(friend.frame), CGRectGetHeight(friend.frame));
        amountInput = [[FLNewTransactionAmountInput alloc] initWithPlaceholder:@"0" for:transaction key:@"amount" currencySymbol:NSLocalizedString(@"GLOBAL_EURO", nil) andFrame:frameAmount delegate:nil];
        [amountInput hideSeparatorTop];
        [amountInput hideSeparatorBottom];
        
        if (currentPreset && currentPreset.blockAmount)
            [amountInput disableInput];
        [amountInput.textfield addTarget:self action:@selector(amountChange) forControlEvents:UIControlEventEditingChanged];
        {
            [amountInput setInputAccessoryView:transactionBarKeyboard];
            [_contentView addSubview:amountInput];
            CGRectSetY(amountInput.frame, CGRectGetMinY(friend.frame));
            _offset = CGRectGetMaxY(amountInput.frame);
        }
        
        NSString *contentPlaceholder = @"FIELD_TRANSACTION_CONTENT_PLACEHOLDER";
        
        content = [[FLTextView alloc] initWithPlaceholder:contentPlaceholder for:transaction key:@"why" position:CGPointMake(0, _offset - 1)];
        [content setInputAccessoryView:transactionBarKeyboard];
        [content hideSeparatorTop];
        [_contentView addSubview:content];
        
        [self prepareImage];
        
        if (currentPreset && currentPreset.blockWhy)
            [content setUserInteractionEnabled:!currentPreset.blockWhy];
        
        [content setWidth:PPScreenWidth() - CGRectGetWidth(imageTransaction.frame)];
        transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionSend:@selector(validSendMoney) actionCollect:@selector(validCollectMoney)];
        
        CGRectSetHeight(_contentView.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame));
        [self.view addSubview:transactionBar];
        
        _offset = CGRectGetMaxY(content.frame);
        
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
        [_contentView addGestureRecognizer:tapG];
    }
    
    if ([[transaction objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypePayment]]) {
        [payementField didWalletTouch];
    }
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame));
    //    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), offset + 100);
    
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
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(self.view.frame) - CGRectGetHeight(transactionBar.frame));
    [friend reloadData];
    [self reloadTransactionBarData];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame));
    
    if ([transaction objectForKey:@"toTitle"]) {
        if (!infoDisplayed) {
            infoDisplayed = YES;
        }
    }
    
    if (firstViewAmount) {
        [amountInput becomeFirstResponder];
        firstViewAmount = NO;
    }
    
    if (firstViewWhy) {
        [content becomeFirstResponder];
        firstViewWhy = NO;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showTuto) userInfo:nil repeats:NO];
}

-(void)amountChange {
    FLNavigationController *nav = (FLNavigationController*)self.parentViewController;
    NSNumber *number = [NSNumber numberWithFloat:[amountInput.textfield.text floatValue]];
    [nav setAmount:number];
}

-(void)showTuto {
    [appDelegate showTutoPage:TutoPageFlooz inController:self];
}

- (void)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - prepare Views

- (void)prepareImage {
    imageTransaction = [[UIImageView alloc] initWithFrame:CGRectMake(PPScreenWidth() - 14 - 80, _offset, 80, 80)];
    [_contentView addSubview:imageTransaction];
    [imageTransaction setMultipleTouchEnabled:YES];
    [imageTransaction setUserInteractionEnabled:YES];
    
    closeImage = [UIButton newWithFrame:CGRectMake(40, 0, 40, 40)];
    [closeImage setImage:[UIImage imageNamed:@"image-close"] forState:UIControlStateNormal];
    [closeImage addTarget:self action:@selector(touchImage) forControlEvents:UIControlEventTouchUpInside];
    [closeImage setImageEdgeInsets:UIEdgeInsetsMake(2, 15, 15, 2)];
    [imageTransaction addSubview:closeImage];
    
    [imageTransaction setAlpha:0.0];
}

#pragma mark -

- (void)didAmountFixSelected {
    [[self view] endEditing:YES];
    
    [transaction setValue:@100.0 forKey:@"amount"];
    
    [UIView animateWithDuration:.5 animations: ^{
        CGRectSetHeight(amountInput.frame, [FLNewTransactionAmount height]);
        CGRectSetY(content.frame, content.frame.origin.y + [FLNewTransactionAmount height]);
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
    }];
}

- (void)didAmountFreeSelected {
    // Sinon la valeur du clavier est sauvegarder a l envoi
    [[self view] endEditing:YES];
    
    [transaction setValue:nil forKey:@"amount"];
    [transaction setValue:nil forKey:@"goal"];
    
    [UIView animateWithDuration:.5 animations: ^{
        CGRectSetHeight(amountInput.frame, 1);
        CGRectSetY(content.frame, content.frame.origin.y - [FLNewTransactionAmount height]);
        _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
    }];
}

- (void)didTypePaymentelected {
    [[self view] endEditing:YES];
    
    // Car remit a zero par didTypeCollectSelected
    [payementField didWalletTouch];
    [self didWalletSelected];
    
    if (CGRectGetHeight(payementField.frame) <= 1) {
        [UIView animateWithDuration:.5 animations: ^{
            CGRectSetHeight(payementField.frame, [FLPaymentField height]);
            CGRectSetY(content.frame, content.frame.origin.y + [FLPaymentField height]);
            _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
        }];
    }
}

- (void)didTypeCollectSelected {
    [[self view] endEditing:YES];
    
    [transaction setValue:nil forKey:@"source"];
    
    if (CGRectGetHeight(payementField.frame) > 1) {
        [UIView animateWithDuration:.5 animations: ^{
            CGRectSetHeight(payementField.frame, 0);
            CGRectSetY(content.frame, content.frame.origin.y - [FLPaymentField height] - 1);
            _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), CGRectGetMaxY(content.frame));
        }];
    }
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
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createTransactionValidate:transaction success: ^(id result) {
        if ([result objectForKey:@"confirmationText"]) {
            FLPopup *popup = [[FLPopup alloc] initWithMessage:[result objectForKey:@"confirmationText"] accept: ^{
                [self didTransactionValidated];
            } refuse:NULL];
            [popup show];
        }
        else {
            [self didTransactionValidated];
        }
    } noCreditCard: ^() {
        [self presentCreditCardController];
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

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardDidDisappear) name:UIKeyboardDidHideNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
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

- (void)keyboardDidDisappear {
    [self reloadTransactionBarData];
    transactionBar.hidden = NO;
    
    [content setMaxHeight:CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame) - CGRectGetMinY(content.frame)];
}

- (void)keyboardWillDisappear {
    [content setMaxHeight:CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame) - CGRectGetMinY(content.frame)];
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self didTransactionValidated];
    }
}

- (void)didTransactionValidated {
    CompleteBlock completeBlock = ^{
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] createTransaction:transaction success: ^(NSDictionary *result) {
                if (transaction[@"image"]) {
                    [[Flooz sharedInstance] uploadTransactionPic:result[@"item"][@"_id"] image:transaction[@"image"] success:^(id result) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadTimeline object:nil];
                    } failure:nil];
                }
                
                if (result[@"sms"] && [MFMessageComposeViewController canSendText]) {
                    MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
                    message.messageComposeDelegate = self;
                    
                    [message setRecipients:[NSArray arrayWithObject:result[@"sms"][@"phone"]]];
                    [message setBody:result[@"sms"][@"message"]];
                    
                    message.modalPresentationStyle = UIModalPresentationPageSheet;
                    [self presentViewController:message animated:YES completion:nil];
                } else {
                    [self dismissView];
                }
            } failure:NULL];
        });
    };
    
    if ([SecureCodeViewController canUseTouchID])
        [SecureCodeViewController useToucheID:completeBlock passcodeCallback:^{
            SecureCodeViewController *controller = [SecureCodeViewController new];
            controller.completeBlock = completeBlock;
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
            
        }];
    else {
        SecureCodeViewController *controller = [SecureCodeViewController new];
        controller.completeBlock = completeBlock;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
    }
}

- (void)dismissView {
    UIViewController *vc = [self presentingViewController];
    
    [self dismissViewControllerAnimated:YES completion: ^{
        if ([[[UIDevice currentDevice] systemVersion] intValue] < 8)
            [vc dismissViewControllerAnimated:YES completion:nil];
        
        if ([[transaction objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypePayment]] || [[transaction  objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypeCharge]]) {
            [appDelegate.revealSideViewController.timelineController reloadTable:TimelineFilterFriend andFocus:YES];
        }
    }];
    
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8 && [vc isKindOfClass:[FLNavigationController class]] && [vc.title isEqualToString:NSLocalizedString(@"NAV_NEW_FLOOZ_FRIENDS", nil)]) {
        [vc.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [vc.view setBackgroundColor:[UIColor clearColor]];
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion: ^{
        if (result == MessageComposeResultSent) {
            
        }
        else if (result == MessageComposeResultCancelled) {
            
        }
        else if (result == MessageComposeResultFailed) {
            
        }
        [self dismissView];
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)presentCamera {
    if (cameraDisplayed) {
        [self dismissCamera];
        [content becomeFirstResponder];
    }
    else {
        [self dismissKeyboard:nil];
        if (!cameraView) {
            if (!cameraBarKeyboard) {
                cameraBarKeyboard = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionSend:@selector(validSendMoney) actionCollect:@selector(validCollectMoney)];
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
    CGRectSetHeight(imageTransaction.frame, 80);
    CGRectSetWidth(imageTransaction.frame, 80);
    [imageTransaction setContentMode:UIViewContentModeScaleAspectFit];
    
    CGFloat scaleFactor = [self scaleFactor];
    CGRectSetHeight(imageTransaction.frame, imageTransaction.image.size.height / scaleFactor);
    CGRectSetWidth(imageTransaction.frame, imageTransaction.image.size.width / scaleFactor);
    
    CGRectSetY(imageTransaction.frame, 50);
    CGRectSetX(imageTransaction.frame, PPScreenWidth() - 14 - CGRectGetWidth(imageTransaction.frame));
    
    CGRectSetX(closeImage.frame, CGRectGetWidth(imageTransaction.frame) - CGRectGetWidth(closeImage.frame));
    
    [transaction setValue:UIImageJPEGRepresentation(rotateImage, 0.7) forKey:@"image"];
    [content setInputView:nil];
    [content setWidth:PPScreenWidth() - CGRectGetWidth(imageTransaction.frame)];
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
    [imageTransaction setImage:nil];
    [imageTransaction setAlpha:0.0];
    [transaction setValue:@"" forKey:@"image"];
}

- (void)dismissCamera {
    if (cameraDisplayed) {
        [UIView animateWithDuration:0.3 animations: ^{
            CGRectSetY(cameraView.frame, CGRectGetHeight(appDelegate.window.frame) - CGRectGetHeight(cameraBarKeyboard.frame));
        } completion: ^(BOOL finished) {
            [camera stopCamera];
            cameraDisplayed = NO;
        }];
    }
}

@end
