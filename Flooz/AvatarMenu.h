//
//  AvatarMenu.h
//  Flooz
//
//  Created by Olivier on 10/22/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvatarMenu : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) UIViewController *parentController;
@property (nonatomic) UIImagePickerController *imagePickerController;

- (void)showAvatarMenu:(UIViewController*)controller;

@end
