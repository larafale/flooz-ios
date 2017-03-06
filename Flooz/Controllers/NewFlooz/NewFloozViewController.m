//
//  NewFloozViewController.m
//  Flooz
//
//  Created by Olive on 07/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLAnimatedImage.h"
#import "NewFloozViewController.h"
#import "FLTextViewComment.h"
#import "DotActivityIndicatorView.h"
#import "DotActivityIndicatorParms.h"
#import "ImagePickerViewController.h"

@interface NewFloozViewController () {
    FLPreset *currentPreset;
    FLUser *selectedUser;
    
    UIScrollView *contentView;
    FLNewTransactionBar *transactionBar;
    UILabel *amountHint;
    FLNewTransactionAmountInput *amountInput;
    FLTextView *content;
    
    FLAnimatedImageView *imageTransaction;
    UIButton *imageCloseButton;
    DotActivityIndicatorView *imageProgressView;
    
    UIBarButtonItem *scopeItem;
    
    BOOL firstView;
    BOOL firstViewAmount;
    BOOL firstViewWhy;
    
    TransactionType currentTransactionType;
    
    CGFloat keyboardHeight;
    
    ScopePickerViewController *scopePickerViewController;
}

@end

@implementation NewFloozViewController

@synthesize transaction;

- (id)initWithTriggerData:(NSDictionary *)data {
    self = [super initWithTriggerData:data];
    if (self) {
        transaction = [NSMutableDictionary new];
        
        selectedUser = nil;
        
        currentPreset = [[FLPreset alloc] initWithJson:data];
        
        transaction[@"preset"] = @YES;
        transaction[@"random"] = [FLHelper generateRandomString];
        
        currentTransactionType = currentPreset.type;
        [transaction setValue:[FLTransaction transactionTypeToParams:currentPreset.type] forKey:@"method"];
        
        if (!currentPreset.isParticipation) {
            if (currentPreset.to) {
                transaction[@"to"] = currentPreset.to;
                self.title = [NSString stringWithFormat:@"@%@", currentPreset.to];
            }
            if (currentPreset.contact) {
                self.title = currentPreset.to;
                transaction[@"contact"] = currentPreset.contact;
            }
        } else {
            transaction[@"potId"] = currentPreset.presetId;
            self.title = currentPreset.collectName;
        }
        
        if (currentPreset.title && ![currentPreset.title isBlank])
            self.title = currentPreset.title;
        else
            self.title = NSLocalizedString(@"NEW_TRANSACTION", nil);
        
        if (currentPreset.amount) {
            transaction[@"amount"] = [FLHelper formatedAmount:currentPreset.amount withCurrency:NO withSymbol:NO];
        }
        
        if (currentPreset.why)
            transaction[@"why"] = currentPreset.why;
        
        if (currentPreset.geo)
            transaction[@"geo"] = currentPreset.geo;
        
        if (currentPreset.payload)
            transaction[@"payload"] = currentPreset.payload;
        
        if (currentPreset.blockAmount)
            firstViewAmount = !currentPreset.blockAmount;
        
        firstViewAmount = currentPreset.focusAmount;
        firstViewWhy = currentPreset.focusWhy;
        
        [[Flooz sharedInstance] clearLocationData];
    }
    return self;
}

