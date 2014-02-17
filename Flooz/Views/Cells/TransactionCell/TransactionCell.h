//
//  TransactionCell.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLTransaction.h"
#import "TransactionCellDelegate.h"

#import "FLSocialView.h"

@interface TransactionCell : UITableViewCell{
    CGFloat height;
    
    UIView *actionView;
    UIView *leftView;
    UIView *rightView;
    UIView *slideView;
    
    CGPoint totalTranslation;
    CGPoint lastTranslation;
    
    BOOL isSwipable;
}

+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction;

@property (weak, nonatomic) UIViewController<TransactionCellDelegate> *delegate;
@property (weak, nonatomic) FLTransaction *transaction;

@end
