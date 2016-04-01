//
//  TransactionCell.h
//  Flooz
//
//  Created by olivier on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLTransaction.h"
#import "FLSocial.h"
#import "FLTransactionDescriptionView.h"

@interface TransactionCell : UITableViewCell {
	CGFloat height;
	FLTransactionDescriptionView *transactionDetailsView;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andDelegate:(id)delegate;
+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction andWidth:(CGFloat)width;
+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction andWidth:(CGFloat)width hideTitle:(BOOL)hideTitle;
- (void)block;

@property (strong, nonatomic) UIViewController <TransactionCellDelegate> *delegateController;
@property (strong, nonatomic) FLTransaction *transaction;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) Boolean hideTitle;

@end