- (id)initWithTransactionType:(TransactionType)transactionType user:(FLUser *)user {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = NSLocalizedString(@"NEW_TRANSACTION", nil);
        transaction = [NSMutableDictionary new];
        
        currentPreset = nil;
        selectedUser = user;
        
        self.title = NSLocalizedString(@"NEW_TRANSACTION", nil);
        
        transaction[@"random"] = [FLHelper generateRandomString];
        transaction[@"preset"] = @NO;
        
        currentTransactionType = transactionType;
        [transaction setValue:[FLTransaction transactionTypeToParams:transactionType] forKey:@"method"];
        
        firstView = YES;
        firstViewAmount = YES;
        firstViewWhy = NO;
        
        if (user.userKind == FloozUser) {
            transaction[@"to"] = user.username;
            [transaction removeObjectForKey:@"contact"];
        } else if (user.userKind == PhoneUser) {
            transaction[@"to"] = user.phone;
            if (user.firstname || user.lastname) {
                [transaction setValue:[NSMutableDictionary new] forKey:@"contact"];
                
                if (![user.firstname isBlank]) {
                    [[transaction objectForKey:@"contact"] setValue:user.firstname forKey:@"firstName"];
                }
                
                if (![user.lastname isBlank]) {
                    [[transaction objectForKey:@"contact"] setValue:user.lastname forKey:@"lastName"];
                }
            }
        } else {
            transaction[@"to"] = user.phone;
            [transaction removeObjectForKey:@"contact"];
        }
        
        [[Flooz sharedInstance] clearLocationData];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (currentPreset && currentPreset.isParticipation) {
        transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self preset:currentPreset actionParticipate:@selector(validParticipation)];
    } else {
        transactionBar = [[FLNewTransactionBar alloc] initWithFor:transaction controller:self preset:currentPreset actionSend:@selector(validSendMoney) actionCharge:@selector(validCollectMoney)];
    }
    
    [transactionBar setDelegate:self];
    
    scopeItem = [[UIBarButtonItem alloc] initWithImage:[UIImage new] style:UIBarButtonItemStylePlain target:self action:@selector(changeScope)];
    [scopeItem setTintColor:[UIColor whiteColor]];
    
    self.view.backgroundColor = [UIColor customBackground];
    
    if (currentPreset && currentPreset.blockBack)
        ((FLNavigationController*)self.parentViewController).blockBack = currentPreset.blockBack;
    
    amountInput = [[FLNewTransactionAmountInput alloc] initWithPlaceholder:@"0.00" for:transaction key:@"amount" currencySymbol:NSLocalizedString(@"GLOBAL_EURO", nil) andFrame:CGRectMake(PPScreenWidth() / 2, 0, PPScreenWidth() / 2, 40) delegate:nil];
    [amountInput hideSeparatorTop];
    [amountInput hideSeparatorBottom];
    
    if (currentPreset && currentPreset.blockAmount)
        [amountInput disableInput];
    
    [amountInput.textfield addTarget:self action:@selector(amountChange) forControlEvents:UIControlEventEditingChanged];
    
    amountHint = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, PPScreenWidth() / 2 - 10, 40)];
    
    if (selectedUser)
        amountHint.text = selectedUser.fullname;
    else if (currentPreset) {
        if (!currentPreset.isParticipation) {
            amountHint.text = currentPreset.toFullName;
        } else {
            amountHint.text = currentPreset.collectName;
        }
    }
    
    amountHint.textColor = [UIColor whiteColor];
    amountHint.font = [UIFont customContentLight:16];
    amountHint.userInteractionEnabled = YES;
    [amountHint addTapGestureWithTarget:self action:@selector(changeUser)];
    
    if (currentPreset && currentPreset.blockTo)
        [amountHint setUserInteractionEnabled:NO];
    
    UIView *amountSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(amountInput.frame), PPScreenWidth(), .7f)];
    [amountSeparator setBackgroundColor:[UIColor customBackground]];
    
    [_mainBody addSubview:amountInput];
    [_mainBody addSubview:amountHint];
    [_mainBody addSubview:amountSeparator];
    
    contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(amountSeparator.frame), PPScreenWidth(), CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(transactionBar.frame) - CGRectGetMaxY(amountSeparator.frame))];
    [contentView setBounces:NO];
    contentView.userInteractionEnabled = YES;
    
    NSString *contentPlaceholder = @"FIELD_TRANSACTION_CONTENT_PLACEHOLDER";
    
    if (currentPreset && currentPreset.whyPlaceholder)
        contentPlaceholder = currentPreset.whyPlaceholder;
    
    content = [[FLTextView alloc] initWithPlaceholder:contentPlaceholder for:transaction key:@"why" frame:CGRectMake(0, 5, PPScreenWidth(), 30)];
    [content setBackgroundColor:[UIColor clearColor]];
    content.textView.keyboardAppearance = UIKeyboardAppearanceLight;
    [content addTextFocusTarget:self action:@selector(contentFocusChanged:)];
    [content addTextChangeTarget:self action:@selector(contentTextChanged)];
    content.textView.scrollEnabled = NO;
    
    [contentView addTapGestureWithTarget:content action:@selector(becomeFirstResponder)];
    
    [contentView addSubview:content];
    
    if (currentPreset && currentPreset.blockWhy)
        [content setUserInteractionEnabled:!currentPreset.blockWhy];
    
    imageTransaction = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(10, 0, PPScreenWidth() - 20, ((PPScreenWidth() - 20) * 3) / 4)];
    imageTransaction.hidden = YES;
    imageTransaction.layer.masksToBounds = YES;
    imageTransaction.layer.cornerRadius = 3.;
    imageTransaction.contentMode = UIViewContentModeScaleAspectFill;
    imageTransaction.backgroundColor = [UIColor customBackground];
    [imageTransaction addTapGestureWithTarget:self action:@selector(showFullImage)];
    
    imageCloseButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(imageTransaction.frame) - 35, 5, 30, 30)];
    imageCloseButton.backgroundColor = [UIColor whiteColor];
    imageCloseButton.layer.masksToBounds = YES;
    imageCloseButton.layer.cornerRadius = 2.;
    [imageCloseButton setImage:[[UIImage imageNamed:@"trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [imageCloseButton setTintColor:[UIColor darkGrayColor]];
    [imageCloseButton addTarget:self action:@selector(didCloseImageButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    imageProgressView = [[DotActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetWidth(imageTransaction.frame) / 2 - CGRectGetHeight(imageTransaction.frame) / 6, CGRectGetHeight(imageTransaction.frame) / 3, CGRectGetHeight(imageTransaction.frame) / 3, CGRectGetHeight(imageTransaction.frame) / 3)];
    [imageProgressView setBackgroundColor:[UIColor clearColor]];
    [imageProgressView setHidden:YES];
    
    DotActivityIndicatorParms *dotParms = [DotActivityIndicatorParms new];
    dotParms.activityViewWidth = imageProgressView.frame.size.width;
    dotParms.activityViewHeight = imageProgressView.frame.size.height;
    dotParms.numberOfCircles = 3;
    dotParms.internalSpacing = 5;
    dotParms.animationDelay = 0.2;
    dotParms.animationDuration = 0.6;
    dotParms.animationFromValue = 0.3;
    dotParms.defaultColor = [UIColor customBlue];
    dotParms.isDataValidationEnabled = YES;
    
    [imageProgressView setDotParms:dotParms];
    
    [imageTransaction addSubview:imageCloseButton];
    [imageTransaction addSubview:imageProgressView];
    
    [contentView addSubview:imageTransaction];
    
    [_mainBody addSubview:contentView];
    
    CGRectSetY(transactionBar.frame,  CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(transactionBar.frame));
    [_mainBody addSubview:transactionBar];
    
    [self updateTransactionBar];

    [self registerForKeyboardNotifications];
    
    self.navigationItem.rightBarButtonItem = scopeItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateScope];
    [transactionBar reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (currentPreset) {
        if (currentPreset.image) {
            [transaction setValue:currentPreset.image forKey:@"imageUrl"];
            [transaction removeObjectForKey:@"image"];
            imageTransaction.hidden = NO;
            imageTransaction.image = nil;
            imageTransaction.animatedImage = nil;
            
            [imageProgressView setHidden:NO];
            [imageProgressView startAnimating];
            
            [imageCloseButton setHidden:YES];
            
            [imageTransaction sd_setImageWithURL:[NSURL URLWithString:currentPreset.image] placeholderImage:nil options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error) {
                    [imageProgressView stopAnimating];
                }
                else {
                    [imageProgressView stopAnimating];
                    [imageProgressView setHidden:YES];
                    [imageCloseButton setHidden:NO];
                }
            }];
            
            CGRectSetY(imageTransaction.frame, CGRectGetMaxY(content.frame) + 10);
            contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(imageTransaction.frame) + 10);
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
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[Flooz sharedInstance] clearLocationData];
}

- (void)changeUser {
    [self.navigationController pushViewController:[UserPickerViewController newWithDelegate:self] animated:YES];
}

- (void)user:(FLUser *)user pickedFrom:(UIViewController *)viewController {
    selectedUser = user;
    
    if (user.userKind == FloozUser) {
        transaction[@"to"] = user.username;
        [transaction removeObjectForKey:@"contact"];
    } else if (user.userKind == PhoneUser) {
        transaction[@"to"] = user.phone;
        if (user.firstname || user.lastname) {
            [transaction setValue:[NSMutableDictionary new] forKey:@"contact"];
            
            if (![user.firstname isBlank]) {
                [[transaction objectForKey:@"contact"] setValue:user.firstname forKey:@"firstName"];
            }
            
            if (![user.lastname isBlank]) {
                [[transaction objectForKey:@"contact"] setValue:user.lastname forKey:@"lastName"];
            }
        }
    } else {
        transaction[@"to"] = user.phone;
        [transaction removeObjectForKey:@"contact"];
    }
    
    amountHint.text = selectedUser.fullname;
    
    [self updateTransactionBar];
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)scope:(FLScope *)scope pickedFrom:(UIViewController *)viewController {
    [transaction setValue:scope.keyString forKey:@"scope"];
    [self updateScope];
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(NSString *)imageUrl pickedFrom:(UIViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    [transaction setValue:imageUrl forKey:@"imageUrl"];
    [transaction removeObjectForKey:@"image"];
    imageTransaction.hidden = NO;
    imageTransaction.image = nil;
    imageTransaction.animatedImage = nil;
    
    [imageProgressView setHidden:NO];
    [imageProgressView startAnimating];
    
    [imageCloseButton setHidden:YES];
    
    [imageTransaction sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil options:0 completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            [imageProgressView stopAnimating];
        }
        else {
            [imageProgressView stopAnimating];
            [imageProgressView setHidden:YES];
            [imageCloseButton setHidden:NO];
        }
    }];
    
    CGRectSetY(imageTransaction.frame, CGRectGetMaxY(content.frame) + 10);
    contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(imageTransaction.frame) + 10);
}

