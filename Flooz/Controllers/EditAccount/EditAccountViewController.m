//
//  EditAccountViewController.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EditAccountViewController.h"

#import "AppDelegate.h"

#import "FLSwitchView.h"

#define MARGE 0.
#define MARGE_HEADER 20.

@interface EditAccountViewController (){
    NSMutableDictionary *_user;
    NSMutableDictionary *_sepa;
    FLUserView *userView;
    FLSwitchView *facebookButton;
    
    FLTextFieldIcon *fieldPhone;
    FLTextFieldIcon *fieldEmail;
    
    UIButton *sendValidationSMS;
    UIButton *sendValidationEmail;
    
    NSArray *documents;
    NSMutableArray *documentsButton;
    
    NSInteger registerButtonCount;
    NSString *currentDocumentKey;
}

@end

@implementation EditAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_EDIT_ACCOUNT", nil);
        
        FLUser *currentUser = [[Flooz sharedInstance] currentUser];
        
        _user = [NSMutableDictionary new];
        [_user setObject:[NSMutableDictionary new] forKey:@"settings"];
        [[_user objectForKey:@"settings"] setObject:[[currentUser address] mutableCopy] forKey:@"address"];
        
        if([currentUser lastname]){
            [_user setObject:[currentUser lastname] forKey:@"lastName"];
        }
        if([currentUser firstname]){
            [_user setObject:[currentUser firstname] forKey:@"firstName"];
        }
        if([currentUser email]){
            [_user setObject:[currentUser email] forKey:@"email"];
        }
        if([currentUser phone]){
            [_user setObject:[currentUser phone] forKey:@"phone"];
        }
        
        _sepa = [[currentUser sepa] mutableCopy];
        
        documents = @[
                      @{@"CARD_ID_RECTO": @"cniRecto"},
                      @{@"CARD_ID_VERSO": @"cniVerso"},
                      @{@"HOME": @"justificatory"}
                      ];
        
        documentsButton = [NSMutableArray new];
        
        registerButtonCount = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(didValidTouch)];
        
    CGFloat height = 0;
    
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:_user key:@"firstName" position:CGPointMake(MARGE, 10) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(8, 16, 32, 32)];
        
        {
            userView = [[FLUserView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
            [userView setImageFromUser:[[Flooz sharedInstance] currentUser]];
            [view addSubview:userView];
        }
        
        [self registerButtonForAction:view];
        [_contentView addSubview:view];
    }
    
    {
        fieldPhone = [[FLTextFieldIcon alloc] initWithIcon:@"field-phone" placeholder:@"FIELD_PHONE" for:_user key:@"phone" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:fieldPhone];
        height = CGRectGetMaxY(fieldPhone.frame);
    }
    
    {
        fieldEmail = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_user key:@"email" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:fieldEmail];
        height = CGRectGetMaxY(fieldEmail.frame);
    }
        
    {
        sendValidationSMS = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100 - 5, 53, 100, 50)];
        
        sendValidationSMS.titleLabel.textAlignment = NSTextAlignmentRight;
        sendValidationSMS.titleLabel.font = [UIFont customContentRegular:12];
        [sendValidationSMS setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        [sendValidationSMS setTitle:NSLocalizedString(@"EDIT_ACCOUNT_SEND_SMS", nil) forState:UIControlStateNormal];
        [_contentView addSubview:sendValidationSMS];
        
        [sendValidationSMS addTarget:self action:@selector(didSendSMSValidationTouch:) forControlEvents:UIControlEventTouchUpInside];
        
//        height = CGRectGetMaxY(sendValidationSMS.frame);
    }
    
    {
        sendValidationEmail = [[UIButton alloc] initWithFrame:CGRectMake(sendValidationSMS.frame.origin.x, 98, 100, CGRectGetHeight(sendValidationSMS.frame))];
        
        sendValidationEmail.titleLabel.textAlignment = NSTextAlignmentRight;
        sendValidationEmail.titleLabel.font = [UIFont customContentRegular:12];
        [sendValidationEmail setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        [sendValidationEmail setTitle:NSLocalizedString(@"EDIT_ACCOUNT_SEND_MAIL", nil) forState:UIControlStateNormal];
        [_contentView addSubview:sendValidationEmail];
        
        [sendValidationEmail addTarget:self action:@selector(didSendEmailValidationTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:@"phone"] intValue] != 2){
        sendValidationSMS.hidden = YES;
    }
    else{
        [fieldPhone setReadOnly:YES];
    }
    
    if([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:@"email"] intValue] != 2){
        sendValidationEmail.hidden = YES;
    }
    else{
        [fieldEmail setReadOnly:YES];
    }
    
    {
        facebookButton = [[FLSwitchView alloc] initWithFrame:CGRectMake(0, height - 1, CGRectGetWidth(_contentView.frame), 45) title:@"EDIT_ACCOUNT_FACEBOOK"];
        
        {
            UIView *separatorTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(facebookButton.frame), 1)];
            UIView *separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(facebookButton.frame) - 1, CGRectGetWidth(facebookButton.frame), 1)];
            
            separatorTop.backgroundColor = separatorBottom.backgroundColor = [UIColor customSeparator];
            
            [facebookButton addSubview:separatorTop];
            [facebookButton addSubview:separatorBottom];
        }
        
        {
            UIImageView *fb = [UIImageView imageNamed:@"facebook2"];
            CGRectSetXY(fb.frame, 18, 16);
            [facebookButton addSubview:fb];
        }
        
        [facebookButton setAlternativeStyle];
        facebookButton.delegate = self;
        CGRectSetX(facebookButton.title.frame, 50);
        
        [_contentView addSubview:facebookButton];
        height = CGRectGetMaxY(facebookButton.frame);
    }
    
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-address" placeholder:@"FIELD_ADDRESS" for:[[_user objectForKey:@"settings"] objectForKey:@"address"] key:@"address" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-zip-code" placeholder:@"FIELD_ZIP_CODE" for:[[_user objectForKey:@"settings"] objectForKey:@"address"] key:@"zipCode" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }

    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-city" placeholder:@"FIELD_CITY" for:[[_user objectForKey:@"settings"] objectForKey:@"address"] key:@"city" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-rib" placeholder:@"FIELD_IBAN_PLACEHOLDER" for:_user key:@"iban" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    for(NSDictionary *dic in documents){
        NSString *key = [[dic allKeys] firstObject];
        NSString *value = [[dic allValues] firstObject];
        
        UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, height, SCREEN_WIDTH, 45)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
        
        [self registerButtonForAction:view];
        view.backgroundColor = [UIColor customBackground];
        view.titleLabel.font = [UIFont customTitleExtraLight:16];
        view.titleLabel.textColor = [UIColor whiteColor];
        
        [view setTitle:NSLocalizedString(([NSString stringWithFormat:@"DOCUMENTS_%@", key]), nil) forState:UIControlStateNormal];
        view.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [view setTitleEdgeInsets:UIEdgeInsetsMake(0, 47, 0, 0)];
        
        UIImageView *imageView;
        
        
        if([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:value] intValue] == 2 || ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:value] intValue] == 0 && [[[[Flooz sharedInstance] currentUser] settings] objectForKey:value])
           ){
            imageView = [UIImageView imageNamed:@"document-check"];
        }
        else{
            imageView = [UIImageView imageNamed:@"arrow-white-right"];
        }
        [documentsButton addObject:imageView];
        
        CGRectSetXY(imageView.frame, 290, 17);
        
        [view addSubview:imageView];
        
        {
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame) - 1, SCREEN_WIDTH, 1)];
            separator.backgroundColor = [UIColor customSeparator];
            [view addSubview:separator];
        }
        
        {
            UIImageView *icon = [UIImageView imageNamed:@"field-documents"];
            CGRectSetXY(icon.frame, 16, 17);
            [view addSubview:icon];
        }
    }
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    if([[Flooz sharedInstance] facebook_token]){
        facebookButton.on = YES;
    }
    else{
        facebookButton.on = NO;
    }
}

