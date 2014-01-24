//
//  TransactionCell.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLTransaction.h"

#import "FLSocialView.h"

@interface TransactionCell : UITableViewCell{
    CGFloat height;
    
    UIView *validView;
    UIView *leftView;
    UIView *rightView;
    UIView *slideView;
    
    UIPanGestureRecognizer *gesture;
    CGPoint lastTranslation;
}

+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction;

@property (strong, nonatomic) FLTransaction *transaction;

@end