- (void)contentFocusChanged:(NSNumber *)focus {
    if ([focus boolValue])
        [transactionBar.textButton setTintColor:[UIColor customBlue]];
    else
        [transactionBar.textButton setTintColor:[UIColor whiteColor]];
}

- (void)contentTextChanged {
    
    CGFloat textViewWidth = content.textView.frame.size.width;
    
    CGSize size = [content.textView sizeThatFits:CGSizeMake(textViewWidth, CGFLOAT_MAX)];
    
    [content.textView setHeight:size.height];
    
    content.textView.contentSize = CGSizeMake(textViewWidth, size.height);
    
    CGRectSetHeight(content.frame, CGRectGetHeight(content.textView.frame));
    
    if (imageTransaction.isHidden) {
        contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(content.frame) + 10);
        
        CGRect cursorRect = [content.textView caretRectForPosition:content.textView.selectedTextRange.start];
        
        cursorRect = [contentView convertRect:cursorRect fromView:content.textView];
        
        if (![self rectVisible:cursorRect]) {
            cursorRect.size.height += 8; // To add some space underneath the cursor
            [contentView scrollRectToVisible:cursorRect animated:YES];
        }
    } else {
        CGRectSetY(imageTransaction.frame, CGRectGetMaxY(content.frame) + 10);
        contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(imageTransaction.frame) + 10);
        
        CGRect cursorRect = [content.textView caretRectForPosition:content.textView.selectedTextRange.start];
        
        cursorRect = [contentView convertRect:cursorRect fromView:content.textView];
        
        if (![self rectVisible:cursorRect]) {
            cursorRect.size.height += 8; // To add some space underneath the cursor
            [contentView scrollRectToVisible:cursorRect animated:YES];
        }
    }
}

