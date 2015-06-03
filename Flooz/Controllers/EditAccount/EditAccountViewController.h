//
//  EditAccountViewController.h
//  Flooz
//
//  Created by olivier on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLSwitchViewDelegate.h"

@interface EditAccountViewController : GlobalViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, FLSwitchViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@end
