//
//  TransactionUsersCollectView.h
//  Flooz
//
//  Created by olivier on 02/08/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionActionsViewDelegate.h"

@interface TransactionUsersCollectView : UIView

@property (weak, nonatomic) FLTransaction *transaction;
@property (weak, nonatomic) id <TransactionActionsViewDelegate> delegate;

@end