- (BOOL)rectVisible: (CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = contentView.contentOffset;
    visibleRect.origin.y += contentView.contentInset.top;
    visibleRect.size = contentView.bounds.size;
    visibleRect.size.height -= contentView.contentInset.top + contentView.contentInset.bottom;
    
    return CGRectContainsRect(visibleRect, rect);
}

- (void)showFullImage {
    if (imageTransaction.image || imageTransaction.animatedImage) {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        
        if (transaction[@"image"])
            imageInfo.image = imageTransaction.image;
        else if (transaction[@"imageUrl"]) {
            [appDelegate showAvatarView:imageTransaction withUrl:[NSURL URLWithString:transaction[@"imageUrl"]]];
            return;
        } else
            return;
        
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
}

- (void)updateScope {
    FLScope *currentScope = [FLScope scopeFromObject:[[Flooz sharedInstance].currentUser.settings objectForKey:@"def"][@"scope"]];
    
    if (currentPreset && currentPreset.scopeDefined)
        currentScope = currentPreset.scope;
    
    for (FLScope *scope in [FLScope defaultScopeList]) {
        if ([[transaction objectForKey:@"scope"] isEqualToString:scope.keyString]) {
            currentScope = scope;
            break;
        }
    }
    
    if (currentPreset && currentPreset.scopes && currentPreset.scopes.count) {
        bool newScopeAvailable = NO;
        for (FLScope *scope in currentPreset.scopes) {
            if (scope.key == currentScope.key) {
                newScopeAvailable = YES;
                break;
            }
        }
        
        if (!newScopeAvailable) {
            currentScope = currentPreset.scopes[0];
        }
    }
    
    [scopeItem setImage:[[FLHelper imageWithImage:currentScope.image scaledToSize:CGSizeMake(25, 25)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    
    [transaction setValue:currentScope.keyString forKey:@"scope"];
}

- (void)updateTransactionBar {
    if (selectedUser) {
        if (selectedUser.blockObject != nil) {
            if ([selectedUser.blockObject objectForKey:@"charge"] != nil && [[selectedUser.blockObject objectForKey:@"charge"] boolValue]) {
                [self hidePayButton:false];
                [self hideChargeButton:true];
                [transactionBar hideButtonSeparator:true];
            } else if ([selectedUser.blockObject objectForKey:@"pay"] != nil && [[selectedUser.blockObject objectForKey:@"pay"] boolValue]) {
                [self hideChargeButton:false];
                [self hidePayButton:true];
                [transactionBar hideButtonSeparator:true];
            } else {
                [self resetPaymentButtons];
            }
        } else {
            [self resetPaymentButtons];
        }
    } else {
        [self resetPaymentButtons];
    }
}

- (void)hideChargeButton:(BOOL)hidden {
    [transactionBar hideChargeButton:hidden];
}

- (void)hidePayButton:(BOOL)hidden {
    [transactionBar hidePayButton:hidden];
}

- (void)resetPaymentButtons {
    if (!currentPreset || !currentPreset.isParticipation) {
        switch (currentTransactionType) {
            case TransactionTypePayment: {
                [self hideChargeButton:true];
                [self hidePayButton:false];
                [transactionBar hideButtonSeparator:true];
                break;
            }
            case TransactionTypeCharge: {
                [self hideChargeButton:false];
                [self hidePayButton:true];
                [transactionBar hideButtonSeparator:true];
                break;
            }
            case TransactionTypeCollect: {
                [self hideChargeButton:false];
                [self hidePayButton:false];
                [transactionBar hideButtonSeparator:false];
                break;
            }
            case TransactionTypeBase: {
                [self hideChargeButton:false];
                [self hidePayButton:false];
                [transactionBar hideButtonSeparator:false];
                break;
            }
        }
    }
}

-(void)amountChange {
    transaction[@"amount"] = amountInput.textfield.text;
}

- (void)validParticipation {
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createParticipationValidate:transaction success: ^(id result) {
        
    }];
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
        
    }];
}

- (void)changeScope {
    if (currentPreset && currentPreset.blockScope)
        return;
    
    if (scopePickerViewController == nil)
        scopePickerViewController = [ScopePickerViewController newWithDelegate:self preset:currentPreset forPot:NO];
    
    scopePickerViewController.currentScope = [FLScope scopeFromObject:transaction[@"scope"]];
    
    [self.navigationController pushViewController:scopePickerViewController animated:YES];
}

- (void)didCloseImageButtonClick {
    [transaction removeObjectForKey:@"image"];
    [transaction removeObjectForKey:@"imageUrl"];
    
    imageTransaction.image = nil;
    imageTransaction.animatedImage = nil;
    imageTransaction.hidden = YES;
    
    contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(content.frame) + 10);
}

