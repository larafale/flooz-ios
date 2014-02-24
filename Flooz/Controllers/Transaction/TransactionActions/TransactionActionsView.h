//
//  TransactionActionsView.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionActionsViewDelegate.h"

@interface TransactionActionsView : UIView{
    CGFloat height;
}

@property (weak, nonatomic) FLTransaction *transaction;
@property (weak, nonatomic) id<TransactionActionsViewDelegate> delegate;

@end
