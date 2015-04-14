//
//  NewTransactionViewController.h
//  Flooz
//
//  Created by jonathan on 1/17/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLSelectAmountDelegate.h"
#import "FLNewTransactionAmount.h"
#import "FLNewTransactionAmountInput.h"
#import "FLPaymentFieldDelegate.h"
#import "NewTransactionSelectTypeDelegate.h"
#import "FLPreset.h"
#import <ImageIO/ImageIO.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "THContactPickerView.h"
#import "THContactViewStyle.h"
#import "FLUserPickerTableView.h"
#import "FLCameraKeyboard.h"
#import "WYPopoverController.h"
#import "FLNewTransactionBar.h"

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"
#define degreesToRadians(degrees) ((degrees) / 180.0 * M_PI)

@interface NewTransactionViewController : GlobalViewController <FLSelectAmountDelegate, FLPaymentFieldDelegate, NewTransactionSelectTypeDelegate, UIAlertViewDelegate, FLCameraKeyboardDelegate, MFMessageComposeViewControllerDelegate, THContactPickerDelegate, FLUserPickerTableViewDelegate, WYPopoverControllerDelegate, FLNewTransactionBarDelegate, WYPopoverControllerDelegate>

- (id)initWithTransactionType:(TransactionType)transactionType;
- (id)initWithTransactionType:(TransactionType)transactionType user:(FLUser *)user;
- (id)initWithPreset:(FLPreset *)preset;
- (void)presentCamera;

@property (weak, nonatomic) IBOutlet FLValidNavBar *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@property (retain) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, retain) NSMutableDictionary *transaction;

- (void)rotateImageWithRadians:(CGFloat)radian imageRotate:(UIImage *)rotateImage andImage:(UIImage *)image;

@end