#pragma mark - Transaction Bar Delegate

- (void)presentCamera {
    [self.view endEditing:YES];

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        UIImagePickerController *cameraUI = [UIImagePickerController new];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.delegate = self;
        cameraUI.allowsEditing = YES;
        [self presentViewController:cameraUI animated:YES completion: ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    } else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted){
                UIImagePickerController *cameraUI = [UIImagePickerController new];
                cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
                cameraUI.delegate = self;
                cameraUI.allowsEditing = YES;
                [self presentViewController:cameraUI animated:YES completion: ^{
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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

- (void)presentImagePicker {
    [self.view endEditing:YES];
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        [self createImagePickerActionSheet];
    }
    else {
        [self createImagePickerAlertController];
    }
}

- (void)createImagePickerActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [menus addObject:NSLocalizedString(@"GLOBAL_ALBUMS", nil)];
    }
    
    [menus addObject:NSLocalizedString(@"GLOBAL_WEB", nil)];
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"GLOBAL_ALBUMS", nil)]) {
        UIImagePickerController *cameraUI = [UIImagePickerController new];
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.delegate = self;
        cameraUI.allowsEditing = YES;
        [self presentViewController:cameraUI animated:YES completion: ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"GLOBAL_WEB", nil)]) {
        ImagePickerViewController *controller = [[ImagePickerViewController alloc] initWithDelegate:self andType:@"web"];
        
        [self.navigationController presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:nil];
    }
}

