//
//  TransactionAmountView.h
//  Flooz
//
//  Created by olivier on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionAmountView : UIView {
	CGFloat height;
}

@property (weak, nonatomic) FLTransaction *transaction;

@end
