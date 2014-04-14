//
//  EditAccountViewController.h
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLSwitchViewDelegate.h"

@interface EditAccountViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FLSwitchViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@end
