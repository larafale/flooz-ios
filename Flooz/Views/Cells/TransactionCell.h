//
//  TransactionCell.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLTransaction.h"

#import "CellSocialView.h"

@interface TransactionCell : UITableViewCell{
    CGFloat height;
    
    UIView *leftView;
    UIView *rightView;
    UIView *slideView;
    
    UIPanGestureRecognizer *panGesture;
    CGPoint lastTranslation;
}

+ (CGFloat)getEstimatedHeight;
+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction;

@property (strong, nonatomic) FLTransaction *transaction;

@end
