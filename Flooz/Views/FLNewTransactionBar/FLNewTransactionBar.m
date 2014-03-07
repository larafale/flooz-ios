//
//  FLNewTransactionBar.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLNewTransactionBar.h"

#import "AppDelegate.h"

@implementation FLNewTransactionBar

- (id)initWithFor:(NSMutableDictionary *)dictionary controller:(UIViewController *)controller
{
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 37)];
    if (self) {
        self.backgroundColor = [UIColor customBackgroundHeader];
        
        _dictionary = dictionary;
        currentController = controller;
        
        locationManager = [CLLocationManager new];
        locationManager.delegate = self;
        
        isEvent = NO;
        if([[_dictionary objectForKey:@"method"] isEqualToString:[FLTransaction transactionTypeToParams:TransactionTypeEvent]]){
            isEvent = YES;
        }
        
        [self createLocalizeButton];
        [self createImageButton];
        [self createFacebookButton];
        [self createSeparator];
        [self createPrivacyButton];
        
        if(isEvent){
            [_dictionary setValue:[FLTransaction transactionScopeToParams:TransactionScopeFriend] forKey:@"scope"];
             [privacyButton setTitle:[FLEvent transactionScopeToText:TransactionScopeFriend] forState:UIControlStateNormal];
        }
        else{
            [_dictionary setValue:[FLTransaction transactionScopeToParams:TransactionScopePublic] forKey:@"scope"];
            [privacyButton setTitle:[FLTransaction transactionScopeToText:TransactionScopePublic] forState:UIControlStateNormal];
        }
    }
    return self;
}

- (void)reloadData
{    
    localizeButton.selected = NO;
    imageButton.selected = NO;
    facebookButton.selected = NO;
    
    if([_dictionary objectForKey:@"lat"]){
        localizeButton.selected = YES;
    }
    if([_dictionary objectForKey:@"image"]){
        imageButton.selected = YES;
    }
    if([_dictionary objectForKey:@"share"]){
        facebookButton.selected = YES;
    }
    
    {
        NSInteger currentIndex = TransactionScopePublic;
        if(isEvent){
            currentIndex++;
        }
        for(NSInteger scope = currentIndex; scope <= TransactionScopePrivate; ++scope){
            if([[_dictionary objectForKey:@"scope"] isEqualToString:[FLTransaction transactionScopeToParams:scope]]){
                currentIndex = scope;
                break;
            }
        }
        
        if(isEvent){
            [privacyButton setTitle:[FLEvent transactionScopeToText:currentIndex] forState:UIControlStateNormal];
        }
        else{
            [privacyButton setTitle:[FLTransaction transactionScopeToText:currentIndex] forState:UIControlStateNormal];
        }
    }
}

- (void)createLocalizeButton
{
    localizeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];
    
    [localizeButton setImage:[UIImage imageNamed:@"new-transaction-bar-localize"] forState:UIControlStateNormal];
    [localizeButton setImage:[UIImage imageNamed:@"new-transaction-bar-localize-selected"] forState:UIControlStateSelected];
    [localizeButton setImage:[UIImage imageNamed:@"new-transaction-bar-localize-selected"] forState:UIControlStateHighlighted];
    
    [localizeButton addTarget:self action:@selector(didLocalizeButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:localizeButton];
    
    // WARNING cache le bouton
    localizeButton.hidden = YES;
}

- (void)createImageButton
{
//    imageButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(localizeButton.frame), 0, CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];

    imageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];
    
    [imageButton setImage:[UIImage imageNamed:@"new-transaction-bar-image"] forState:UIControlStateNormal];
    [imageButton setImage:[UIImage imageNamed:@"new-transaction-bar-image-selected"] forState:UIControlStateSelected];
    [imageButton setImage:[UIImage imageNamed:@"new-transaction-bar-image-selected"] forState:UIControlStateHighlighted];
    
    [imageButton addTarget:self action:@selector(didImageButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:imageButton];
}

- (void)createFacebookButton
{
//    facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageButton.frame), 0, CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];
    
        facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(localizeButton.frame), 0, CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];
    
    [facebookButton setImage:[UIImage imageNamed:@"new-transaction-bar-facebook"] forState:UIControlStateNormal];
    [facebookButton setImage:[UIImage imageNamed:@"new-transaction-bar-facebook-selected"] forState:UIControlStateSelected];
    [facebookButton setImage:[UIImage imageNamed:@"new-transaction-bar-facebook-selected"] forState:UIControlStateHighlighted];
    
    [facebookButton addTarget:self action:@selector(didFacebookButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:facebookButton];
}