- (void)didValidTouch
{
    [[self view] endEditing:YES];
    
    _user[@"settings"] = @{ @"sepa": _sepa };
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateUser:_user success:^(id result) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:NULL];
}

- (void)didFacebookTouch
{
    [[Flooz sharedInstance] showLoadView];
    
    if([[Flooz sharedInstance] facebook_token]){
        facebookButton.on = NO;
        [[Flooz sharedInstance] disconnectFacebook];
    }
    else{
        facebookButton.on = YES;
        [[Flooz sharedInstance] connectFacebook];
    }
}

- (void)didSwitchViewSelected
{
    [self didFacebookTouch];
}

- (void)didSwitchViewUnselected
{
    [self didFacebookTouch];
}

- (void)registerButtonForAction:(UIButton *)button
{
    SEL action;
    switch (registerButtonCount) {
        case 0:
            action = @selector(didEditAvatarTouch);
            break;
        case 1:
            action = @selector(didDocumentTouch0);
            break;
        case 2:
            action = @selector(didDocumentTouch1);
            break;
        case 3:
            action = @selector(didDocumentTouch2);
            break;
        default:
            action = nil;
            NSLog(@"registerButtonForAction: unkown action");
            break;
    }
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    registerButtonCount++;
}

- (void)didEditAvatarTouch
{
    currentDocumentKey = nil;
    [self showImagePicker];
}

