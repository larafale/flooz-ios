//
//  NewFloozViewController.h
//  Flooz
//
//  Created by Olive on 07/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "GeolocViewController.h"
#import "FLNewTransactionBar.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "FLPreset.h"
#import "FLNewTransactionAmountInput.h"
#import "UserPickerViewController.h"
#import "ScopePickerViewController.h"
#import "ImagePickerViewController.h"

@interface NewFloozViewController : BaseViewController<GeolocDelegate, FLNewTransactionBarDelegate, JTSImageViewControllerInteractionsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UserPickerViewControllerDelegate, ScopePickerViewControllerDelegate, ImagePickerViewControllerDelegate>

@property (nonatomic, retain) NSMutableDictionary *transaction;

- (id)initWithTransactionType:(TransactionType)transactionType user:(FLUser *)user;

@end
