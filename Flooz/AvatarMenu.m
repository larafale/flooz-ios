//
//  AvatarMenu.m
//  Flooz
//
//  Created by Olivier on 10/22/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "AvatarMenu.h"

@implementation AvatarMenu

- (void)showAvatarMenu:(UIViewController*)controller {
    
    self.parentController = controller;
    
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
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self presentPhoto];
        }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self presentLibrary];
        }]];
    }
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        [self getPhotoFromFacebook];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self.parentController presentViewController:newAlert animated:YES completion:nil];
}

- (void)createActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [menus addObject:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [menus addObject:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil)];
    }
    [menus addObject:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil)];
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet showInView:self.parentController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil)]) {
        [self presentPhoto];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil)]) {
        [self presentLibrary];
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil)]) {
        [self getPhotoFromFacebook];
    }
}

- (void)presentPhoto {
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.delegate = self;
    cameraUI.allowsEditing = YES;
    cameraUI.mediaTypes = @[(NSString *) kUTTypeImage];
    self.imagePickerController = cameraUI;
    [self.parentController presentViewController:cameraUI animated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)presentLibrary {
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cameraUI.delegate = self;
    cameraUI.allowsEditing = YES;
    cameraUI.mediaTypes = @[(NSString *) kUTTypeImage];
    self.imagePickerController = cameraUI;
    [self.parentController presentViewController:cameraUI animated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (void)getPhotoFromFacebook {
    [[Flooz sharedInstance] getFacebookPhoto: ^(id result) {
        if (result[@"id"]) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?&width=134&height=134", result[@"id"]]]];
            [self sendData:imageData];
        }
    }];
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
    
    [self sendData:imageData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendData:(NSData *)imageData {
    [[Flooz sharedInstance] uploadDocument:imageData field:@"picId" success:NULL failure:NULL];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"editAvatar" object:imageData];
}

@end
