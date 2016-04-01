//
//  NewCollectController.m
//  Flooz
//
//  Created by Olive on 3/3/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "NewCollectController.h"
#import "FLPaymentField.h"
#import "FLNewTransactionBar.h"
#import "FLPopupInformation.h"

#import "TimelineViewController.h"

#import "AppDelegate.h"

#import "FLTutoPopoverViewController.h"
#import "UIView+FindFirstResponder.h"
#import "FLPopoverTutoTheme.h"

#import "FLPopupTrigger.h"
#import "GeolocViewController.h"

@interface NewCollectController () {
    
    FLNewTransactionBar *transactionBar;
    FLNewTransactionBar *transactionBarKeyboard;
    FLNewTransactionBar *cameraBarKeyboard;
    
    FLPreset *currentPreset;
    
    FLTextField *name;
    FLTextView *content;
    
    FLTutoPopoverViewController *tutoPopover;
    WYPopoverController *popoverController;
    
    BOOL infoDisplayed;
    BOOL firstView;
    BOOL firstViewAmount;
    BOOL firstViewWhy;
    BOOL isDemo;
    
    NSTimer *demoTimer;
    
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

@implementation NewCollectController

@synthesize transaction;

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        
        transaction = [NSMutableDictionary new];
        
        currentPreset = [[FLPreset alloc] initWithJson:data];
        
        transaction[@"preset"] = @YES;
        transaction[@"random"] = [FLHelper generateRandomString];
        
        infoDisplayed = NO;
        firstView = YES;
        isDemo = currentPreset.popup != NULL || currentPreset.steps != NULL;
        
        if (currentPreset.title && ![currentPreset.title isBlank])
            self.title = currentPreset.title;
        else
            self.title = NSLocalizedString(@"NEW_COLLECT", nil);
        
        if (currentPreset.why)
            transaction[@"why"] = currentPreset.why;
        
        if (currentPreset.geo)
            transaction[@"geo"] = currentPreset.geo;
        
        if (currentPreset.payload)
            transaction[@"payload"] = currentPreset.payload;
        
        currentDemoStep = 0;
        firstViewWhy = currentPreset.focusWhy;
        
        [[Flooz sharedInstance] clearLocationData];
    }
    return self;
}


- (id)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"NEW_COLLECT", nil);
        transaction = [NSMutableDictionary new];
        
        currentPreset = nil;
        
        transaction[@"random"] = [FLHelper generateRandomString];
        transaction[@"preset"] = @NO;
        
        infoDisplayed = NO;
        firstView = YES;
        firstViewAmount = YES;
        firstViewWhy = NO;
        isDemo = NO;
        
        [[Flooz sharedInstance] clearLocationData];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionCollect:@selector(valid)];
    [transactionBar setDelegate:self];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPScreenHeight() - PPStatusBarHeight() - NAVBAR_HEIGHT - CGRectGetHeight(transactionBar.frame))];
    [self.view addSubview:self.contentView];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    if (currentPreset && currentPreset.blockBack)
        ((FLNavigationController*)self.parentViewController).blockBack = currentPreset.blockBack;
    
    transactionBarKeyboard = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionCollect:@selector(valid)];
    [transactionBarKeyboard setDelegate:self];
    
    _offset = 0;
    
    {
        NSString *namePlaceholder = NSLocalizedString(@"FIELD_COLLECT_NAME_PLACEHOLDER", nil);
        
        if (currentPreset && currentPreset.namePlaceholder)
            namePlaceholder = currentPreset.namePlaceholder;
        
        name = [[FLTextField alloc] initWithPlaceholder:namePlaceholder for:transaction key:@"name" frame:CGRectMake(5, 3, PPScreenWidth() - 10, 50)];
        [name setLineNormalColor:[UIColor clearColor]];
        [name setLineErrorColor:[UIColor clearColor]];
        [name setLineSelectedColor:[UIColor clearColor]];
        [name setLineDisableColor:[UIColor clearColor]];
        [name setInputAccessoryView:transactionBarKeyboard];
        [name addTextFocusTarget:self action:@selector(nameFocus)];
        
        [_contentView addSubview:name];
        
        _offset = CGRectGetHeight(name.frame);
        
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, _offset, SCREEN_WIDTH, 1)];
        [separator setBackgroundColor:[UIColor customMiddleBlue]];
        [_contentView addSubview:separator];
        
        ++_offset;
        
        NSString *contentPlaceholder = @"FIELD_COLLECT_CONTENT_PLACEHOLDER";
        
        if (currentPreset && currentPreset.whyPlaceholder)
            contentPlaceholder = currentPreset.whyPlaceholder;
        
        content = [[FLTextView alloc] initWithPlaceholder:contentPlaceholder for:transaction key:@"why" frame:CGRectMake(0, _offset, PPScreenWidth(), CGRectGetHeight(_contentView.frame) - CGRectGetHeight(transactionBar.frame) - _offset)];
        [content setInputAccessoryView:transactionBarKeyboard];
        [content addTextFocusTarget:self action:@selector(contentFocus)];
        
        [_contentView addSubview:content];
        
        [name addForNextClickTarget:content action:@selector(becomeFirstResponder)];
        
        [self prepareImage];
        
        if (currentPreset && currentPreset.blockWhy)
            [content setUserInteractionEnabled:!currentPreset.blockWhy];
        
        _offset = CGRectGetMaxY(content.frame);
        
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
        [_contentView addGestureRecognizer:tapG];
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
    
    [self reloadTransactionBarData];
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
        [name becomeFirstResponder];
    }
}

