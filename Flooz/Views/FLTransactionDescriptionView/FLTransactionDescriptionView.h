//
//  FLTransactionDescriptionView.h
//  Flooz
//
//  Created by Arnaud on 2014-09-25.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLTransaction.h"
#import "TransactionCellDelegate.h"
#import "TransactionViewController.h"
#import "WYPopoverController.h"

@interface FLTransactionDescriptionView : UIView<WYPopoverControllerDelegate>

- (id)initWithFrame:(CGRect)frame andAvatar:(BOOL)avatar;
- (id)initWithFrame:(CGRect)frame transaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath andAvatar:(BOOL)avatar;
+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction avatarDisplay:(BOOL)withAvatar andWidth:(CGFloat)width;

@property (weak, nonatomic) UIViewController <TransactionCellDelegate> *delegate;
@property (weak, nonatomic) TransactionViewController *parentController;
@property (strong, nonatomic) FLTransaction *transaction;
@property (strong, nonatomic) NSIndexPath *indexPath;

@end