- (void)createSeparator
{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(facebookButton.frame), 0, 1, CGRectGetHeight(self.frame))];
    
    separator.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:separator];
}

- (void)createPrivacyButton
{
    privacyButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(facebookButton.frame), 0, CGRectGetWidth(self.frame) - CGRectGetMaxX(facebookButton.frame), CGRectGetHeight(self.frame))];
    
    [privacyButton setImage:[UIImage imageNamed:@"arrow-blue-down"] forState:UIControlStateNormal];
    
    privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0, CGRectGetWidth(privacyButton.frame) - 20, 0, 0);
    privacyButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, [privacyButton imageForState:UIControlStateNormal].size.width);
    
    [privacyButton setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
    privacyButton.titleLabel.font = [UIFont customContentRegular:12];
    
    [privacyButton addTarget:self action:@selector(didPrivacyButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:privacyButton];
}

#pragma mark -

- (void)didLocalizeButtonTouch
{
    localizeButton.selected = !localizeButton.selected;
    
    if(localizeButton.selected){
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized){
            [locationManager startUpdatingLocation];
        }else{
            localizeButton.selected = NO;
            DISPLAY_ERROR(FLGPSAccessDenyError);
        }
    }
    else{
        [_dictionary setValue:nil forKey:@"lat"];
        [_dictionary setValue:nil forKey:@"lng"];
    }
}

- (void)didImageButtonTouch
{
    if(!imageButton.selected){
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"GLOBAL_CAMERA", nil), NSLocalizedString(@"GLOBAL_ALBUMS", nil), nil];
        
        // WARNING
        [actionSheet showInView:self];
    }
    else{
        [_dictionary setValue:nil forKey:@"image"];
        imageButton.selected = NO;
    }
}

- (void)didFacebookButtonTouch
{
    facebookButton.selected = !facebookButton.selected;
    
    if(facebookButton.selected){
        [_dictionary setValue:@"1" forKey:@"share"];
    }
    else{
        [_dictionary setValue:nil forKey:@"share"];
    }
}

- (void)didPrivacyButtonTouch
{
    NSInteger currentIndex = TransactionScopePublic;
    if(isEvent){
        currentIndex++;
    }
    
    for(NSInteger scope = currentIndex; scope <= TransactionScopePrivate; ++scope){
        if([[_dictionary objectForKey:@"scope"] isEqualToString:[FLTransaction transactionScopeToParams:scope]]){
            currentIndex = scope;
            break;
        }
    }
    
    currentIndex++;
    if(currentIndex > TransactionScopePrivate){
        currentIndex = TransactionScopePublic;
        if(isEvent){
            currentIndex++;
        }
    }
    
    [_dictionary setValue:[FLTransaction transactionScopeToParams:currentIndex] forKey:@"scope"];
    
    if(isEvent){
        [privacyButton setTitle:[FLEvent transactionScopeToText:currentIndex] forState:UIControlStateNormal];
    }
    else{
        [privacyButton setTitle:[FLTransaction transactionScopeToText:currentIndex] forState:UIControlStateNormal];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSNumber *lat = [NSNumber numberWithDouble:[manager.location coordinate].latitude];
    NSNumber *lng = [NSNumber numberWithDouble:[manager.location coordinate].longitude];
    
    [_dictionary setValue:lat forKey:@"lat"];
    [_dictionary setValue:lng forKey:@"lng"];
    
    [manager stopUpdatingLocation];
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
    
    [currentController presentViewController:cameraUI animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    
//    UIImage *resizedImage;
//    //Resize
//    {
//        CGFloat width = originalImage.size.width / originalImage.size.height * 156.;
//        CGSize newSize = CGSizeMake(width, 156);
//        
//        UIGraphicsBeginImageContext(newSize);
//        [originalImage drawInRect:CGRectMakeSize(newSize.width, newSize.height)];
//        resizedImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//    }
//    
    imageButton.selected = YES;
    [_dictionary setValue:UIImagePNGRepresentation(originalImage) forKey:@"image"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
