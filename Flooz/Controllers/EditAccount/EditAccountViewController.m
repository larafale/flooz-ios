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

#define MARGE 20.

@interface EditAccountViewController (){
    NSMutableDictionary *_user;
    FLUserView *userView;
    FLSwitchView *facebookButton;
    
    UIButton *sendValidationSMS;
    UIButton *sendValidationEmail;
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
        UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 65, 0, 65, 80)];
        
        {
            userView = [[FLUserView alloc] initWithFrame:CGRectMake(17, 25, 32, 32)];
            [userView setImageFromUser:[[Flooz sharedInstance] currentUser]];
            [view addSubview:userView];
        }
        
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.frame) - 16, CGRectGetWidth(view.frame), 16)];
            label.font = [UIFont customTitleBook:12];
            label.textColor = [UIColor customBlueLight];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = @"EDIT";
            
            [view addSubview:label];
        }
        
        [view addTarget:self action:@selector(didEditAvatarTouch) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:view];
    }

    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-name" placeholder:@"FIELD_FIRSTNAME" for:_user key:@"firstName" frame:CGRectMake(MARGE, 10, 225, 0) placeholder2:@"FIELD_LASTNAME" key2:@"lastName"];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-phone" placeholder:@"FIELD_PHONE" for:_user key:@"phone" frame:CGRectMake(MARGE, height, 225, 0)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        FLTextFieldIcon *view = [[FLTextFieldIcon alloc] initWithIcon:@"field-email" placeholder:@"FIELD_EMAIL" for:_user key:@"email" position:CGPointMake(MARGE, height)];
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }

    {
        sendValidationSMS = [[UIButton alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_contentView.frame) / 2., 50)];
        
        sendValidationSMS.titleLabel.textAlignment = NSTextAlignmentCenter;
        sendValidationSMS.titleLabel.font = [UIFont customContentRegular:12];
        [sendValidationSMS setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        [sendValidationSMS setTitle:NSLocalizedString(@"EDIT_ACCOUNT_SEND_SMS", nil) forState:UIControlStateNormal];
        [_contentView addSubview:sendValidationSMS];
        
        [sendValidationSMS addTarget:self action:@selector(didSendSMSValidationTouch) forControlEvents:UIControlEventTouchUpInside];
        
        height = CGRectGetMaxY(sendValidationSMS.frame);
    }
    
    {
        sendValidationEmail = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_contentView.frame) / 2., sendValidationSMS.frame.origin.y, CGRectGetWidth(_contentView.frame) / 2., CGRectGetHeight(sendValidationSMS.frame))];
        
        sendValidationEmail.titleLabel.textAlignment = NSTextAlignmentCenter;
        sendValidationEmail.titleLabel.font = [UIFont customContentRegular:12];
        [sendValidationEmail setTitleColor:[UIColor customBlueLight] forState:UIControlStateNormal];
        [sendValidationEmail setTitle:NSLocalizedString(@"EDIT_ACCOUNT_SEND_MAIL", nil) forState:UIControlStateNormal];
        [_contentView addSubview:sendValidationEmail];
        
        [sendValidationEmail addTarget:self action:@selector(didSendEmailValidationTouch) forControlEvents:UIControlEventTouchUpInside];
    }
    
    {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, height + 40, CGRectGetWidth(self.view.frame) - MARGE, 15)];
        view.font = [UIFont customContentRegular:12];
        view.textColor = [UIColor customBlueLight];
        view.text = NSLocalizedString(@"EDIT_ACCOUNT_PERSONAL_INFO", nil);
        
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
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
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, height + 40, 244, 20)];
        view.font = [UIFont customContentRegular:12];
        view.textColor = [UIColor customBlueLight];
        view.text = NSLocalizedString(@"EDIT_ACCOUNT_SOCIAL_INFO", nil);
        
        [_contentView addSubview:view];
        height = CGRectGetMaxY(view.frame);
    }
    
    {
        facebookButton = [[FLSwitchView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_contentView.frame), 56) title:@"EDIT_ACCOUNT_FACEBOOK"];
                
        {
            UIView *separatorTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(facebookButton.frame), 1)];
            UIView *separatorBottom = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(facebookButton.frame) - 1, CGRectGetWidth(facebookButton.frame), 1)];
            
            separatorTop.backgroundColor = separatorBottom.backgroundColor = [UIColor customSeparator];
            
            [facebookButton addSubview:separatorTop];
            [facebookButton addSubview:separatorBottom];
        }
        
        {
            UIImageView *fb = [UIImageView imageNamed:@"facebook2"];
            CGRectSetXY(fb.frame, 24, 21);
            [facebookButton addSubview:fb];
        }
        
        [facebookButton setAlternativeStyle];
        facebookButton.delegate = self;
        CGRectSetX(facebookButton.title.frame, 50);
        
//        [facebookButton setTitle:NSLocalizedString(@"EDIT_ACCOUNT_FACEBOOK", nil) forState:UIControlStateNormal];
//        [facebookButton setTitle:NSLocalizedString(@"EDIT_ACCOUNT_FACEBOOK_DISCNNECT", nil) forState:UIControlStateSelected];
//        [facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        facebookButton.titleLabel.font = [UIFont customContentLight:14];
//        
//        [facebookButton addTarget:self action:@selector(didFacebookTouch) forControlEvents:UIControlEventTouchUpInside];
//        
        [_contentView addSubview:facebookButton];
        height = CGRectGetMaxY(facebookButton.frame);
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

- (void)didEditAvatarTouch
{
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
    UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage = [originalImage resize:CGSizeMake(640, 0)];
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);

    [userView setImageFromData:imageData];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] uploadDocument:imageData field:@"picId" success:NULL failure:NULL];
    }];
}

- (void)didSendSMSValidationTouch
{
    
}

- (void)didSendEmailValidationTouch
{
    
}

@end