- (void)didDocumentTouch0
{
    currentDocumentKey = [[documents[0] allValues] firstObject];
    [self showImagePicker];
}

- (void)didDocumentTouch1
{
    currentDocumentKey = [[documents[1] allValues] firstObject];
    [self showImagePicker];
}

- (void)didDocumentTouch2
{
    currentDocumentKey = [[documents[2] allValues] firstObject];
    [self showImagePicker];
}

- (void)showImagePicker
{
    if(
        ([[[[[Flooz sharedInstance] currentUser] checkDocuments] objectForKey:currentDocumentKey] intValue] == 0 && [[[[Flooz sharedInstance] currentUser] settings] objectForKey:currentDocumentKey])
        ){
        return;
    }
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"GLOBAL_CAMERA", nil), NSLocalizedString(@"GLOBAL_ALBUMS", nil), nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidAppear:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillDisappear)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
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

#pragma mark - ImagePicker

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    
    if(buttonIndex == 0){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO){
            DISPLAY_ERROR(FLCameraAccessDenyError);
            return;
        }
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else if(buttonIndex == 1){
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO){
            DISPLAY_ERROR(FLAlbumsAccessDenyError);
            return;
        }
        
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }else{
        return;
    }
    
    cameraUI.delegate = self;
    
    [self presentViewController:cameraUI animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if(!currentDocumentKey){
        UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *resizedImage = [originalImage resize:CGSizeMake(640, 0)];
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);
        
        [userView setImageFromData:imageData];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] uploadDocument:imageData field:@"picId" success:NULL failure:NULL];
        }];
    }
    else{
        UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *resizedImage = [originalImage resize:CGSizeMake(640, 0)];
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);
        
        NSString *key = currentDocumentKey;
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] uploadDocument:imageData field:key success:^{
                NSUInteger index = 0;
                for(NSDictionary *dic in documents){
                    if([[[dic allValues] firstObject] isEqualToString:currentDocumentKey]){
                        break;
                    }
                    index++;
                }
                
                UIImageView *imageView = [documentsButton objectAtIndex:index];
                imageView.image = [UIImage imageNamed:@"document-check"];
                CGRectSetWidthHeight(imageView.frame, imageView.image.size.width, imageView.image.size.height);

            } failure:NULL];
        }];
    }
}

- (void)didSendSMSValidationTouch:(UIButton *)sender
{
    [[Flooz sharedInstance] sendSMSValidation];
    sender.hidden = YES;
}

- (void)didSendEmailValidationTouch:(UIButton *)sender
{
    [[Flooz sharedInstance] sendEmailValidation];
    sender.hidden = YES;
}

@end
