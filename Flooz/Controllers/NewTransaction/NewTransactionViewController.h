//
//  NewTransactionViewController.h
//  Flooz
//
//  Created by olivier on 1/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLNewTransactionAmount.h"
#import "FLNewTransactionAmountInput.h"
#import "FLPaymentFieldDelegate.h"
#import "FLPreset.h"
#import <ImageIO/ImageIO.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "THContactPickerView.h"
#import "THContactViewStyle.h"
#import "FLUserPickerTableView.h"
#import "FLCameraKeyboard.h"
#import "WYPopoverController.h"
#import "FLNewTransactionBar.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "FLTransactionDescriptionView.h"

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"
#define degreesToRadians(degrees) ((degrees) / 180.0 * M_PI)

@interface NewTransactionViewController : GlobalViewController <FLPaymentFieldDelegate, UIAlertViewDelegate, FLCameraKeyboardDelegate, MFMessageComposeViewControllerDelegate, THContactPickerDelegate, FLUserPickerTableViewDelegate, WYPopoverControllerDelegate, FLNewTransactionBarDelegate, WYPopoverControllerDelegate, JTSImageViewControllerInteractionsDelegate>

- (id)initWithTransactionType:(TransactionType)transactionType;
- (id)initWithTransactionType:(TransactionType)transactionType user:(FLUser *)user;
- (id)initWithPreset:(FLPreset *)preset;
- (void)presentCamera;

@property (weak, nonatomic) IBOutlet FLValidNavBar *navBar;
@property (retain, nonatomic) UIView *contentView;

@property (retain) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, retain) NSMutableDictionary *transaction;

- (void)rotateImageWithRadians:(CGFloat)radian imageRotate:(UIImage *)rotateImage andImage:(UIImage *)image;

@end
