//
//  NewCollectController.h
//  Flooz
//
//  Created by Olive on 3/3/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FLNewTransactionAmount.h"
#import "FLNewTransactionAmountInput.h"
#import "FLPreset.h"
#import <ImageIO/ImageIO.h>
#import "FLCameraKeyboard.h"
#import "WYPopoverController.h"
#import "FLNewTransactionBar.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "FLTransactionDescriptionView.h"
#import "GeolocViewController.h"

@interface NewCollectController : GlobalViewController <UIAlertViewDelegate, FLCameraKeyboardDelegate, WYPopoverControllerDelegate, FLNewTransactionBarDelegate, JTSImageViewControllerInteractionsDelegate, GeolocDelegate>

- (void)presentCamera;
- (void)presentLocation;

@property (weak, nonatomic) IBOutlet FLValidNavBar *navBar;
@property (retain, nonatomic) UIView *contentView;

@property (retain) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, retain) NSMutableDictionary *transaction;

- (void)rotateImageWithRadians:(CGFloat)radian imageRotate:(UIImage *)rotateImage andImage:(UIImage *)image;

@end