- (void)contentFocus {
    if ([popoverController isPopoverVisible])
        [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale];
}

- (void)nameFocus {
    if ([popoverController isPopoverVisible])
        [popoverController dismissPopoverAnimated:YES options:WYPopoverAnimationOptionFadeWithScale];
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
            else if ([stepData[@"focus"] isEqualToString:@"name"]) {
                [name becomeFirstResponder];
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
    } else if ([focus isEqualToString:@"name"]) {
        retRec = CGRectMake(retRec.origin.x, retRec.origin.y, 50, 40);
    } else if ([focus isEqualToString:@"scope"] || [focus isEqualToString:@"image"] || [focus isEqualToString:@"fb"] || [focus isEqualToString:@"pay"] || [focus isEqualToString:@"geo"]) {
        retRec = CGRectMake(retRec.origin.x, retRec.origin.y - 5, retRec.size.width, retRec.size.height);
    } else if ([focus isEqualToString:@"amount"]) {
        retRec = CGRectMake(retRec.origin.x + 15, retRec.origin.y - 5, retRec.size.width, retRec.size.height);
    }
    
    return retRec;
}

- (UIView*) getDemoStepPopoverView:(NSString*)focus {
    if ([focus isEqualToString:@"name"]) {
        return name;
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
        return transactionBar.collectButton;
    }
    if ([focus isEqualToString:@"geo"]) {
        return transactionBar.locationButton;
    }
    return nil;
}

- (WYPopoverArrowDirection) getDemoStepPopoverArrowDirection:(NSString*)focus {
    if ([focus isEqualToString:@"name"]) {
        return WYPopoverArrowDirectionUp;
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
    if ([focus isEqualToString:@"name"]) {
        return @[name];
    }
    if ([focus isEqualToString:@"scope"]) {
        return @[transactionBar.privacyButton];
    }
    if ([focus isEqualToString:@"why"]) {
        return @[content];
    }
    if ([focus isEqualToString:@"pay"]) {
        return @[transactionBar.collectButton];
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

- (void)valid {
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createCollectValidate:transaction success: ^(id result) {
        
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

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    [self reloadTransactionBarData];
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    [content setHeight:CGRectGetHeight(_contentView.frame) - keyboardHeight - CGRectGetHeight(name.frame) - 5];
    
    [self dismissCamera];
}

- (void)keyboardDidDisappear:(NSNotification *)notification {
    [self reloadTransactionBarData];
    transactionBar.hidden = NO;
    
    [content setHeight:CGRectGetHeight(_contentView.frame) - CGRectGetMinY(content.frame)];
}

- (void)keyboardWillDisappear {
    
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 125 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion: ^{
        if (currentPreset && currentPreset.isDemo) {
            [appDelegate askNotification];
        }
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)presentLocation {
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
                    cameraBarKeyboard = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionCollect:@selector(valid)];
                    [cameraBarKeyboard setDelegate:self];
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
                            cameraBarKeyboard = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self actionCollect:@selector(valid)];
                            [cameraBarKeyboard setDelegate:self];
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
