//
//  NewCollectController.h
//  Flooz
//
//  Created by Olive on 3/3/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FLPreset.h"
#import <ImageIO/ImageIO.h>
#import "WYPopoverController.h"
#import "FLNewTransactionBar.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "FLTransactionDescriptionView.h"
#import "GeolocViewController.h"
#import "ImagePickerViewController.h"


@interface NewCollectController : BaseViewController <UIAlertViewDelegate, FLNewTransactionBarDelegate, JTSImageViewControllerInteractionsDelegate, GeolocDelegate, ImagePickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) NSMutableDictionary *transaction;

@end