- (void)createImagePickerAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_ALBUMS", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            UIImagePickerController *cameraUI = [UIImagePickerController new];
            cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            cameraUI.delegate = self;
            cameraUI.allowsEditing = YES;
            [self presentViewController:cameraUI animated:YES completion: ^{
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }];
        }]];
    }
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_WEB", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        ImagePickerViewController *controller = [[ImagePickerViewController alloc] initWithDelegate:self andType:@"web"];
        
        [self.navigationController presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:nil];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(originalImage, 1);
    
    [picker dismissViewControllerAnimated:YES completion: ^{
        
    }];
    
    [transaction setValue:imageData forKey:@"image"];
    [transaction removeObjectForKey:@"imageUrl"];
    imageTransaction.hidden = NO;
    [imageProgressView setHidden:YES];
    imageTransaction.image = originalImage;
    
    CGRectSetY(imageTransaction.frame, CGRectGetMaxY(content.frame) + 10);
    contentView.contentSize = CGSizeMake(PPScreenWidth(), CGRectGetMaxY(imageTransaction.frame) + 10);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)presentGIFPicker {
    [self.view endEditing:YES];
    
    ImagePickerViewController *controller = [[ImagePickerViewController alloc] initWithDelegate:self andType:@"gif"];
    
    [self.navigationController presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:nil];
}

- (void)focusDescription {
    if ([content isFirstResponder])
        [content resignFirstResponder];
    else
        [content becomeFirstResponder];
}

- (void)presentLocation {
    [self.view endEditing:YES];
    
    GeolocViewController *controller = [GeolocViewController new];
    [controller setDelegate:self];
    
    if (transaction[@"geo"]) {
        controller.selectedPlace = transaction[@"geo"];
    }
    
    [self.navigationController presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:nil];
}

#pragma mark - Geoloc Delegate

- (void) locationPlaceSelected:(NSDictionary *)place {
    [transaction setObject:place forKey:@"geo"];
    [transactionBar reloadData];
}

- (void) removeLocation {
    [transaction removeObjectForKey:@"geo"];
    [transactionBar reloadData];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
    [self registerNotification:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(transactionBar.frame));
    CGRectSetHeight(contentView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(transactionBar.frame) - keyboardHeight - CGRectGetMinY(contentView.frame));
}

- (void)keyboardFrameChanged:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(transactionBar.frame));
    CGRectSetHeight(contentView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(transactionBar.frame) - keyboardHeight - CGRectGetMinY(contentView.frame));
}

- (void)keyboardWillDisappear {
    keyboardHeight = 0;
    
    CGRectSetY(transactionBar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(transactionBar.frame));
    CGRectSetHeight(contentView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(transactionBar.frame) - keyboardHeight - CGRectGetMinY(contentView.frame));
}

@end
